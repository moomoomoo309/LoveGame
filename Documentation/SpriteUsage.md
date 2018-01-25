# Using the sprite class

## Construction

    sprite:new {
        --Put args here
    }
    --Or
    sprite.new {
        --Put args here
    }
    --Or
    sprite {
        --Put args here
    }

## Parameters
- Id: number (sprite.Id())
  - The Id, a number used to specify drawing order. If the Id is taken, a new one will be assigned.
- imagePath: string (false)
  - The path to the image and/or the animation used for the image/animation.
- image: Drawable (nil)
  - Used to draw the sprite when no animation is playing. Will be set if the imagePath is specified.
- animations: table ({})
  - A list of animations used for the sprite. Will be set if the imagePath is specified.
- visible: boolean (true)
  - Whether or not the sprite should be drawn.
- x: number (0)
  - The X-coordinate of the sprite.
- y: number (0)
  - The Y-coordinate of the sprite.
- w: number (0)
  - The width of the sprite.
- h: number (0)
  - The height of the sprite.
- ox: number, function (0)
  - The offset from the top left of the sprite in the X-direction, in unscaled coordinates. Should be a function, because you need to divide by sx!
- oy: number, function (0)
  - The offset from the top left of the sprite in the Y-direction, in unscaled coordinates. Should be a function, because you need to divide by sy!
- rotation: number (0)
  - How much the sprite should be rotated, in degrees.
- flipHorizontal: boolean (false)
  - If the sprite should be flipped horizontally. Flips in-place, respecting ox and width.
- flipVertical: boolean (false)
  - If the sprite should be flipped vertically. Flips in-place, respecting oy and height.
- alpha: number (255)
  - How opaque the sprite should be, from 0 to 255. (0 is transparent, 255 is opaque)
- color: table (nil)
  - What color should be overlayed over the image. nil or false is identical to {255,255,255}.
- filterMin: string ("nearest")
  - How it should scale the sprite when scaling down. Can be "nearest" or "linear".
- filterMax: string ("nearest")
  - How it should scale the sprite when scaling up. Can be "nearest" or "linear".
- anisotropy: number (0)
  - The maximum anisotropic filtering it should apply.
- animPath: string (the imagePath with the extension changed to anim, or false if the imagePath is not specified)
  - The path to the anim file specifying the animation for the sprite.

### Internal Only Parameters
- animating: false
  - Specifies whether or not the sprite is playing an animation (even if it's paused, this will still be true!). If it is true, it will be a pointer to the running animation.
- sx: nil
  - The scale in the X-direction. Used as a width multiplier, but not set until drawing.
- sy: nil
  - The scale in the Y-direction. Used as a height multiplier, but not set until drawing.

## The animation class

### Construction
- In code
  - Same as sprite class. (animation.new{}, animation:new{}, or animation{})
- In a file
  - Make a lua file that returns a table in the following format:

#### Table Format
- Name: String - The name of the animation, and how it will be accessed. (mySprite[animationName].method())
  - \[colors]: Table {r,g,b\[,a]}, {{r,g,b\[,a]},{r,g,b\[,a]},...}, function(self, currentFrame, frameCount) returning Table in previous format - The color(s) that should be overlayed for a given frame of the animation.
  - frameSize: Table {x,y}, {{x,y},{x,y},...} - The size of each frame.
  - frames: Table {x,y}, {{x,y},{x,y},...} - The coordinates of the top left corner of each frame.
  - frameDurations: Number, Table {Number, Number, ...} - How long each frame should be, in seconds.

##### Example:
    color = color or require "color"
    local tbl
    tbl = {
        backAndForth = {
            colors = function(_, _, frameCount)
                return { color.hsv(frameCount * tbl.backAndForth.frameDurations * hueCyclesPerSecond * 256 % 256, 255, 255) }
            end,
            frameSize = { 5, 1 },
            frames = {
                { 1, 1 },
                { 1, 3 },
                { 1, 5 },
                { 1, 7 },
                { 1, 9 },
                { 1, 7 },
                { 1, 5 },
                { 1, 3 },
            },
            frameDurations = 1 / 60
        },
    }
    return tbl

### Possible Errors:

##### If the file could not be executed:
 - "Could not execute file at \[filePath]. Is the path correct, or is the file malformed?"

##### If the file does not return a table:
 - "Expected table, found \[type]."

##### If frameSize or any of its entries are not a table:
 - "frameSize must be a table, is a \[type]."

##### If frameSize has a non-number in it:
 - "frameSize\[\[entry number]\] must be a number, is a \[type of the entry]."

##### If frameSize contains no tables and has an odd length:
 - "The frameSize (\[length of frameSize]) must be a multiple of two!"

##### If any of the entries in frameSize don't have two entries:
 - "The frameSize for frame \[frameNumber] (\[length of frameSize]) must be a multiple of two!"

##### If the length of frameDurations and frameSize does not match:
 - "Mismatched frame duration (\[size of frameDurations]) and size! (\[size of frameSize])"

##### If the length of frameDurations and frames does not match:
 - "Mismatched frame duration (\[size of frameDurations]) and count! (\[size of frames])"

##### If colors is a table and the length of frameDurations and colors does not match:
 - "Mismatched frame count (\[size of frameCount]) and colors (\[size of colors])"

##### If frames is not a table or a string:
 - "frames must be a table or string, is a \[type of frames]"