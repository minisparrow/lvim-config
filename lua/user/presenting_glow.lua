local M = {}
local TMP_FILE = "/tmp/presenting_glow_preview.md"
local GLOW_BUF = nil
local GLOW_WIN = nil

M.preview = function()
  -- 1. 检查环境
  if not _G.Presenting or not _G.Presenting._state then
    vim.notify("Not in Presenting mode", vim.log.levels.WARN)
    return
  end
  if vim.fn.executable("glow") == 0 then
    vim.notify("glow is not installed", vim.log.levels.ERROR)
    return
  end
  
  local content = _G.Presenting._state.slides[_G.Presenting._state.slide]
  if not content then return end

  -- 2. 写入临时文件 (覆盖写入，极快)
  local f = io.open(TMP_FILE, "w")
  f:write(content)
  f:close()

  -- 3. 复用窗口：如果窗口存在且有效，直接跳转；否则创建新窗口
  if GLOW_WIN and vim.api.nvim_win_is_valid(GLOW_WIN) then
    vim.api.nvim_set_current_win(GLOW_WIN)
  else
    vim.cmd("vsplit GlowPreview")
    GLOW_WIN = vim.api.nvim_get_current_win()
    GLOW_BUF = vim.api.nvim_get_current_buf()
  end

  local width = vim.api.nvim_win_get_width(GLOW_WIN)

  -- 4. 运行 Glow (复用缓冲区会自动覆盖旧内容)
  vim.fn.termopen({
    "glow", 
    "-s", "dark", 
    "-w", tostring(width), 
    TMP_FILE
  }, {
    on_exit = function() end
  })
  
  vim.cmd("stopinsert")
  
  -- 5. 绑定关闭快捷键
  local opts = { noremap = true, silent = true, buffer = GLOW_BUF }
  vim.keymap.set("n", "q", "<cmd>bd!<CR>", opts)
  vim.keymap.set("n", "<Esc>", "<cmd>bd!<CR>", opts)
end

return M
