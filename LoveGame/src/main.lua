--It begins.
io.stdout:setvbuf "no" --Makes printing not buffer, so it prints instantly.
animation = animation or require "animation"
sprite = sprite or require "sprite"
pretty = pretty or require "pl.pretty"
require "gooi"
loveloader = loveloader or require "love-loader.love-loader"
sti = sti or require "sti"
camera = camera or require "camera"

event = require "event"

local w, h = 50, 10
local testSprite, testSprite2
local cam

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
    love.graphics.setBackgroundColor(255, 255, 255)
    cam = camera:new()
end

function love.draw()
    cam:draw()
    sprite.drawAll()
    gooi.draw()
    love.graphics.pop() --Pop the camera transformations
end

function love.update(dt)
    loveloader.update()
    sprite.updateAll()
    testSprite2.rotation = (testSprite.rotation + 360 * math.sin(love.timer.getTime())) % 360
    cam.rotation = testSprite2.rotation
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
        cam:panTo(testSprite2, 1, "cos")
    elseif button == 2 then
        local newZoom = math.random()*2
        cam:zoomTo(newZoom, 1, "cos")
    end
end

function love.mousereleased(x, y)
    gooi.released()
end
