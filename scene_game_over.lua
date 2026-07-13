local util = require "util"

local function init()
  State = {
    timer = 1.5
  }
end

local function update(dt)
  State.timer -= dt
  if (State.timer > 0) then
    return
  end
  
  if input.pressed(input.BTN1) then
    State.scene_to_init = SCENE_IN_GAME
  end
end

local function draw()
  gfx.clear(gfx.COLOR_RED)

  local text = { "YOU BIT THE MOON DUST" }
  if (State.timer < 0) then
    text[#text + 1] = ""
    text[#text + 1] = "Press button 1"
  end

  util.text_multiline_center(text, gfx.COLOR_WHITE)
end

return {
  init = init,
  update = update,
  draw = draw
}