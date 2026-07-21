local util = require "util"

local skip_time = 2

local function init()
  State = {
    timer = 0
  }
  music.loop("intro")
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
  gfx.clear(gfx.COLOR_BLACK)

  local text = { "MOONSHOT", "", "Moon robots are mean -", "but you are keen", "",  ""}
  if util.should_show_flash_text(skip_time, State.timer) then
      text[#text] = "Press button 1"
  end

  util.text_multiline_center(text, gfx.COLOR_WHITE)

  local offset = math.floor((State.timer * 4) % 4)
  local spr = SPR_MOON + offset
  gfx.spr(spr, 35, 14)
  gfx.spr(spr, 106, 14)
end

return {
  init = init,
  update = update,
  draw = draw
}