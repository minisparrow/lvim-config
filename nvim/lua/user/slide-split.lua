
local M = {}

-- =========================
-- Configuration
-- =========================

-- 一个 slide 理想情况下的内容量
local TARGET_LINES = 38

-- 小于这个数量时，尽量不要因为 H2/H3 分页
local MIN_LINES = 24

-- 单个 block 超过这个数量，也允许它自己占一页
local MAX_LINES = 55


-- =========================
-- Helpers
-- =========================

local function insert_sep(result)
  table.insert(result, "")
  table.insert(result, "---")
  table.insert(result, "")
end


local function is_blank(line)
  return line:match("^%s*$") ~= nil
end


local function is_table_line(line)
  return line:match("^%s*|") ~= nil
end


local function is_code_fence(line)
  return line:match("^%s*```") ~= nil
end


local function heading_level(line)
  local hashes = line:match("^(#+)%s")
  return hashes and #hashes or 0
end


local function is_heading(line)
  return heading_level(line) > 0
end


-- =========================
-- Remove old separators
-- =========================

local function strip_old_separators(lines)

  local cleaned = {}
  local in_code = false

  -- YAML frontmatter
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

    -- YAML frontmatter 不处理
    if i <= fm_end then

      table.insert(cleaned, line)

    elseif is_code_fence(line) then

      in_code = not in_code
      table.insert(cleaned, line)

    elseif in_code then

      table.insert(cleaned, line)

    elseif line:match("^%-%-%-$") then

      -- 删除旧 separator

    else

      table.insert(cleaned, line)

    end
  end


  -- collapse blank lines
  local result = {}

  for _, line in ipairs(cleaned) do

    local prev = result[#result]

    if not (
      is_blank(line)
      and prev
      and is_blank(prev)
    ) then

      table.insert(result, line)

    end
  end

  return result
end


-- =========================
-- Parse markdown blocks
-- =========================

local function parse_blocks(lines, start)

  local blocks = {}

  local i = start

  while i <= #lines do

    local line = lines[i]

    -- ---------------------
    -- Code block
    -- ---------------------

    if is_code_fence(line) then

      local block = {
        type = "code",
        lines = {},
      }

      table.insert(block.lines, line)

      i = i + 1

      while i <= #lines do

        table.insert(block.lines, lines[i])

        if is_code_fence(lines[i]) then
          break
        end

        i = i + 1
      end

      table.insert(blocks, block)

    -- ---------------------
    -- Table
    -- ---------------------

    elseif is_table_line(line) then

      local block = {
        type = "table",
        lines = {},
      }

      while i <= #lines and is_table_line(lines[i]) do

        table.insert(block.lines, lines[i])

        i = i + 1
      end

      table.insert(blocks, block)

      goto continue

    -- ---------------------
    -- Heading
    -- ---------------------

    elseif is_heading(line) then

      local level = heading_level(line)

      table.insert(blocks, {
        type = "heading",
        level = level,
        lines = { line },
      })

    -- ---------------------
    -- Blank
    -- ---------------------

    elseif is_blank(line) then

      table.insert(blocks, {
        type = "blank",
        lines = { line },
      })

    -- ---------------------
    -- Normal paragraph/list
    -- ---------------------

    else

      local block = {
        type = "text",
        lines = {},
      }

      -- 连续普通文本作为一个 block
      while i <= #lines do

        local current = lines[i]

        if is_blank(current)
          or is_heading(current)
          or is_code_fence(current)
          or is_table_line(current)
        then
          break
        end

        table.insert(block.lines, current)

        i = i + 1
      end

      table.insert(blocks, block)

      goto continue

    end

    i = i + 1

    ::continue::
  end

  return blocks
end


-- =========================
-- Main
-- =========================

function M.split_slides()

  local buf = vim.api.nvim_get_current_buf()

  local raw_lines =
    vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local lines =
    strip_old_separators(raw_lines)


  -- -------------------------
  -- Find frontmatter
  -- -------------------------

  local start = 1

  if lines[1] and lines[1]:match("^%-%-%-$") then

    for i = 2, #lines do

      if lines[i]:match("^%-%-%-$") then

        start = i + 1
        break

      end
    end
  end


  -- -------------------------
  -- Parse blocks
  -- -------------------------

  local blocks =
    parse_blocks(lines, start)


  local result = {}

  -- 保留 YAML
  for i = 1, start - 1 do
    table.insert(result, lines[i])
  end


  local current_lines = 0
  local has_content = false


  local function add_block(block)

    for _, line in ipairs(block.lines) do
      table.insert(result, line)
    end

    current_lines =
      current_lines + #block.lines

    if block.type ~= "blank" then
      has_content = true
    end
  end


  local function new_slide()

    if has_content then
      insert_sep(result)
    end

    current_lines = 0
    has_content = false
  end


  -- =========================
  -- Smart pagination
  -- =========================

  for _, block in ipairs(blocks) do

    local size = #block.lines


    -- -------------------------
    -- H1
    -- -------------------------

    if block.type == "heading"
      and block.level == 1
    then

      -- H1 永远开始新 slide
      if has_content then
        new_slide()
      end

      add_block(block)


    -- -------------------------
    -- H2
    -- -------------------------

    elseif block.type == "heading"
      and block.level == 2
    then

      -- 当前内容已经比较满
      if current_lines >= MIN_LINES then
        new_slide()
      end

      add_block(block)


    -- -------------------------
    -- H3
    -- -------------------------

    elseif block.type == "heading"
      and block.level >= 3
    then

      -- H3 更宽松
      if current_lines >= TARGET_LINES then
        new_slide()
      end

      add_block(block)


    -- -------------------------
    -- Code / Table
    -- -------------------------

    elseif block.type == "code"
      or block.type == "table"
    then

      -- 如果当前已经接近满页，
      -- 并且这个 block 放不下，就移动到下一页
      if current_lines > 0
        and current_lines + size > TARGET_LINES
      then

        new_slide()

      end

      add_block(block)


      -- 如果单独一个 block 就很大，
      -- 不要再马上插入 separator。
      --
      -- 让下一个 block 来决定是否分页。


    -- -------------------------
    -- Normal text
    -- -------------------------

    else

      if current_lines > 0
        and current_lines + size > TARGET_LINES
      then

        new_slide()

      end

      add_block(block)

    end
  end


  -- =========================
  -- Remove trailing separator
  -- =========================

  while #result > 0
    and is_blank(result[#result])
  do
    table.remove(result)
  end

  if result[#result]
    and result[#result]:match("^%-%-%-$")
  then
    table.remove(result)
  end


  -- =========================
  -- Write back
  -- =========================

  local cursor =
    vim.api.nvim_win_get_cursor(0)

  vim.api.nvim_buf_set_lines(
    buf,
    0,
    -1,
    false,
    result
  )

  vim.api.nvim_win_set_cursor(
    0,
    cursor
  )

  vim.notify(
    "Smart slide separators inserted",
    vim.log.levels.INFO
  )
end


return M
