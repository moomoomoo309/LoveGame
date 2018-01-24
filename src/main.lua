--It begins.
io.stdout:setvbuf "no" --Makes printing not buffer, so it prints instantly.
local sprite = require "sprite"
require "gooi"
local loader = require "love-loader.love-loader"
local camera = require "camera"
local shine = require "shine"
local scheduler = require "scheduler"
local color = require "color"
loadingAssets = true
loadingCallbacks = {}

local w, h = 50, 10
local testSprite, testSprite2, background
local cam
local effects = {}
local rot = false

function love.load()
    testSprite = sprite {
        imagePath = "assets/testSprite.png",
        w = w,
        h = h,
        ox = sprite.centerOx,
        oy = sprite.centerOy,
    }

    testSprite2 = sprite {
        imagePath = "assets/idle_boxmaker_beta.png",
        w = 64,
        h = 128,
        ox = sprite.centerOx,
        oy = sprite.centerOy,
    }

    background = sprite {
        imagePath = "assets/idle_boxmaker_beta.png",
        x = 0,
        y = 0,
        w = 400,
        h = 400,
    }
    loadingCallbacks[#loadingCallbacks + 1] = function()
        testSprite.animations.backAndForth:start()
        testSprite2.animations.idle:start()
    end
    cam = camera:new()
    effects.blur = shine.boxblur()
    effects.blur.radius_v, effects.blur.radius_h = 1, 1

    effects.vignette = shine.vignette()
    effects.vignette:set("radius", .95)
    effects.vignette:set("softness", .5)
    effects.vignette:set("opacity", 1)

    effects.pause = effects.blur:chain(effects.vignette)

    loader.start(function()
        loadingAssets = false
        for _, v in pairs(loadingCallbacks) do
            v()
        end
        loadingCallbacks = nil
    end)

end

function love.draw()
    if loadingAssets then
        local w, h = love.graphics.getWidth(), love.graphics.getHeight()
        local percentLoaded = loader.loadedCount / loader.resourceCount
        local r, g, b = love.graphics.getColor()
        love.graphics.printf("Loading...", w * .1, h * .375, w * .9, "left")
        love.graphics.printf(("%d%%"):format(percentLoaded * 100), 0, h * .375, w * .9, "right")
        love.graphics.setColor(128, 128, 128)
        love.graphics.rectangle("fill", w * .1, h * .45, w * .8, h * .1)

        --A scissor is used here so the rectangle could easily be replaced with an image.
        love.graphics.setScissor(w * .11, h * .465, w * .78 * percentLoaded, h * .0725)

        --TODO: Replace the rectangle with something better
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("fill", w * .11, h * .465, w * .78, h * .0725)
        love.graphics.setColor(r, g, b)

        love.graphics.setScissor()
    else
        --Draw anything not affected by the camera, but below the sprites and GUI here.
        love.graphics.setBackgroundColor(0, 0, 0)
        effects.pause:draw(function()
            cam:draw()
            local trans = cam.getTransformations()
            -- Draw white background, make sure rectangle is large enough to cover all rotations.
            local size = math.max(love.graphics.getWidth() / trans[2], love.graphics.getHeight() / trans[2])
            local posOffset = size * .20710678118654757 --This constant is (sqrt(2)-1)/2.
            size = size * 1.4142135623730951 --This constant is sqrt(2).
            love.graphics.rectangle("fill", -trans[4] - posOffset, -trans[5] - posOffset, size, size)
            sprite.drawAll()
            love.graphics.pop() --Pop the camera transformations. Anything controlled by the camera should go before this.
        end)
        --Draw anything not affected by the camera and above the sprites here.
        gooi.draw()
    end
end

function love.update(dt)
    if loadingAssets then
        loader.update()
    end
    scheduler.update(dt)
    camera.inst.rotation = rot and (testSprite.rotation + 360 * math.sin(love.timer.getTime())) % 360 or 0
    gooi.update(dt)
    camera.update()
end

local function followMouse(x, y)
    testSprite.x, testSprite.y = x, y
    testSprite2.x, testSprite2.y = x, y
    if not loadingAssets then
        if x > love.graphics.getWidth() / 2 then
            testSprite2.animations.idle:resume()
        else
            testSprite2.animations.idle:pause()
        end
    end
end

function love.mousemoved(x, y)
    followMouse(x, y)
end

function love.mousepressed(x, y, button)
    gooi.pressed()
    if button == 1 then
        cam:panTo(testSprite2, 1)
    elseif button == 2 then
        local newZoom = math.random() * 1.5
        cam:zoomTo(newZoom, 1)
    elseif button == 3 then
        if cam.followFct then
            cam:unfollow()
        else
            cam:follow(testSprite2)
        end
    end
end

function love.keypressed(key)
    if key == "space" then
        rot = not rot
    end
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousereleased(x, y)
    gooi.released()
end
