object = object or require "object"
local camera

local function removeSelf(self, tbl)
    for i = 1, #tbl do
        if tbl[i] == self then
            table.remove(tbl, i)
            break
        end
    end
end

local function transition(self, time, interpolation, values)
    local interFct = camera.interpolations[interpolation] or camera.interpolations.linear --How it should interpolate
    local startValues, endValues, keys = {}, {}, {}
    for k, v in pairs(values) do
        startValues[#startValues+1] = v
        endValues[#endValues+1] = self[k]
        keys[#keys+1] = k
    end
    local startTime = love.timer.getTime()
    local stopTime = time + startTime
    local transitionFct
    local firstIteration = true --The first iteration is way off, so it should be ignored.
    local lastInterValues = {}
    transitionFct = function(self)
        local currentTime = love.timer.getTime()
        local percentProgress = (currentTime - startTime) / (stopTime - startTime)
        percentProgress = percentProgress > 1 and 1 or percentProgress --Make sure the progress doesn't exceed one, but that it gets to the end at 1.
        local deltas, interValues = {}, {}
        for i = 1, #startValues do
            interValues[i] = interFct(0, endValues[i] - startValues[i], percentProgress)
            if #lastInterValues > 0 then
                deltas[i] = interValues[i] - lastInterValues[i]
            end
        end
        lastInterValues = interValues --Grab the last values for the next delta.
        if firstIteration then
            --Ignore the first iteration, since it isn't a delta in the first iteration.
            firstIteration = false
            return
        end
        for i = 1, #keys do
            self[keys[i]] = self[keys[i]] + deltas[i] --Actually offset the values in the camera.
        end
        if percentProgress == 1 then
            removeSelf(transitionFct, self.drawFcts) --Remove yourself from the draw functions.
        end
    end
    self.drawFcts[#self.drawFcts+1] = transitionFct --Add the above function to the list of draw functions.
end

camera = {
    interpolations = {
        linear = function(start, stop, percentProgress)
            return start + (stop - start) * (1-percentProgress)
        end,
        cos = function(start, stop, percentProgress)
            local f = (1-math.cos((1-percentProgress) * math.pi)) / 2
            return start * (1-f) + stop * f
        end
    },
    new = function(_, args)
        if not args then
            args = _
        end
        local obj = object {
            x = args.x or 0,
            y = args.y or 0,
            w = args.w or love.graphics.getWidth(),
            h = args.h or love.graphics.getHeight(),
            viewport = args.viewport or love.graphics.getDimensions(),
            zoom = args.zoom or 1,
            rotation = args.rotation or 0,
            drawFcts = {}
        }
        obj:addCallback("w", function(self, w)
            self.viewport[1] = w
        end)
        obj:addCallback("h", function(self, h)
            self.viewport[2] = h
        end)
        obj:addCallback("viewport", function(self, viewport)
            if type(viewport) ~= "table" then
                error(("Viewport should be a table, was a %s."):format(type(viewport)))
            end
            if #viewport==2 then
                self.w, self.h = unpack(viewport)
            else
                error"Viewport length not 2!"
            end
        end)
        obj.class = camera
        return obj
    end,
    draw = function(self)
        local centerX = self.x + self.w / 2 / self.zoom
        local centerY = self.y + self.h / 2 / self.zoom
        love.graphics.push()
        love.graphics.scale(self.zoom)
        love.graphics.translate(centerX, centerY)
        love.graphics.rotate(math.rad(self.rotation))
        local drawFcts = self.drawFcts
        for _, v in pairs(drawFcts) do
            if v then
                v(self)
            end
        end
    end,
    toCameraCoords = function(self, x, y)
        local xRot, yRot = math.cos(-self.rotation), math.sin(-self.rotation)
        x, y = (x - self.w/2) / self.zoom, (y-self.h/2) / self.zoom
        x, y = xRot * x - yRot * y, yRot * x + xRot * y
        return x+self.x, y+self.y
    end,
    toWorldCoords = function(self, x, y)
        local xRot, yRot = math.cos(-self.rotation), math.sin(-self.rotation)
        x, y = x+self.x, y+self.y
        x, y = xRot * x - yRot * y, yRot * x + xRot * y
        return (x - self.w/2) / self.zoom, (y-self.h/2) / self.zoom
    end,
    pan = function(self, x, y, time, interpolation)
        transition(self, time, interpolation, { x = x, y = y })
    end,
    panTo = function(self, obj, time, interpolation)
        local camX, camY = -obj.x, -obj.y
        self:pan(camX, camY, time, interpolation)
    end,
    zoomTo = function(self, newZoom, time, interpolation)
        transition(self, time, interpolation, { zoom = newZoom })
    end
}

return setmetatable(camera, { __call = camera.new, __index = object })
