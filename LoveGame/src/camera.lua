object = object or require "object"
timer = timer or require "timer"
local camera

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
            args = _ or {}
        end
        local obj = object {
            x = args.x or 0,
            y = args.y or 0,
            w = args.w or love.graphics.getWidth(),
            h = args.h or love.graphics.getHeight(),
            viewport = args.viewport or love.graphics.getDimensions(),
            zoom = args.zoom or 1,
            rotation = args.rotation or 0,
            updateFcts = {},
            followFct = nil,
            inst = nil
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
        if camera.inst then
            error "Camera instance already exists! Camera is a singleton!"
        end
        camera.inst = obj
        return obj
    end,
    draw = function(self)
        local centerX = self.x + self.w / 2 / self.zoom
        local centerY = self.y + self.h / 2 / self.zoom
        love.graphics.push()
        love.graphics.scale(self.zoom)
        love.graphics.translate(centerX, centerY)
        love.graphics.rotate(math.rad(self.rotation))
    end,
    getTranslations = function(self)
        self = self or camera.inst
        local centerX = self.x + self.w / 2 / self.zoom
        local centerY = self.y + self.h / 2 / self.zoom
        return { math.rad(self.rotation), self.zoom, self.zoom, centerX, centerY }
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
    transition = function(self, time, interpolation, values, key, fct)
        local interFct = camera.interpolations[interpolation] or camera.interpolations.cos --How it should interpolate
        local endValues, startValues, keys = {}, {}, {}
        for k, v in pairs(values) do
            endValues[#endValues+1] = v
            startValues[#startValues+1] = self[k]
            keys[#keys+1] = k
            if time == 0 then
                self[k] = v
            end
        end
        if time == 0 then
            if type(fct) == "function" then
                fct(self, 1)
            end
            return
        end
        local transitionFct
        local firstIteration = true --The first iteration is way off, so it should be ignored.
        local lastInterValues = {}
        local cam = camera.inst
        transitionFct = function(timeElapsed)
            local percentProgress = timeElapsed / time
            percentProgress = percentProgress > 1 and 1 or percentProgress --Make sure the progress doesn't exceed one
            local deltas, interValues = {}, {}
            for i = 1, #endValues do
                interValues[i] = interFct(0, startValues[i] - endValues[i], percentProgress)
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
                cam[keys[i]] = cam[keys[i]] + deltas[i] --Actually offset the values in the camera.
            end
            if type(fct) == "function" then
                fct(cam, percentProgress)
            end
        end
        cam.updateFcts[key or #cam.updateFcts+1] = transitionFct --Add the above function to the list of update functions.
        timer.before(time, transitionFct)
        timer.after(time, function()
            for i = 1, #keys do
                if values[i] ~= nil then
                    cam[keys[i]] = values[i] --Make sure the camera values end up being where they should be.
                end
            end
        end)
    end,
    pan = function(self, x, y, time, interpolation, fct)
        return self:transition(time, interpolation, { x = x, y = y }, "pan", fct)
    end,
    panTo = function(self, obj, time, interpolation, fct)
        return self:pan(-obj.x, -obj.y, time, interpolation, fct)
    end,
    zoomTo = function(self, newZoom, time, interpolation, fct)
        return self:transition(time, interpolation, { zoom = newZoom }, "zoom", fct)
    end,
    follow = function(self, obj)
        if not self.followFct then
            self.followFct = function()
                self.x, self.y = -obj.x, -obj.y
            end
            timer["until"](function()
                return not self.followFct
            end, self.followFct, nil)
        end
    end,

}

return setmetatable(camera, { __call = camera.new, __index = object })
