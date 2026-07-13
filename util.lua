local function text_center_horizontal(text, y, color)
  local text_width = #text * CHAR_WIDTH
  gfx.text(text, (GAME_WIDTH - text_width) / 2, y, color)
end

local function text_center(text, color)
  text_center_horizontal(text, (GAME_HEIGHT - CHAR_HEIGHT) / 2, color)
end

local function text_multiline_center(text_lines, color)
  local total_height = #text_lines * CHAR_HEIGHT
  local start_height = (GAME_HEIGHT - total_height) / 2

  for index, text in ipairs(text_lines) do
    text_center_horizontal(text, start_height + CHAR_HEIGHT * (index - 1), color)
  end
end

local function should_show_flash_text(initial_wait, time_elapsed)
  local time = time_elapsed - initial_wait
  if time < 0 then
    return false
  end
  return time % FLASH_TEXT_TIME * 2 < FLASH_TEXT_TIME
end

return {
  text_center_horizontal = text_center_horizontal,
  text_center = text_center,
  text_multiline_center = text_multiline_center,
  should_show_flash_text = should_show_flash_text
}