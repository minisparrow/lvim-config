local function FindVariableDefinition()
  local current_word = vim.fn.expand('<cword>')
  local pattern = "%" .. current_word
  vim.cmd('mark m')
  local current_pos = vim.fn.getpos('.')
  local result = vim.fn.search(pattern, 'bW')
  if result == 0 then
    print("No definition found for variable: %" .. current_word)
    vim.fn.setpos('.', current_pos)
  else
    vim.cmd('execute "normal! zz"')
  end
end

local function PreviewVariableDefinition()
  local current_word = vim.fn.expand('<cword>')
  local pattern = "%" .. current_word .. "\\>"
  local current_pos = vim.fn.getpos('.')
  vim.api.nvim_command("vimgrep /" .. pattern .. "/ %")
  vim.api.nvim_command("copen")
  vim.cmd('wincmd w')
  vim.fn.setpos('.', current_pos)
end

vim.keymap.set("n", "<leader>jj", FindVariableDefinition, { desc = "Jump to variable definition" })
vim.keymap.set("n", "<leader>kk", ":normal! `m<CR>", { desc = "Return to mark m" })
vim.keymap.set("n", "<leader>rr", PreviewVariableDefinition, { desc = "Preview variable references" })
