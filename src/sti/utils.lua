local loader = require "love-loader.love-loader"

-- Some utility functions that shouldn't be exposed.
local utils = {}

-- https://github.com/stevedonovan/Penlight/blob/master/lua/pl/path.lua#L286
function utils.format_path(path)
    local np_gen1, np_gen2 = '[^SEP]+SEP%.%.SEP?', 'SEP+%.?SEP'
    local np_pat1, np_pat2 = np_gen1:gsub('SEP', '/'), np_gen2:gsub('SEP', '/')
    local k

    repeat -- /./ -> /
        path, k = path:gsub(np_pat2, '/')
    until k == 0

    repeat -- A/../ -> (empty)
        path, k = path:gsub(np_pat1, '')
    until k == 0

    if path == '' then
        path = '.'
    end

    return path
end

-- Compensation for scale/rotation shift
function utils.compensate(tile, tileX, tileY, tileW, tileH)
    local origx = tileX
    local origy = tileY
    local compx = 0
    local compy = 0

    if tile.sx < 0 then
        compx = tileW
    end
    if tile.sy < 0 then
        compy = tileH
    end

    if tile.r > 0 then
        tileX = tileX + tileH - compy
        tileY = tileY + tileH + compx - tileW
    elseif tile.r < 0 then
        tileX = tileX + compy
        tileY = tileY - compx + tileH
    else
        tileX = tileX + compx
        tileY = tileY + compy
    end

    return tileX, tileY
end

-- Cache images in main STI module
function utils.cache_image(sti, path, image)
    local tbl = { image = image }
    loader.newImage(tbl, "image", path)
    if loadingAssets then
        loadingCallbacks[#loadingCallbacks + 1] = function()
            tbl.image:setFilter("nearest", "nearest")
            sti.cache[path] = tbl.image
            tbl = nil
        end
    else
        tbl.image:setFilter("nearest", "nearest")
        sti.cache[path] = tbl.image
        tbl = nil
    end
end

-- We just don't know.
function utils.get_tiles(imageW, tileW, margin, spacing)
    imageW = imageW - margin
    local n = 0

    while imageW >= tileW do
        imageW = imageW - tileW
        if n ~= 0 then
            imageW = imageW - spacing
        end
        if imageW >= 0 then
            n = n + 1
        end
    end

    return n
end

-- Decompress tile layer data
function utils.get_decompressed_data(data)
    local ffi = require "ffi"
    local d = {}
    local decoded = ffi.cast("uint32_t*", data)

    for i = 0, data:getSize() / ffi.sizeof("uint32_t") do
        table.insert(d, tonumber(decoded[i]))
    end

    return d
end

-- Convert a Tiled ellipse object to a LOVE polygon
function utils.convert_ellipse_to_polygon(x, y, w, h, max_segments)
    local ceil = math.ceil
    local cos = math.cos
    local sin = math.sin

    local function calc_segments(segments)
        local function vdist(a, b)
            local c = {
                x = a.x - b.x,
                y = a.y - b.y,
            }

            return c.x * c.x + c.y * c.y
        end

        segments = segments or 64
        local vertices = {}

        local v = { 1, 2, ceil(segments / 4 - 1), ceil(segments / 4) }

        local m
        if love and love.physics then
            m = love.physics.getMeter()
        else
            m = 32
        end

        for _, i in ipairs(v) do
            local angle = (i / segments) * math.pi * 2
            local px = x + w / 2 + cos(angle) * w / 2
            local py = y + h / 2 + sin(angle) * h / 2

            table.insert(vertices, { x = px / m, y = py / m })
        end

        local dist1 = vdist(vertices[1], vertices[2])
        local dist2 = vdist(vertices[3], vertices[4])

        -- Box2D threshold
        if dist1 < 0.0025 or dist2 < 0.0025 then
            return calc_segments(segments - 2)
        end

        return segments
    end

    local segments = calc_segments(max_segments)
    local vertices = {}

    table.insert(vertices, { x = x + w / 2, y = y + h / 2 })

    for i = 0, segments do
        local angle = (i / segments) * math.pi * 2
        local px = x + w / 2 + cos(angle) * w / 2
        local py = y + h / 2 + sin(angle) * h / 2

        table.insert(vertices, { x = px, y = py })
    end

    return vertices
end

function utils.rotate_vertex(map, vertex, x, y, cos, sin)
    if map.orientation == "isometric" then
        x, y = utils.convert_isometric_to_screen(map, x, y)
        vertex.x, vertex.y = utils.convert_isometric_to_screen(map, vertex.x, vertex.y)
    end

    vertex.x = vertex.x - x
    vertex.y = vertex.y - y

    return
    x + cos * vertex.x - sin * vertex.y,
    y + sin * vertex.x + cos * vertex.y
end

--- Project isometric position to cartesian position
function utils.convert_isometric_to_screen(map, x, y)
    local mapH = map.height
    local tileW = map.tilewidth
    local tileH = map.tileheight
    local tileX = x / tileH
    local tileY = y / tileH
    local offsetX = mapH * tileW / 2

    return
    (tileX - tileY) * tileW / 2 + offsetX,
    (tileX + tileY) * tileH / 2
end

function utils.hex_to_color(hex)
    if hex:sub(1, 1) == "#" then
        hex = hex:sub(2)
    end

    return {
        r = tonumber(hex:sub(1, 2), 16),
        g = tonumber(hex:sub(3, 4), 16),
        b = tonumber(hex:sub(5, 6), 16)
    }
end

function utils.pixel_function(_, _, r, g, b, a)
    local mask = utils._TC

    if r == mask.r and
            g == mask.g and
            b == mask.b then
        return r, g, b, 0
    end

    return r, g, b, a
end

function utils.fix_transparent_color(tileset, path)
    loader.newImage(tileset, "image", path)

    if loadingAssets then
        loadingCallbacks[#loadingCallbacks + 1] = function()
            if tileset.transparentcolor then
                utils._TC = utils.hex_to_color(tileset.transparentcolor)

                local image_data = tileset.image:getData()
                image_data:mapPixel(utils.pixel_function)
                tileset.image = love.graphics.newImage(image_data)
            end
        end
    else
        if tileset.transparentcolor then
            utils._TC = utils.hex_to_color(tileset.transparentcolor)

            local image_data = tileset.image:getData()
            image_data:mapPixel(utils.pixel_function)
            tileset.image = love.graphics.newImage(image_data)
        end
    end
end

return utils
