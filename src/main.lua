--It begins.
io.stdout:setvbuf "no" --Makes printing not buffer, so it prints instantly.
local sprite = require "sprite"
require "gooi"
loadingAssets = true
loadingCallbacks = {}
local loader = require "love-loader.love-loader"
local sti = require "sti"
local camera = require "camera"
local moonshine = require "moonshine"
local scheduler = require "scheduler"
local baton = require "baton.baton"
local bump = require "bump.bump"
local entity = require "entity"

local loadingFont
local defaultFont = love.graphics.getFont()
local w, h = love.graphics.getDimensions()
local testSprite, playerSprite, background
local cam
local effects = {}
local rot = false
local controls

local defaultControls = {
    jump = { "key:up", "key:w", "button:dpup", "button:a", "axis:lefty-" },
    duck = { "key:down", "key:s", "button:dpdown", "axis:lefty+" },
    right = { "key:right", "key:d", "button:dpright", "axis:leftx+" },
    left = { "key:left", "key:a", "button:dpleft", "axis:leftx-" },
    pause = { "key:escape", "button:start" }
}

function love.load()
    playerSprite = sprite {
        imagePath = "assets/idle_boxmaker_beta.png",
        x = w / 2,
        y = h / 2,
        w = 34,
        h = 64,
        ox = sprite.centerOx,
        oy = sprite.centerOy,
    }
    loadingCallbacks[#loadingCallbacks + 1] = function()
        playerSprite.animations.idle:start()
    end

    cam = camera:new {
        w = w,
        h = h,
    }
    cam:follow(player)
    effects.pause = moonshine(moonshine.effects.boxblur).chain(moonshine.effects.vignette)
    effects.pause.boxblur.radius = 1
    effects.pause.vignette.radius = .95
    effects.pause.vignette.softness = .5
    effects.pause.vignette.opacity = 1

    loadingFont = love.graphics.newFont(36)
    loader.start(function()
        loadingAssets = false
        for _, v in pairs(loadingCallbacks) do
            v()
        end
        loadingCallbacks = nil
        loadingFont = nil
        love.graphics.setFont(defaultFont)
    end)
    love.graphics.setFont(loadingFont)
    controls = baton.new(defaultControls, love.joystick.getJoysticks()[1])
end

local function drawLoadingBar()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local percentLoaded = loader.loadedCount / loader.resourceCount
    local r, g, b = love.graphics.getColor()
    love.graphics.printf("Loading...", w * .1, h * .375, w * .9, "left")
    love.graphics.printf(("%d%%"):format(percentLoaded * 100), 0, h * .375, w * .9, "right")
    love.graphics.setColor(.5, .5, .5)
    love.graphics.rectangle("fill", w * .1, h * .45, w * .8, h * .1)

    --A scissor is used here so the rectangle could easily be replaced with an image.
    love.graphics.setScissor(w * .11, h * .465, w * .78 * percentLoaded, h * .0725)

    --TODO: Replace the rectangle with something better
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("fill", w * .11, h * .465, w * .78, h * .0725)
    love.graphics.setColor(r, g, b)

    love.graphics.setScissor()
end

function love.draw()
    if loadingAssets then
        drawLoadingBar()
    else
        --Draw anything not affected by the camera, but below the sprites and GUI here.
        love.graphics.setBackgroundColor(0, 0, 0)
        effects.pause.draw(function()
            cam:draw()
            local trans = cam.getTransformations()
            -- Draw white background, make sure rectangle is large enough to cover all rotations.
            local size = math.max(love.graphics.getWidth() / trans[2], love.graphics.getHeight() / trans[2])
            local posOffset = size * .20710678118654757 --This constant is (sqrt(2)-1)/2.
            size = size * 1.4142135623730951 --This constant is sqrt(2).
            love.graphics.rectangle("fill", -trans[4] - posOffset, -trans[5] - posOffset, size, size)
            love.graphics.pop() --Pop the camera transformations. Anything controlled by the camera should go before this.
        end)
        --Draw anything not affected by the camera and above the sprites here.
        gooi.draw()
    end
end

local function checkControls()
    controls:update()
    if controls:down "jump" then
        player.y = player.y - 1
    end
    if controls:down "left" then
        player.x = player.x - 1
    end
    if controls:down "right" then
        player.x = player.x + 1
    end
    if controls:down "duck" then
        player.y = player.y + 1
    end
end

function love.update(dt)
    if loadingAssets then
        loader.update()
    end
    scheduler.update(dt)
    cam.rotation = rot and (testSprite.rotation + 360 * math.sin(love.timer.getTime())) % 360 or 0
    gooi.update(dt)
    camera.update()
    entity.updateAll()
    checkControls()
end

function love.mousemoved(x, y)
end

function love.mousepressed(x, y, button)
    gooi.pressed()
    if button == 1 then
        cam:panTo(playerSprite, 1)
    elseif button == 2 then
        local newZoom = math.random() * 5
        cam:zoomTo(newZoom, 1)
    elseif button == 3 then
        if cam.followFct then
            cam:unfollow()
        else
            cam:follow(playerSprite)
        end
    end
end

function love.keypressed(key)
    if key == "space" then
        rot = not rot
    end
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousereleased(x, y)
    gooi.released()
end
