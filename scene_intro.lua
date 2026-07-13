local util = require "util"

local function init()
  State = {
    timer = 2.5
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
  gfx.clear(gfx.COLOR_BLACK)

  local text = { "MOONSHOT", "", "Moon robots are mean -", "but you are keen", "",  ""}
  if (State.timer < 0) then
    text[#text] = "Press button 1"
  end

  util.text_multiline_center(text, gfx.COLOR_WHITE)

  gfx.spr(1, 35, 14)
  gfx.spr(1, 106, 14)
end

return {
  init = init,
  update = update,
  draw = draw
}