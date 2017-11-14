--It begins.
io.stdout:setvbuf "no" --Makes printing not buffer, so it prints instantly.
local sprite = require "sprite"
require "gooi"
local loveloader = require "love-loader.love-loader"
local camera = require "camera"
local shine = require "shine"
local scheduler = require "scheduler"

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
    testSprite.animations.backAndForth:start()
    testSprite2.animations.idle:start()
    cam = camera:new()
    effects.blur = shine.boxblur()
    effects.blur.radius_v, effects.blur.radius_h = 1, 1

    effects.vignette = shine.vignette()
    effects.vignette:set("radius", .95)
    effects.vignette:set("softness", .5)
    effects.vignette:set("opacity", 1)

    effects.pause = effects.blur:chain(effects.vignette)

end

function love.draw()
    --Draw the map above. (Anything not affected by the camera, but below the sprites and GUI)
    love.graphics.setBackgroundColor(0, 0, 0)
    effects.pause:draw(function()
        cam:draw()
        local trans = cam.getTransformations()
        -- Draw white background, make sure rectangle is large enough to cover all rotations.
        -- The minimum would be size * sqrt(2), and the X and Y would be -trans[4]-size*(1-sqrt(2))/2 and -trans[5]-size*(1-sqrt(2))/2,
        -- But why do sqrt(2) so much when you can just use 2 and 4, which are doable with left/right shifts?
        local size = math.max(love.graphics.getWidth() / trans[2], love.graphics.getHeight() / trans[2])
        love.graphics.rectangle("fill", -trans[4] - size / 4, -trans[5] - size / 4, size * 2, size * 2)

        sprite.drawAll()
        love.graphics.pop() --Pop the camera transformations. Anything controlled by the camera should go before this.
    end)
    --GUI or anything that does not move with the camera should go after here.
    gooi.draw()
end

function love.update(dt)
    loveloader.update()
    scheduler.update(dt)
    camera.inst.rotation = rot and (testSprite.rotation + 360 * math.sin(love.timer.getTime())) % 360 or 0
    gooi.update(dt)
    camera.update()
end

local function followMouse(x, y)
    testSprite.x, testSprite.y = x, y
    testSprite2.x, testSprite2.y = x, y
    if x > love.graphics.getWidth() / 2 then
        testSprite2.animations.idle:resume()
    else
        testSprite2.animations.idle:pause()
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
end

function love.mousereleased(x, y)
    gooi.released()
end
