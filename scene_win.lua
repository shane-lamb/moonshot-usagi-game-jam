local util = require "util"

local skip_time = 1.5

local function init()
  State = {
    timer = 0
  }
  sfx.play(SFX_WIN)
end

local function update(dt)
  State.timer += dt
  if (State.timer < skip_time) then
    return
  end
  
  if input.pressed(input.BTN1) then
    State.scene_to_init = SCENE_INTRO
  end
end

local function draw()
  gfx.clear(gfx.COLOR_DARK_BLUE)

  local text = { "YOU ARE OVER THE MOON", "", ""}
  if util.should_show_flash_text(skip_time, State.timer) then
      text[#text] = "YOU WIN!"
  end

  util.text_multiline_center(text, gfx.COLOR_WHITE)
end

return {
  init = init,
  update = update,
  draw = draw
}