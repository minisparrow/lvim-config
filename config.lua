-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
--
local plugins = {
  {
    -- latex, ultisnips
    "dylanaraps/wal",
    "KeitaNakamura/tex-conceal.vim",
    "SirVer/ultisnips",
    "lervag/vimtex", --latex 主要是这个， 其他两个可以不用
    "xuhdev/vim-latex-live-preview",
    "jbyuki/nabla.nvim",
    "liuchengxu/graphviz.vim",
    -- auto scroll
    {
      "karb94/neoscroll.nvim",
      config = function()
        require("neoscroll").setup({
          easing_function = nil, -- 缓动效果（可选）
        })
      end,
    },
    'godlygeek/tabular',
    {
      "preservim/vim-markdown",
      config = function()
        vim.g.vim_markdown_toc_autofit = 1
      end,

    },
    {
      "mzlogin/vim-markdown-toc",
      config = function()
        vim.g.vmt_auto_update_on_save = 1 -- 自动更新目录
        vim.g.vmt_dont_insert_fence = 1   -- 不插入围栏
      end,
    },
    -- {

    --   "ajorgensen/vim-markdown-toc",
    --     vim.g.mdtoc_starting_header_level = 1
    -- },

    -- 插件部分
    -- markdown
    {
      "toppair/peek.nvim",
      event = { "VeryLazy" },
      build = "deno task --quiet build:fast",
      -- deno install
      -- curl -fsSL https://deno.land/install.sh | sh
      config = function()
        require('peek').setup({
          auto_load = true,          -- 打开 Markdown 文件时自动加载预览
          close_on_bdelete = true,   -- 关闭缓冲区时自动关闭预览
          app = 'browser',           -- 使用系统默认浏览器
          theme = 'light',           -- 主题设置：'light' 或 'dark'
          filetype = { 'markdown' }, -- 启用预览的文件类型
        })

        vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
        vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
      end,
    },
    -- install without yarn or npm
    {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      ft = { "markdown" },
      build = function() vim.fn["mkdp#util#install"]() end,
    },
    "preservim/nerdtree",
    'kshenoy/vim-signature',
    'inkarkat/vim-mark',
    'inkarkat/vim-ingo-library',
    'junegunn/fzf',
    'junegunn/fzf.vim',
    'gyim/vim-boxdraw',
    'neovim/nvim-lspconfig',
    'simrat39/symbols-outline.nvim',
    'vim-airline/vim-airline',
    'vim-airline/vim-airline-themes',
    'godlygeek/tabular',
    'preservim/tagbar',
    "mfussenegger/nvim-dap-python",
    "nvim-neotest/neotest",
    "nvim-neotest/neotest-python",
    "nvim-neotest/nvim-nio",
    'mfussenegger/nvim-dap',
    "mfussenegger/nvim-dap-python",
    'theHamsta/nvim-dap-virtual-text',
    'rcarriga/nvim-dap-ui',
    "wbthomason/packer.nvim",
    "jose-elias-alvarez/null-ls.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter"
    -- jupyter notebook
    -- 'luk400/vim-jukit',
    -- "GCBallesteros/jupytext.nvim"
  },
  --   {
  --     "ggandor/lightspeed.nvim",
  --     event = "BufRead",
  --   },
  --   {
  --     "ggandor/leap.nvim",
  --     name = "leap",
  --     config = function()
  --       require("leap").add_default_mappings()
  --     end,
  --   },
}

local plugin_filetree = require('user.file-tree')
vim.list_extend(plugins, plugin_filetree.plugins)
local plugin_git = require("user.git")
vim.list_extend(plugins, plugin_git.plugins)

for mode, mappings in pairs(plugin_git.keybindings) do
  for key, cmd in pairs(mappings) do
    lvim.keys[mode][key] = cmd
  end
end
lvim.builtin.gitsigns.active = false

lvim.plugins = plugins


-- vim options
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
-- general
lvim.log.level = "info"
lvim.format_on_save = {
  enabled = true,
  pattern = "*.lua",
  timeout = 1000,
}

vim.g.python3_host_prog = "/opt/homebrew/bin/python3"
-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- -- Change theme settings
-- lvim.colorscheme = "habamax"
lvim.colorscheme = "tokyonight"

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- Automatically install missing parsers when entering buffer
lvim.builtin.treesitter.auto_install = true
lvim.builtin.which_key.mappings["dm"] = { "<cmd>lua require('neotest').run.run()<cr>",
  "Test Method" }
lvim.builtin.which_key.mappings["dM"] = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",
  "Test Method DAP" }
lvim.builtin.which_key.mappings["df"] = {
  "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>", "Test Class" }
lvim.builtin.which_key.mappings["dF"] = {
  "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", "Test Class DAP" }
lvim.builtin.which_key.mappings["dS"] = { "<cmd>lua require('neotest').summary.toggle()<cr>", "Test Summary" }
-- 添加清除所有断点的快捷键, conflict with dap debug continue
-- vim.api.nvim_set_keymap('n', '<leader>dc', ':lua require("dap").clear_breakpoints()<CR>',
--   { noremap = true, silent = true })

-- vim options
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.relativenumber = false

-- lifunc clipboard
-- 设置xclip复制到vim.g.clipboard
-- vim.opt.clipboard = "unnamedplus"
-- vim.opt.number = true
-- vim.g.clipboard = {
--   name = 'xclip',
--   copy = {
--     ['+'] = 'xclip -selection clipboard',
--     ['*'] = 'xclip -selection primary',
--   },
--   paste = {
--     ['+'] = 'xclip -selection clipboard -o',
--     ['*'] = 'xclip -selection primary -o',
--   },
--   cache_enabled = true,
-- }

vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.g.clipboard = {
  name = 'pbcopy',
  copy = {
    ['+'] = 'pbcopy',
    ['*'] = 'pbcopy',
  },
  paste = {
    ['+'] = 'pbpaste',
    ['*'] = 'pbpaste',
  },
  cache_enabled = true,
}


vim.opt.number = true
require("symbols-outline").setup()
local opts = {
  highlight_hovered_item = true,
  show_guides = true,
  auto_preview = false,
  position = 'right',
  relative_width = true,
  width = 25,
  auto_close = false,
  show_numbers = false,
  show_relative_numbers = false,
  -- show_symbol_details = true,
  preview_bg_highlight = 'Pmenu',
  autofold_depth = nil,
  auto_unfold_hover = true,
  fold_markers = { '', '' },
  wrap = false,
  keymaps = { -- These keymaps can be a string or a table for multiple keys
    close = { "<Esc>", "q" },
    goto_location = "<Cr>",
    focus_location = "o",
    hover_symbol = "<C-space>",
    toggle_preview = "K",
    rename_symbol = "r",
    code_actions = "a",
    fold = "h",
    unfold = "l",
    fold_all = "W",
    unfold_all = "E",
    fold_reset = "R",
  },
  lsp_blacklist = {},
  symbol_blacklist = {},
  symbols = {
    File = { icon = "", hl = "@text.uri" },
    Module = { icon = "", hl = "@namespace" },
    Namespace = { icon = "", hl = "@namespace" },
    Package = { icon = "", hl = "@namespace" },
    Class = { icon = "𝓒", hl = "@type" },
    Method = { icon = "ƒ", hl = "@method" },
    Property = { icon = "", hl = "@method" },
    Field = { icon = "", hl = "@field" },
    Constructor = { icon = "", hl = "@constructor" },
    Enum = { icon = "ℰ", hl = "@type" },
    Interface = { icon = "ﰮ", hl = "@type" },
    Function = { icon = "", hl = "@function" },
    Variable = { icon = "", hl = "@constant" },
    Constant = { icon = "", hl = "@constant" },
    String = { icon = "𝓐", hl = "@string" },
    Number = { icon = "#", hl = "@number" },
    Boolean = { icon = "⊨", hl = "@boolean" },
    Array = { icon = "", hl = "@constant" },
    Object = { icon = "⦿", hl = "@type" },
    Key = { icon = "🔐", hl = "@type" },
    Null = { icon = "NULL", hl = "@type" },
    EnumMember = { icon = "", hl = "@field" },
    Struct = { icon = "𝓢", hl = "@type" },
    Event = { icon = "🗲", hl = "@type" },
    Operator = { icon = "+", hl = "@operator" },
    TypeParameter = { icon = "𝙏", hl = "@parameter" },
    Component = { icon = "", hl = "@function" },
    Fragment = { icon = "", hl = "@constant" },
  },
}


--- func:  python code completion
require('lspconfig')
require('lspconfig').pyright.setup {}

-- lvim/config.lua

-- Ensure nvim-cmp is loaded and configured
local cmp = require 'cmp'

cmp.setup {
  -- Your nvim-cmp configuration
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
}

-- Treesitter configuration
require 'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
}

-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<C-p>"] = ":bprevious<cr>"
lvim.keys.normal_mode["<C-n>"] = ":bnext<cr>"
lvim.keys.normal_mode["<C-l>"] = ":echo expand('%:p')<cr>"
lvim.keys.normal_mode["<C-t>"] = ":SymbolsOutline<cr>"

lvim.builtin.treesitter.ensure_installed = {
  "python",
  "cpp",
  "c",
  "java",
  "lua",
  "vim",
  "vimdoc",
  "query",
  "markdown",
}
vim.opt_local.makeprg = "clang"
vim.api.nvim_set_keymap('n', '<Space>ne', ':NERDTreeToggle<CR>', { noremap = true, silent = true })

dapui = require('dapui')
dapui.setup({
  layouts = {
    --1. scope, breakpoints, stacks, watches
    {
      elements = { {
        id = "scopes",
        size = 0.25
      }, {
        id = "breakpoints",
        size = 0.25
      }, {
        id = "stacks",
        size = 0.25
      }, {
        id = "watches",
        size = 0.25
      } },
      position = "right",
      size = 60
    },
    --2. repl, console
    {
      elements = { {
        id = "repl",
        size = 0.5
      }, {
        id = "console",
        size = 0.5
      } },
      position = "bottom",
      size = 10
    },
    --3. stacks
    {
      elements = {
        {
          id = "stacks",
          size = 1
        }
      },
      position = "right",
      size = 60
    },
    --4. repl
    {
      elements = {
        {
          id = "repl",
          size = 1
        }
      },
      position = "bottom",
      size = 10
    },
    --5. watches
    {
      elements = {
        {
          id = "watches",
          size = 1
        }
      },
      position = "right",
      size = 60
    },
  },
})

vim.o.foldmethod = 'indent'
vim.o.foldlevel = 99    -- 默认展开所有折叠
vim.o.foldenable = true -- 启用代码折叠

require("user.searchword")
require("user.jump")
require("user.countlines")
require("user.depends-tree")
require("user.file-tree")
require("user.clangd-lsp")
require("user.lualine")
require("user.code-formatter")
require("user.debug-cpp")
require("user.debug-py")
require("user.debug-window")
require("user.latex")
require("user.buffer-tab-select")
require("user.inkscape_figure")
neoscroll = require('neoscroll')


vim.api.nvim_set_keymap('n', '<leader>gvc', ':GraphvizCompile<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gv', ':Graphviz<CR>', { noremap = true, silent = true })
-- autoscroll
lvim.keys.normal_mode["<leader>rol"] = function() neoscroll.scroll(20, true, 200) end

-- 引入自动滚动模块
local autoscroll = require("user.autoscroll")

-- 启动自动滚动
lvim.keys.normal_mode["<C-f>"] = function() autoscroll.start(500) end -- 每 200 毫秒滚动 1 行
-- 停止自动滚动
lvim.keys.normal_mode["<C-b>"] = function() autoscroll.stop() end
