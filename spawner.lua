local function create()
  return {
    wave = 1,
    timer = SPAWNER_INITIAL_DELAY
  }
end

local function update(dt)
  local spawner = State.spawner

  spawner.timer -= dt
  
  if spawner.timer > 0 then
    return
  end

  -- 50% chance of spawning on left or right edge of screen
  local x = MIN_X
  if math.random() < 0.5 then
    x = MAX_X
  end

  table.insert(State.enemies, {
    x = x,
    y = math.random(MIN_Y, MAX_Y),
    dir = -1,
    type = TYPE_ENEMY,
    shoot_timer = 0.5 + math.random() / 2,
    move_timer = 0,
    move_x = 0,
    move_y = 0
  })
  
  spawner.timer = SPAWNER_DELAY
end

return {
  update = update,
  create = create
}