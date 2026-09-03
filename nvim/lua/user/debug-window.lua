local M = {}
local dap = require('dap')
local dapui = require('dapui')

function M.add_to_dap_watch()
  local word = vim.fn.expand("<cword>")
  dapui.elements.watches.add(word)
end

function M.toggle_element(element)
  dapui.toggle({ layout = element })
end

local function open_single_float_element(element)
  if element == "watch" then
    local word = vim.fn.expand("<cword>")
    dapui.elements.watches.add(word)
    dapui.float_element("watches", { width = 50, height = 20 })
  elseif element == "breakpoints" then
    dapui.float_element("breakpoints")
  elseif element == "scopes" then
    dapui.float_element("scopes")
  elseif element == "stacks" then
    dapui.float_element("stacks", { width = 50, height = 20 })
  end
end

vim.keymap.set("n", "<leader>dwo", function() dapui.toggle() end, { desc = "Toggle DAP UI" })
vim.keymap.set("n", "<leader>dwa", function() M.add_to_dap_watch() end, { desc = "Add to DAP watch" })
vim.keymap.set("n", "<leader>dw1", function() M.toggle_element(1) end, { desc = "Toggle DAP layout 1" })
vim.keymap.set("n", "<leader>dw2", function() M.toggle_element(2) end, { desc = "Toggle DAP layout 2" })
vim.keymap.set("n", "<leader>dw3", function() M.toggle_element(3) end, { desc = "Toggle DAP layout 3" })
vim.keymap.set("n", "<leader>dw4", function() M.toggle_element(4) end, { desc = "Toggle DAP layout 4" })
vim.keymap.set("n", "<leader>dw5", function() M.toggle_element(5) end, { desc = "Toggle DAP layout 5" })
vim.keymap.set("n", "<leader>dw6", function() M.toggle_element(6) end, { desc = "Toggle DAP layout 6" })
vim.keymap.set("n", "<leader>dfw", function() open_single_float_element('watch') end, { desc = "Float watches" })
vim.keymap.set("n", "<leader>dfb", function() open_single_float_element('breakpoints') end, { desc = "Float breakpoints" })
vim.keymap.set("n", "<leader>dfs", function() open_single_float_element('stacks') end, { desc = "Float stacks" })
vim.keymap.set("n", "<leader>dfc", function() open_single_float_element('scopes') end, { desc = "Float scopes" })

return M
