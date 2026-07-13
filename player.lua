local bullet = require "bullet"

local function create()
  return {
    x = MID_X,
    y = MID_Y,
    dir = 1,
    type = TYPE_PLAYER,
    reload_timer = 0
  }
end

local function update(dt)
  local player = State.player

  if input.held(input.LEFT) then
    player.x -= dt * PLAYER_SPEED
    player.dir = -1
  end
  if input.held(input.RIGHT) then
    player.x += dt * PLAYER_SPEED
    player.dir = 1
  end
  if input.held(input.UP) then
    player.y -= dt * PLAYER_SPEED
  end
  if input.held(input.DOWN) then
    player.y += dt * PLAYER_SPEED
  end

  player.x = util.clamp(player.x, MIN_X, MAX_X)
  player.y = util.clamp(player.y, MIN_Y, MAX_Y)

  player.reload_timer -= dt
  if input.held(input.BTN1) and player.reload_timer < 0 then
    bullet.shoot_from_entity(player)
    player.reload_timer = PLAYER_RELOAD_TIME
  end
end

return {
  update = update,
  create = create
}