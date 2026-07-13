local util = require "util"

local update_player = (require "player").update
local create_player = (require "player").create
local update_spawner = (require "spawner").update
local create_spawner = (require "spawner").create
local update_bullets = (require "bullet").update
local update_enemies = (require "enemy").update

local function init()
  State = {
    spawner = create_spawner(),
    player = create_player(),
    enemies = {},
    bullets = {}
  }
  sfx.play(SFX_WAVE_START)
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

  gfx.rect_fill(0, 0, GAME_WIDTH, SPRITE_SIZE * 2, gfx.COLOR_BLACK)
  util.text_center_horizontal("WAVE " .. State.spawner.wave, 1, gfx.COLOR_WHITE)

  for i = 0, GAME_WIDTH - SPRITE_SIZE, SPRITE_SIZE do
    gfx.spr(7, i, SPRITE_SIZE)
  end

  local entities = get_entities_sorted()

  for _, entity in ipairs(entities) do
    if (entity.type == TYPE_BULLET) then
      gfx.circ_fill(entity.x + HALF_SPRITE_SIZE, entity.y + HALF_SPRITE_SIZE, 1, gfx.COLOR_RED)
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