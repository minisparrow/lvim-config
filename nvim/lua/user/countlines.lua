function CountLinesFromMark()
  local top_line = vim.fn.line("'a")
  local current_line = vim.fn.line(".")
  print(math.abs(current_line - top_line))
end

vim.api.nvim_create_user_command('CountLines', CountLinesFromMark, {})
