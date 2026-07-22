local util = require "util"

local skip_time = 1

local function init(args)
  State = {
    timer = 0,
    lives_left = args.lives_left,
    wave = args.wave
  }
end

local function update(dt)
  State.timer += dt
  if (State.timer < skip_time) then
    return
  end
  
  if input.pressed(input.BTN1) then
    if State.lives_left > 0 then
      State.scene_to_init = SCENE_IN_GAME
      State.scene_init_args = {
        lives_left = State.lives_left,
        wave = State.wave
      }
    else
      State.scene_to_init = SCENE_INTRO
    end
  end
end

local function draw()
  gfx.clear(gfx.COLOR_RED)
  
  local text = { "YOU BIT THE MOON DUST", "", ""}
  if util.should_show_flash_text(skip_time, State.timer) then
      if State.lives_left > 0 then
        local life_text = State.lives_left > 1 and "lives" or "life"
        text[#text] = State.lives_left .. " " .. life_text .. " left"
      else
        text[#text] = "GAME OVER"
      end
  end

  util.text_multiline_center(text, gfx.COLOR_WHITE)
end

return {
  init = init,
  update = update,
  draw = draw
}