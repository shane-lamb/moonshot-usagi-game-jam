local bullet = require "bullet"
local ParticleManager = require "particle_manager"

local function update_enemy(enemy, dt)
  if (enemy.hit) then
    sfx.play(SFX_EXPLOSION)
    ParticleManager.explosion(enemy.x + HALF_SPRITE_SIZE, enemy.y + HALF_SPRITE_SIZE)
    return true
  end

  enemy.move_timer -= dt

  local player = State.player
  local x_diff = player.x - enemy.x

  if (enemy.move_timer < 0) then
    local y_diff = player.y - enemy.y
    local x_diff_mag = math.abs(x_diff)

    -- move towards the player vertically
    enemy.move_y = (y_diff > 0 and 1 or -1) * ENEMY_SPEED

    -- face and move towards the player horizontally...
    enemy.dir = x_diff > 0 and 1 or -1
    -- ...except if "too close" to the player, then run away instead
    if x_diff_mag < ENEMY_RUN_FROM_PLAYER_DISTANCE then
      -- ...provided there's room to move away
      local breathing_space = math.abs(player.x - (x_diff < 0 and ENEMY_MAX_X or ENEMY_MIN_X))
      if breathing_space > ENEMY_RUN_FROM_PLAYER_DISTANCE then
        enemy.dir *= -1
      end
    end
    enemy.move_x = enemy.dir * ENEMY_SPEED

    enemy.move_timer = ENEMY_MIN_MOVE_TIME + math.random()
  end

  enemy.x += enemy.move_x * dt
  enemy.y += enemy.move_y * dt
  enemy.y = util.clamp(enemy.y, MIN_Y, MAX_Y)
  enemy.x = util.clamp(enemy.x, ENEMY_MIN_X, ENEMY_MAX_X)

  local facing_player = (x_diff > 0) == (enemy.dir > 0)
  -- since shoot timer only decreases when facing player,
  -- enemy will never waste a shot shooting away from the player
  if facing_player then
    enemy.shoot_timer -= dt
  end
  if enemy.shoot_timer < 0 then
    bullet.shoot_from_entity(enemy)
    enemy.shoot_timer = ENEMY_RELOAD_TIME
  end
end

local function update_enemies(dt)
  local enemies = State.enemies
  
  for i = #enemies, 1, -1 do
    local enemy = enemies[i]
    if update_enemy(enemy, dt) then
      table.remove(enemies, i)
    end
  end
end

return {
  update = update_enemies
}