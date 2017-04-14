--It begins.
io.stdout:setvbuf "no" --Makes printing not buffer, so it prints instantly.
animation = animation or require "animation"
sprite = sprite or require "sprite"
pretty = pretty or require "pl.pretty"

event = require "event"

local w, h = -50, -10
local testSprite, testSprite2

function love.load()
    testSprite = sprite {
        imagePath = "assets/testSprite.png",
        w = w,
        h = h,
        ox = sprite.centerOx,
        oy = sprite.centerOy,
    }
    testSprite.animations[1]:start()
end

function love.draw()
    sprite.drawAll()
end

function love.update(dt)
    sprite.updateAll()
    testSprite.rotation = (testSprite.rotation + 1) % 360
end

function love.mousemoved(x, y)
    testSprite.x, testSprite.y = x - testSprite.w / 2, y - testSprite.h / 2
end
