SIDE_LEFT = 0
SIDE_RIGHT = 1
SIDE_BOTH = 2
SIDE_RANDOM = 3

local waves = {
  {
    steps = {
      { side = SIDE_LEFT, count = 3, delay = 0.5 },
      { delay = 5.0 },
      { side = SIDE_RIGHT, count = 3, delay = 0.5 }
    }
  },
  {
    steps = {
      { side = SIDE_BOTH, count = 3, delay = 0.5 },
      { delay = 5.0 },
      { side = SIDE_RANDOM, count = 10, delay = 1 }
    }
  },
  {
    steps = {
      { side = SIDE_BOTH, count = 4, delay = 0.8 },
      { delay = 6.0 },
      { side = SIDE_RANDOM, count = 15, delay = 1 }
    }
  }
}

local function spawn_enemy(single_side)
  table.insert(State.enemies, {
    x = single_side == SIDE_LEFT and ENEMY_MIN_X or ENEMY_MAX_X,
    y = math.random(MIN_Y, MAX_Y),
    dir = -1,
    type = TYPE_ENEMY,
    shoot_timer = math.random(),
    move_timer = 0,
    move_x = 0,
    move_y = 0
  })
end

local function spawn_for_step(step)
  local side = step.side
  if side == SIDE_RANDOM then
    side = math.random() < 0.5 and SIDE_LEFT or SIDE_RIGHT
  end
  if side == SIDE_LEFT or side == SIDE_BOTH then
    spawn_enemy(SIDE_LEFT)
  end
  if side == SIDE_RIGHT or side == SIDE_BOTH then
    spawn_enemy(SIDE_RIGHT)
  end
end

local function create(wave)
  return {
    wave = wave,
    step = 1,
    count = 0,
    timer = 0,
    intermission = false,
    intermission_count = 1,
  }
end

local function update_wave(spawner)
  local wave = waves[spawner.wave]

  if spawner.step > #wave.steps then
    if #State.enemies == 0 then
      if spawner.wave == #waves then
        State.scene_to_init = SCENE_WIN
        return
      end
      spawner.intermission = true
      spawner.timer = 0 -- needed as we were waiting for enemies to be killed
      -- we don't update wave or step yet, intermission will do this once over
    end
    return
  end
  local step = wave.steps[spawner.step]

  local step_count = step.count and step.count or 1
  if spawner.count == step_count then
    spawner.step += 1
    spawner.count = 0
    return
  end

  if (spawner.timer > step.delay) then
    spawn_for_step(step)
    spawner.timer = 0
    spawner.count += 1
  end
end

local function update_intermission(spawner)
    if spawner.timer < 1 then
      return
    end
    
    spawner.timer = 0
    spawner.count += 1

    if spawner.count > 3 then
      spawner.intermission = false
      spawner.count = 0

      spawner.wave += 1
      spawner.step = 1
      sfx.play(SFX_WAVE_START)
    else
      sfx.play(SFX_BEEP)
    end
end

local function update(dt)
  local spawner = State.spawner
  spawner.timer += dt
  if spawner.intermission then
    update_intermission(spawner)
  else
    update_wave(spawner)
  end
end

return {
  update = update,
  create = create
}