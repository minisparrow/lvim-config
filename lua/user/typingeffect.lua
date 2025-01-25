-- local M = {}
--
-- -- 打字效果函数
-- function M.type_file(interval)
--   interval = interval or 100 -- 每个字符的时间间隔，默认 100ms
--
--   -- 获取当前文件的内容
--   local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
--   local content = table.concat(lines, "\n") -- 将所有行拼接为字符串
--
--   -- 清空当前缓冲区
--   vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
--
--   local i = 1
--   local timer = vim.loop.new_timer()
--
--   -- 启动定时器逐个插入字符
--   timer:start(0, interval, vim.schedule_wrap(function()
--     if i <= #content then
--       local char = content:sub(i, i)                             -- 获取当前字符
--       vim.api.nvim_buf_set_text(0, 0, i - 1, 0, i - 1, { char }) -- 插入字符到缓冲区
--       vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, replacement)
--
--       i = i + 1
--     else
--       timer:stop() -- 完成后停止计时器
--       timer:close()
--     end
--   end))
-- end
--
-- return M

local M = {}

-- 打字机效果函数
function M.type_file(interval)
  interval = interval or 100 -- 默认每 100ms 插入一个字符

  -- 获取当前文件内容
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n") -- 将所有行拼接成一个字符串

  -- 清空缓冲区内容
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })

  local i = 1
  local timer = vim.loop.new_timer()

  -- 定时逐字符插入
  timer:start(0, interval, vim.schedule_wrap(function()
    if i <= #content then
      local char = content:sub(i, i)                     -- 逐个获取字符
      vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, { char }) -- 插入字符到缓冲区
      i = i + 1
    else
      timer:stop() -- 停止计时器
      timer:close()
    end
  end))
end

return M
