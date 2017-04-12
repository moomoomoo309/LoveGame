--It begins.
io.stdout:setvbuf "no" --Makes printing not buffer, so it prints instantly.

event = require "event"

local mousePosX, mousePosY = 0, 0
local w, h = 50, 50
local avgColorsPerSecond = 1

function love.update(dt)
  if math.random(0, 1 / (dt * avgColorsPerSecond)) < 1 then
    love.graphics.setColor(math.random(0, 255), math.random(0, 255), math.random(0, 255))
  end
end

function love.draw()
  love.graphics.rectangle("fill",mousePosX - w / 2, mousePosY - h / 2, w, h)
end

function love.mousemoved(x, y)
  mousePosX, mousePosY = x, y
end
