local function vimgrep_and_open(keyword)
  local current_position = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_command("vimgrep /" .. keyword .. "/ %")
  vim.api.nvim_command("copen")
  vim.cmd("wincmd p")
  vim.api.nvim_win_set_cursor(0, current_position)
end

vim.keymap.set("n", "<leader>swk", function()
  local keyword = vim.fn.input("Keyword: ")
  if keyword ~= "" then
    vimgrep_and_open(keyword)
  else
    print("No keyword provided")
  end
end, { desc = "Search keyword in file" })

vim.keymap.set("n", "<leader>swc", function()
  local current_word = vim.fn.expand("<cword>")
  if current_word ~= "" then
    print("Current word: " .. current_word)
    vimgrep_and_open(current_word)
  else
    print("No word under cursor")
  end
end, { desc = "Search word under cursor" })

vim.keymap.set("n", "<leader>swg", function()
  local telescope_builtin = require('telescope.builtin')
  local word = vim.fn.expand("<cword>")
  telescope_builtin.live_grep({ default_text = word })
end, { desc = "Grep word under cursor" })

vim.keymap.set("n", "<S-s>", ":Telescope current_buffer_fuzzy_find<cr>", { desc = "Buffer fuzzy find" })
vim.keymap.set("n", "<S-f>", ":Telescope find_files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<S-g>", ":Telescope live_grep<cr>", { desc = "Live grep" })
