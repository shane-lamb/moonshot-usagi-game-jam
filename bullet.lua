local function shoot_from_entity(entity)
  sfx.play(SFX_SHOOT)
  table.insert(State.bullets, {
    -- minus 1 to half sprite size makes bullet start a little closer to shooter
    x = entity.x + entity.dir * (HALF_SPRITE_SIZE - 1),
    y = entity.y,
    time_left = BULLET_LIFETIME,
    dir = entity.dir,
    type = TYPE_BULLET,
    hurt_enemy = entity.type == TYPE_PLAYER
  })
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
    sfx.play(SFX_HIT)
    State.scene_to_init = SCENE_GAME_OVER
    State.scene_init_args = {
      lives_left = State.lives_left - 1,
      wave = State.spawner.wave
    }
    return true
  end
end

local function update_bullets(dt)
  local bullets = State.bullets

  for i = #bullets, 1, -1 do
    local bullet = bullets[i]
    if update_bullet(bullet, dt) then
      table.remove(bullets, i)
    end
  end
end

return {
  shoot_from_entity = shoot_from_entity,
  update = update_bullets
}