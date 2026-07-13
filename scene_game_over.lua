local util = require "util"

local skip_time = 1.5

local function init()
  State = {
    timer = 0
  }
end

local function update(dt)
  State.timer += dt
  if (State.timer < skip_time) then
    return
  end
  
  if input.pressed(input.BTN1) then
    State.scene_to_init = SCENE_IN_GAME
  end
end

local function draw()
  gfx.clear(gfx.COLOR_RED)
  
  local text = { "YOU BIT THE MOON DUST", "", ""}
  if util.should_show_flash_text(skip_time, State.timer) then
      text[#text] = "Press button 1"
  end

  util.text_multiline_center(text, gfx.COLOR_WHITE)
end

return {
  init = init,
  update = update,
  draw = draw
}