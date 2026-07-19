-- from https://book.usagiengine.com/recipes/particles.html

local ParticleManager = {}

-- Trigger an explosion at the specified location. `num` is how many circles to spawn, defaults to 12.
function ParticleManager.explosion(x, y, num)
  num = num or 12
  ParticleManager.spawn(x, y, {
    num = num,
    colors = { gfx.COLOR_WHITE, gfx.COLOR_YELLOW, gfx.COLOR_RED, gfx.COLOR_ORANGE, gfx.COLOR_PEACH },
    speed_range = { 50, 75 },
    angle_range = { 0, 360 },
    lifetime_range = { 0.15, 0.6 },
    radius_range = { 4, 8 },
  })
end

function ParticleManager.spawn(x, y, opts)
  for i = 1, opts.num do
    local angle_start = opts.angle_range[1]
    local angle_end = opts.angle_range[2] or angle_start
    local angle_rand = 0
    if angle_start ~= angle_end then
      angle_rand = math.random() / 2
      if math.random() < 0.5 then
        angle_rand *= -1
      end
    end
    local lifetime = math.random() * (opts.lifetime_range[2] - opts.lifetime_range[1]) + opts.lifetime_range[1]

    table.insert(State.particles, {
      angle = angle_rand + math.rad(angle_start + (i * ((angle_end - angle_start) / opts.num))),
      color = opts.colors[math.random(1, #opts.colors)],
      speed = math.random(opts.speed_range[1], opts.speed_range[2]),
      r = math.random(opts.radius_range[1], opts.radius_range[2]),
      lifetime = lifetime,
      life = lifetime,
      x = x,
      y = y,
    })
  end
end

function ParticleManager.update(dt)
  for i = #State.particles, 1, -1 do
    local particle = State.particles[i]
    particle.life -= dt

    if particle.life > 0 then
      particle.x += math.cos(particle.angle) * particle.speed * dt
      particle.y += math.sin(particle.angle) * particle.speed * dt
    else
      table.remove(State.particles, i)
    end
  end
end

function ParticleManager.draw()
  for _, particle in ipairs(State.particles) do
    local r = particle.r * (particle.life / particle.lifetime)
    if r >= 0.5 then
      gfx.circ_fill(particle.x, particle.y, r, particle.color)
    end
  end
end

return ParticleManager
