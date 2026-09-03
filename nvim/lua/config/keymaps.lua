-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- better up/down on wrapped lines
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

-- keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- keep cursor centered on search results
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- paste without losing register
map("x", "<leader>p", [["_dP]])

-- yank to system clipboard
map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

-- delete to void register
map({ "n", "v" }, "<leader>d", [["_d]])

-- quick save
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })

-- clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- visual block select
map("n", "<leader>v", "<C-v>", { desc = "Visual Block" })

-- buffer navigation
map("n", "<C-p>", ":bprevious<cr>", { desc = "Previous buffer" })
map("n", "<C-n>", ":bnext<cr>", { desc = "Next buffer" })
map("n", "<C-l>", ":echo expand('%:p')<cr>", { desc = "Show file path" })

-- autoscroll (requires neoscroll)
local autoscroll_ok, autoscroll = pcall(require, "user.autoscroll")
if autoscroll_ok then
  map("n", "<C-f>", function() autoscroll.start(500) end, { desc = "Start autoscroll" })
  map("n", "<C-b>", function() autoscroll.stop() end, { desc = "Stop autoscroll" })
end

-- markdown slides
map("n", "<leader>ml", function()
  local file = vim.fn.expand("%:p")
  vim.cmd("terminal slides '" .. file .. "'")
  vim.cmd("startinsert")
end, { desc = "Slides presentation" })

map("n", "<leader>mp", function()
  local file = vim.fn.expand("%:p")
  vim.cmd("terminal mdp '" .. file .. "'")
  vim.cmd("startinsert")
end, { desc = "MDP presentation" })

map("n", "<leader>md", function()
  require("user.slide-split").split_slides()
end, { desc = "Markdown split slides" })

-- osc52 yank (remote clipboard)
map("v", "<leader>y", function()
  local ok, osc52 = pcall(require, "osc52")
  if ok then
    osc52.copy_visual()
  else
    vim.cmd('normal! "+y')
  end
end, { desc = "Yank to clipboard" })

-- load user modules
require("user.clipboard")
require("user.searchword")
require("user.jump")
require("user.countlines")
require("user.depends-tree")
require("user.inkscape_figure")
