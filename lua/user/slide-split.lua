local M = {}

local function insert_sep(result)
  table.insert(result, "")
  table.insert(result, "---")
  table.insert(result, "")
end

local function is_table_line(line)
  return line:match("^%s*|") ~= nil
end

local function is_code_fence(line)
  return line:match("^%s*```") ~= nil
end

local function is_quote_line(line)
  return line:match("^%s*>") ~= nil
end

local function heading_level(line)
  local hashes = line:match("^(#+)%s")
  return hashes and #hashes or 0
end

local function strip_old_separators(lines)
  local cleaned = {}
  local in_code = false

  local fm_end = 0
  if lines[1] and lines[1]:match("^%-%-%-$") then
    for i = 2, #lines do
      if lines[i]:match("^%-%-%-$") then
        fm_end = i
        break
      end
    end
  end

  for i, line in ipairs(lines) do
    if i <= fm_end then
      table.insert(cleaned, line)
    elseif is_code_fence(line) then
      in_code = not in_code
      table.insert(cleaned, line)
    elseif in_code then
      table.insert(cleaned, line)
    elseif is_table_line(line) then
      table.insert(cleaned, line)
    elseif line:match("^%-%-%-$") then
      -- skip old separator
    else
      table.insert(cleaned, line)
    end
  end

  local result = {}
  for _, line in ipairs(cleaned) do
    local prev = result[#result]
    if not (line:match("^%s*$") and prev and prev:match("^%s*$")) then
      table.insert(result, line)
    end
  end
  return result
end

function M.split_slides()
  local buf = vim.api.nvim_get_current_buf()
  local raw_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local lines = strip_old_separators(raw_lines)
  local win_height = vim.api.nvim_win_get_height(0)
  -- Aggressive content per slide: multiply by 10 to drastically reduce page count
  -- For 1599 lines, this should give roughly 15-20 pages
  local max_lines = math.floor(win_height * 10)

  local start = 1
  if lines[1] and lines[1]:match("^%-%-%-$") then
    for i = 2, #lines do
      if lines[i]:match("^%-%-%-$") then
        start = i + 1
        break
      end
    end
  end

  local result = {}
  for i = 1, start - 1 do
    table.insert(result, lines[i])
  end

  local count = 0
  local i = start
  while i <= #lines do
    local line = lines[i]

    if is_code_fence(line) then
      local block = { line }
      i = i + 1
      while i <= #lines do
        table.insert(block, lines[i])
        if is_code_fence(lines[i]) then
          break
        end
        i = i + 1
      end
      
      -- Only separate block if it's large (more than 10 lines)
      if #block > 10 then
        if count > 0 then
          insert_sep(result)
        end
        for _, l in ipairs(block) do
          table.insert(result, l)
        end
        insert_sep(result)
        count = 0
      else
        -- Small block: merge with other content
        for _, l in ipairs(block) do
          table.insert(result, l)
          count = count + 1
        end
      end

    elseif is_table_line(line) then
      local block = { line }
      while i + 1 <= #lines and is_table_line(lines[i + 1]) do
        i = i + 1
        table.insert(block, lines[i])
      end
      
      -- Only separate table if it's large (more than 10 lines)
      if #block > 10 then
        if count > 0 then
          insert_sep(result)
        end
        for _, l in ipairs(block) do
          table.insert(result, l)
        end
        insert_sep(result)
        count = 0
      else
        -- Small table: merge with other content
        for _, l in ipairs(block) do
          table.insert(result, l)
          count = count + 1
        end
      end

    elseif is_quote_line(line) then
      local block = { line }
      while i + 1 <= #lines and is_quote_line(lines[i + 1]) do
        i = i + 1
        table.insert(block, lines[i])
      end
      
      -- Only separate quote if it's large (more than 10 lines)
      if #block > 10 then
        if count > 0 then
          insert_sep(result)
        end
        for _, l in ipairs(block) do
          table.insert(result, l)
        end
        insert_sep(result)
        count = 0
      else
        -- Small quote: merge with other content
        for _, l in ipairs(block) do
          table.insert(result, l)
          count = count + 1
        end
      end

    elseif line:match("^%s*$") then
      -- Empty lines don't count towards slide content
      table.insert(result, line)

    elseif heading_level(line) >= 1 then
      local level = heading_level(line)
      -- H1: start new slide
      if level == 1 then
        if count > 0 then
          insert_sep(result)
        end
        table.insert(result, line)
        count = 1
      else
        -- H2/H3: just add without forcing split
        if count >= max_lines then
          insert_sep(result)
          count = 0
        end
        table.insert(result, line)
        count = count + 1
      end

    else
      if count >= max_lines then
        insert_sep(result)
        count = 0
      end
      table.insert(result, line)
      count = count + 1
    end

    i = i + 1
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
  vim.api.nvim_win_set_cursor(0, cursor)
  vim.notify("Slide separators inserted", vim.log.levels.INFO)
end

return M
