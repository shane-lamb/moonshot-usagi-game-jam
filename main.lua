require "constants"

local scenes = {
  [SCENE_INTRO] = require "scene_intro",
  [SCENE_IN_GAME] = require "scene_in_game",
  [SCENE_GAME_OVER] = require "scene_game_over",
  [SCENE_WIN] = require "scene_win"
}

function _config()
  ---@type Usagi.Config
  return { name = "Moonshot", game_id = "com.usagiengine.MOONSHOT", game_height = GAME_HEIGHT, game_width = GAME_WIDTH }
end

function _init()
  -- Live reload preserves globals across saved edits but resets locals.
  -- Stash mutable game state in a capitalized global like `State` so it
  -- survives reloads; F5 calls _init again to reset.
  State = {
    scene_to_init = SCENE_INTRO
  }
  DeathCount = 0
end

function _update(dt)
  local scene_to_init = State.scene_to_init
  if scene_to_init then
    music.stop()
    scenes[scene_to_init].init(State.scene_init_args)
    State.scene = scene_to_init
  end

  scenes[State.scene].update(dt)
end

function _draw()
  scenes[State.scene].draw()
end