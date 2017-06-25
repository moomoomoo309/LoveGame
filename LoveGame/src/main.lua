--It begins.
io.stdout:setvbuf "no" --Makes printing not buffer, so it prints instantly.
animation = animation or require "animation"
sprite = sprite or require "sprite"
pretty = pretty or require "pl.pretty"
require "gooi"
loveloader = loveloader or require "love-loader.love-loader"
sti = sti or require "sti"
camera = camera or require "camera"
shine = shine or require"shine"

event = require "event"

local w, h = 50, 10
local testSprite, testSprite2
local cam
local effects = {}

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
    testSprite.animations.backAndForth:start()
    testSprite2.animations.idle:start()
    cam = camera:new()
    effects.blur = shine.boxblur()
    effects.blur.radius_v, effects.blur.radius_h = 3, 3

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
        local trans = cam.getTranslations()
        love.graphics.rectangle("fill", -trans[4], -trans[5], love.graphics.getWidth(), love.graphics.getHeight())
        sprite.drawAll()
        love.graphics.pop() --Pop the camera transformations. Anything controlled by the camera should go before this.
    end)
    --GUI or anything that does not move with the camera should go after here.
    gooi.draw()
end

function love.update(dt)
    loveloader.update()
    timer.update(dt)
    sprite.updateAll()
    testSprite2.rotation = (testSprite.rotation + 360 * math.sin(love.timer.getTime())) % 360
    gooi.update(dt)
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
        local newZoom = math.random()*1.5
        cam:zoomTo(newZoom, 1)
    elseif button == 3 then
        if cam.followFct then
            cam.followFct = nil
        else
            cam:follow(testSprite2)
        end
    end
end

function love.mousereleased(x, y)
    gooi.released()
end
