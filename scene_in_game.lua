
local update_player = (require "player").update
local update_bullets = (require "bullet").update
local update_enemies = (require "enemy").update

local function init()
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
  sfx.play(SFX_WAVE_START)
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

local function update(dt)
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

local function draw()
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

return {
  init = init,
  update = update,
  draw = draw
}