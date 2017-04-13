--It begins.
io.stdout:setvbuf "no" --Makes printing not buffer, so it prints instantly.
animation = animation or require "animation"
sprite = sprite or require "sprite"
pretty = pretty or require "pl.pretty"

event = require "event"

local mousePosX, mousePosY = 0, 0
local w, h = 50, 50
local avgColorsPerSecond = 1
local testSprite, testSprite2

function love.load()
    testSprite = sprite {
        imagePath = "testSprite.png",
        w = 100,
        h = 100,
        flipVertical = true,
        flipHorizontal = true
    }
    testSprite.animations[1]:start()
    testSprite2 = sprite {
        w = 100,
        h = 100,
        image = love.graphics.newImage "testSprite.png",
        flipVertical = true,
        flipHorizontal = true
    }
    print(pretty.write(testSprite))
    love.graphics.setColor(255, 0, 0)
end

function love.draw()
    love.graphics.rectangle("fill", testSprite.x, testSprite.y, testSprite.w, testSprite.h)
    sprite.drawAll()
end

function love.mousemoved(x, y)
    mousePosX, mousePosY = x, y
    testSprite.x, testSprite.y = x, y
    testSprite2.x, testSprite2.y = x, y
end
