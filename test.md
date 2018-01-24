# Trying to learn Lua & Love2D!<br><br>Assignments

### Note: Documentation located at `/src/doc/index.html/`

## Make testSprite2 flip by pressing 'e'!
### Two methods (try both!):
- Add code into `love.keypressed` and `love.keyreleased` to do it.
- Add code into `love.load` to do it using the scheduler.

### Tips:
- The scheduler module takes functions as its parameters.
You can declare them right in the parameters. There's plenty of examples in the code for it.

## Make testSprite2 cycle between a rainbow gradient!
### Two methods (try both!):
- Add code into `love.update` to do it.
- Add code into `love.load` to do it using the scheduler.

### Tips:
- `color.lua` has a function called `hsv` which converts HSV color to RGB color. That'll make this easy.

## Make your own sprite!
- Add your own image, and create your own. There's plenty of documentation in `sprite.lua` and in `src/doc/index.html` for it!

### Bonus!
- Animate it somehow! If you don't have a spritesheet, just animate the color.

## Advanced: Make a "class"!
- Lua doesn't _really_ have classes, but there's some code in here that simulates it.

### Tips:
- Good examples include `sprite.lua`, `animation.lua`, `object.lua`, and `camera.lua`.
- If you need callbacks (or setters, if you prefer the java name), that's what `object.lua` is for.

### A few ideas:
- A class for the loading bar. (You might not see it, but the loading bar is in the code!)
- A class for a "character". (a sprite which can move)
