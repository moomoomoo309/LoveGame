--It begins.
io.stdout:setvbuf "no" --Makes printing not buffer, so it prints instantly.
animation = animation or require "animation"
sprite = sprite or require "sprite"
pretty = pretty or require "pl.pretty"

event = require "event"

local w, h = 50, 10
local testSprite, testSprite2

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
end

function love.draw()
    sprite.drawAll()
end

function love.update(dt)
    sprite.updateAll()
    testSprite2.rotation = (testSprite.rotation + 360 * math.sin(love.timer.getTime())) % 360
end

function love.mousemoved(x, y)
    testSprite.x, testSprite.y = x, y
    testSprite2.x, testSprite2.y = x, y
    if x > love.graphics.getWidth() / 2 then
        testSprite2.animations.idle:resume()
    else
        testSprite2.animations.idle:pause()
    end
end
