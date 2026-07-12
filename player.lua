local bullet = require "bullet"

local function update(dt)
  if input.held(input.LEFT) then
    State.player.x -= dt * PLAYER_SPEED
    State.player.dir = -1
  end
  if input.held(input.RIGHT) then
    State.player.x += dt * PLAYER_SPEED
    State.player.dir = 1
  end
  if input.held(input.UP) then
    State.player.y -= dt * PLAYER_SPEED
  end
  if input.held(input.DOWN) then
    State.player.y += dt * PLAYER_SPEED
  end

  State.player.x = util.clamp(State.player.x, MIN_X, MAX_X)
  State.player.y = util.clamp(State.player.y, MIN_Y, MAX_Y)

  if input.pressed(input.BTN1) then
    bullet.shoot_from_entity(State.player)
  end
end

return {
  update = update
}