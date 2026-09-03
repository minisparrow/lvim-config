-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true

-- from LunarVim config
vim.opt.guifont = "Monaco:h12"
vim.opt.encoding = "utf-8"
vim.opt.ambiwidth = "single"
vim.opt.listchars = { tab = '▸ ', trail = '·', extends = '❯', precedes = '❮', nbsp = '␣' }
vim.opt.fillchars = { vert = '│', fold = '·', diff = '·' }
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""
vim.opt.number = true
vim.o.foldmethod = "manual"
vim.o.foldenable = false
