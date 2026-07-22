local util = require "util"
local ParticleManager = require "particle_manager"

local update_player = (require "player").update
local create_player = (require "player").create
local update_spawner = (require "spawner").update
local create_spawner = (require "spawner").create
local update_bullets = (require "bullet").update
local update_enemies = (require "enemy").update

local function init(args)
  local wave = args and args.wave or 1
  local lives_left = args and args.lives_left or 3
  State = {
    spawner = create_spawner(wave),
    player = create_player(),
    enemies = {},
    bullets = {},
    time = 0,
    particles = {},
    lives_left = lives_left
  }
  sfx.play(SFX_WAVE_START)
  music.loop("ingame")
end

local function update(dt)
  State.time += dt
  update_spawner(dt)
  update_bullets(dt)
  update_player(dt)
  update_enemies(dt)
  ParticleManager.update(dt)
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

  gfx.rect_fill(0, 0, GAME_WIDTH, SPRITE_SIZE, gfx.COLOR_BLACK)
  -- wave #
  util.text_center_horizontal("WAVE " .. State.spawner.wave, 1, gfx.COLOR_WHITE)
  -- lives left
  for i = 1, State.lives_left, 1 do
    gfx.spr(SPR_HEART, GAME_WIDTH - 4 - (SPRITE_SIZE - 5) * i, 0)
  end
  -- death count
  gfx.spr(SPR_SKULL, 4, 0)
  gfx.text("" .. DeathCount, 17, 1, gfx.COLOR_WHITE)


  local sprite_offset = math.floor((State.time * 7) % 4)

  for i = 0, GAME_WIDTH - SPRITE_SIZE, SPRITE_SIZE do
    gfx.spr(SPR_WALL + sprite_offset, i, SPRITE_SIZE)
  end

  local entities = get_entities_sorted()
  for _, entity in ipairs(entities) do
    if entity.type == TYPE_BULLET then
      if entity.hurt_enemy then
        gfx.spr_ex(SPR_PLAYER_BULLET + sprite_offset, entity.x, entity.y, entity.dir == 1, false, 0, gfx.COLOR_TRUE_WHITE, 1.0)
      else
        gfx.spr_ex(SPR_ENEMY_BULLET + sprite_offset, entity.x, entity.y, entity.dir == 1, false, 0, gfx.COLOR_TRUE_WHITE, 1.0)
      end
      -- gfx.circ_fill(entity.x + HALF_SPRITE_SIZE, entity.y + HALF_SPRITE_SIZE, 1, gfx.COLOR_RED)
    elseif entity.type == TYPE_ENEMY then
      gfx.spr_ex(SPR_ENEMY + sprite_offset, entity.x, entity.y, entity.dir == 1, false, 0, gfx.COLOR_TRUE_WHITE, 1.0)
    elseif entity.type == TYPE_PLAYER then
      local spr_index = SPR_PLAYER
      if entity.moving then
        spr_index += sprite_offset
      end
      gfx.spr_ex(spr_index, entity.x, entity.y, entity.dir == 1, false, 0, gfx.COLOR_TRUE_WHITE, 1.0)  
    end
  end

  ParticleManager.draw()
end

return {
  init = init,
  update = update,
  draw = draw
}