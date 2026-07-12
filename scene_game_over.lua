local function init()
  State = {
    timer = 2.5
  }
end

local function update(dt)
  State.timer -= dt
  if (State.timer < 0) then
    State.scene_to_init = SCENE_IN_GAME
  end
end

local function draw()
  gfx.clear(gfx.COLOR_RED)

  -- game over text
  local y = GAME_HEIGHT / 2 - 6
  local color = gfx.COLOR_WHITE
  local half_width = GAME_WIDTH / 2
  gfx.text("YOU BITE THE MOON DUST", half_width - 66, y, color)
end

return {
  init = init,
  update = update,
  draw = draw
}