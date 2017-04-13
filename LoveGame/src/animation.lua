local animation
animation = animation or {
    new = function(self, args)
        local obj = {
            frames = args.frames or {},
            frameDurations = args.frameDurations or 1 / 60,
            currentFrame = 1,
            lastTime = 0,
            remainingTime = 0,
            sprite = nil,
            animation = self,
            start = self.start,
            stop = self.stop
        }
        return setmetatable(obj, { __index = animation })
    end,
    start = function(self)
        self.animation.runningAnimations[self.sprite] = self
        self.lastTime = love.timer.getTime()
        self.sprite.animating = self
    end,
    stop = function(self)
        self.animation.runningAnimations[self.sprite] = nil
        self.sprite.animating = false
    end,
    runningAnimations = {},
    animate = function(self)
        if not self.sprite.visible then
            animation.runningAnimations[self.sprite] = nil
        end
        local timePassed = love.timer.getTime() - self.lastTime --Get the delta between the last frame of animation and now.
        if self.remainingTime > timePassed then --If the leftover time before the next frame is animated is higher than the time passed...
            self.remainingTime = self.remainingTime - timePassed --Subtract it from the leftover time
            self.lastTime = love.timer.getTime() --Update the time of the last frame
            return
        else
            timePassed = timePassed - self.remainingTime --Subtract it from the time passed and move to the next frame.
            self.currentFrame = self.currentFrame == #self.frames and 1 or self.currentFrame + 1
        end
        if type(self.frameDurations) == "number" then
            while timePassed > 0 do
                if self.frameDurations > timePassed then
                    self.remainingTime = self.frameDurations - timePassed --Set the leftover time, and break
                    break
                end
                timePassed = timePassed - self.frameDurations --Subtract the time from one frame
                self.currentFrame = self.currentFrame == #self.frames and 1 or self.currentFrame + 1 --Next frame!
            end
        else
            while timePassed > 0 do
                if self.frameDurations[self.currentFrame] > timePassed then
                    self.remainingTime = self.frameDurations[self.currentFrame] - timePassed --Set the leftover time, and break
                    break
                end
                timePassed = timePassed - self.frameDurations[self.currentFrame] --Subtract the time from one frame
                self.currentFrame = self.currentFrame == #self.frames and 1 or self.currentFrame + 1 --Next frame!
            end
        end
        self.lastTime = love.timer.getTime() --Update the time of the last frame
    end,
    animateAll = function()
        for _, anim in pairs(animation.runningAnimations) do
            anim:animate()
        end
    end
}

setmetatable(animation, { __call = animation.new })

return animation