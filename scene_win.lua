local util = require "util"

local function init()
  State = {
    timer = 1.5
  }
  sfx.play(SFX_WIN)
end

local function update(dt)
  State.timer -= dt
  if (State.timer > 0) then
    return
  end
  
  if input.pressed(input.BTN1) then
    State.scene_to_init = SCENE_INTRO
  end
end

local function draw()
  gfx.clear(gfx.COLOR_DARK_BLUE)

  local text = { "YOU ARE OVER THE MOON" }
  if (State.timer < 0) then
    text[#text + 1] = ""
    text[#text + 1] = "YOU WIN!"
  end

  util.text_multiline_center(text, gfx.COLOR_WHITE)
end

return {
  init = init,
  update = update,
  draw = draw
}