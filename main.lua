SPRITE_SIZE = 16
HALF_SPRITE_SIZE = SPRITE_SIZE / 2
QUARTER_SPRITE_SIZE = HALF_SPRITE_SIZE / 2
GAME_HEIGHT = 90
GAME_WIDTH = 160
MIN_X = 0
MAX_X = GAME_WIDTH - SPRITE_SIZE
MID_X = MIN_X + (MAX_X - MIN_X) / 2
MIN_Y = 16
MAX_Y = GAME_HEIGHT - SPRITE_SIZE
MID_Y = MIN_Y + (MAX_Y - MIN_Y) / 2

TYPE_PLAYER = 0
TYPE_ENEMY = 1
TYPE_BULLET = 2

PLAYER_SPEED = 30

ENEMY_SPEED = 20
ENEMY_RELOAD_TIME = 1.3
ENEMY_RUN_FROM_PLAYER_DISTANCE = 50
ENEMY_MIN_MOVE_TIME = 0.5 -- max move time is this plus 1 second

BULLET_SPEED = PLAYER_SPEED * 2
BULLET_LIFETIME = 2.5

SPAWNER_INITIAL_DELAY = 0.5
SPAWNER_DELAY = 2

function _config()
  ---@type Usagi.Config
  return { name = "Moonshot", game_id = "com.usagiengine.MOONSHOT", game_height = GAME_HEIGHT, game_width = GAME_WIDTH }
end

function _init()
  -- Live reload preserves globals across saved edits but resets locals.
  -- Stash mutable game state in a capitalized global like `State` so it
  -- survives reloads; F5 calls _init again to reset.
  State = {
    player = {
      x = MID_X,
      y = MID_Y,
      dir = 1,
      type = TYPE_PLAYER
    },
    enemies = {},
    bullets = {},
    spawn_timer = SPAWNER_INITIAL_DELAY
  }
end

local function shoot_bullet(entity)
  table.insert(State.bullets, {
    x = entity.x + entity.dir * HALF_SPRITE_SIZE,
    y = entity.y,
    time_left = BULLET_LIFETIME,
    dir = entity.dir,
    type = TYPE_BULLET,
    hurt_enemy = entity.type == TYPE_PLAYER
  })
end

local function update_spawner(dt)
  State.spawn_timer -= dt
  
  if State.spawn_timer > 0 then
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
  
  State.spawn_timer = SPAWNER_DELAY
end

local function update_player(dt)
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
    shoot_bullet(State.player)
  end
end

local function update_bullet(bullet, dt)
  bullet.time_left -= dt
  if bullet.time_left < 0 then
    return true
  end

  bullet.x += BULLET_SPEED * dt * bullet.dir

  -- damage entity if bullet collided
  local bullet_point = { x = bullet.x + HALF_SPRITE_SIZE, y = bullet.y + HALF_SPRITE_SIZE }
  local target_rect = { w = HALF_SPRITE_SIZE, h = HALF_SPRITE_SIZE }

  if bullet.hurt_enemy then
    for _, enemy in ipairs(State.enemies) do
      target_rect.x = enemy.x + QUARTER_SPRITE_SIZE
      target_rect.y = enemy.y + QUARTER_SPRITE_SIZE
      if util.point_in_rect(bullet_point, target_rect) then
        enemy.hit = true
        return true
      end
    end
    return
  end

  -- bullet is targetted at player
  target_rect.x = State.player.x + QUARTER_SPRITE_SIZE
  target_rect.y = State.player.y + QUARTER_SPRITE_SIZE
  if util.point_in_rect(bullet_point, target_rect) then
    -- player hit!
    return true
  end
end

local function update_bullets(dt)
  for i = #State.bullets, 1, -1 do
    local bullet = State.bullets[i]
    if update_bullet(bullet, dt) then
      table.remove(State.bullets, i)
    end
  end
end

local function update_enemy(enemy, dt)
  if (enemy.hit) then
    return true
  end
  
  enemy.move_timer -= dt

  local x_diff = State.player.x - enemy.x

  if (enemy.move_timer < 0) then
    local y_diff = State.player.y - enemy.y
    local x_diff_mag = math.abs(x_diff)

    -- move towards the player vertically
    enemy.move_y = (y_diff > 0 and 1 or -1) * ENEMY_SPEED

    -- face and move towards the player horizontally...
    enemy.dir = x_diff > 0 and 1 or -1
    -- ...except if "too close" to the player, then run away instead
    if (x_diff_mag < ENEMY_RUN_FROM_PLAYER_DISTANCE) then
      enemy.dir *= -1
    end
    enemy.move_x = enemy.dir * ENEMY_SPEED

    enemy.move_timer = ENEMY_MIN_MOVE_TIME + math.random()
  end

  enemy.x += enemy.move_x * dt
  enemy.y += enemy.move_y * dt
  enemy.y = util.clamp(enemy.y, MIN_Y, MAX_Y)
  enemy.x = util.clamp(enemy.x, MIN_X, MAX_X)

  local facing_player = (x_diff > 0) == (enemy.dir > 0)
  -- since shoot timer only decreases when facing player,
  -- enemy will never waste a shot shooting away from the player
  if facing_player then
    enemy.shoot_timer -= dt
  end
  if enemy.shoot_timer < 0 then
    shoot_bullet(enemy)
    enemy.shoot_timer = ENEMY_RELOAD_TIME
  end
end

local function update_enemies(dt)
  for i = #State.enemies, 1, -1 do
    local enemy = State.enemies[i]
    if update_enemy(enemy, dt) then
      table.remove(State.enemies, i)
    end
  end
end

function _update(dt)
  update_spawner(dt)
  update_bullets(dt)
  update_player(dt)
  update_enemies(dt)
end

local function get_entities_sorted()
    local num_enemies = #State.enemies
    local num_players = 1
    local num_bullets = #State.bullets
    local total_len = num_enemies + num_players
    
    local entities = table.create(total_len)
    
    -- shallow copy between arrays
    table.move(State.enemies, 1, num_enemies, 1, entities)
    table.move({ State.player }, 1, num_players, num_enemies + 1, entities)
    table.move(State.bullets, 1, num_bullets, num_enemies + num_players + 1, entities)

    -- sort by "y" value to get correct draw order
    table.sort(entities, function(a, b)
       return a.y < b.y   -- lowest y first
    end)
    
    return entities
end

function _draw(dt)
  gfx.clear(gfx.COLOR_LIGHT_GRAY)

  local entities = get_entities_sorted()

  for _, entity in ipairs(entities) do
    if (entity.type == TYPE_BULLET) then
      gfx.circ_fill(entity.x + HALF_SPRITE_SIZE, entity.y + HALF_SPRITE_SIZE, 1, gfx.COLOR_ORANGE)
    elseif (entity.type == TYPE_ENEMY) then
      gfx.spr_ex(2, entity.x, entity.y, entity.dir == 1, false, 0, gfx.COLOR_TRUE_WHITE, 1.0)
    elseif (entity.type == TYPE_PLAYER) then
      gfx.spr_ex(6, entity.x, entity.y, entity.dir == 1, false, 0, gfx.COLOR_TRUE_WHITE, 1.0)  
    end
  end
end