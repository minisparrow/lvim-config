return {
  -- neoscroll: smooth scrolling
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup({
        easing_function = nil,
      })
    end,
  },

  -- diffview: git diff viewer
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  },

  -- osc52: remote clipboard
  { "ojroques/nvim-osc52" },

  -- graphviz
  {
    "liuchengxu/graphviz.vim",
    cmd = { "Graphviz", "GraphvizCompile" },
    keys = {
      { "<leader>gvc", ":GraphvizCompile<CR>", desc = "Graphviz compile" },
      { "<leader>gv", ":Graphviz<CR>", desc = "Graphviz preview" },
    },
  },

  -- toggleterm: terminal management
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "horizontal",
        close_on_exit = true,
        shell = "zsh",
        dir = vim.fn.getcwd(),
        float_opts = {
          border = "curved",
          winblend = 0,
        },
      })
    end,
    keys = {
      { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Vertical terminal" },
      { "<leader>t1", "<cmd>1ToggleTerm<CR>", desc = "Terminal 1" },
      { "<leader>t2", "<cmd>2ToggleTerm<CR>", desc = "Terminal 2" },
      { "<leader>t3", "<cmd>3ToggleTerm<CR>", desc = "Terminal 3" },
      { "<leader>ts", "<cmd>TermSelect<CR>", desc = "Select terminal" },
    },
  },

  -- fff.nvim: fast file finder
  {
    "dmtrKovalenko/fff.nvim",
    enabled = vim.fn.has("nvim-0.10") == 1,
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    opts = {
      debug = {
        enabled = true,
        show_scores = true,
      },
    },
    lazy = false,
    keys = {
      { "ff", function() require("fff").find_files() end, desc = "FFFind files" },
      { "fg", function() require("fff").live_grep() end, desc = "FFF live grep" },
      { "fz", function() require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } }) end, desc = "FFF fuzzy grep" },
      { "fc", function() require("fff").live_grep({ query = vim.fn.expand("<cword>") }) end, desc = "FFF search word" },
    },
  },

  -- symbols-outline
  {
    "simrat39/symbols-outline.nvim",
    cmd = { "SymbolsOutline" },
    config = function()
      require("symbols-outline").setup({
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = "right",
        relative_width = true,
        width = 25,
        auto_close = false,
        show_numbers = false,
        show_relative_numbers = false,
        preview_bg_highlight = "Pmenu",
        auto_unfold_hover = true,
        wrap = false,
        keymaps = {
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
      })
    end,
    keys = {
      { "<C-t>", "<cmd>SymbolsOutline<CR>", desc = "Symbols Outline" },
      { "<leader>mt", "<cmd>SymbolsOutline<CR>", desc = "Symbols Outline" },
    },
  },

  -- vim-mark: multi-color word highlighting
  {
    "inkarkat/vim-mark",
    dependencies = { "inkarkat/vim-ingo-library" },
  },

  -- boxdraw: draw boxes in visual block mode
  { "gyim/vim-boxdraw" },

  -- vim-signature: show marks in sign column
  { "kshenoy/vim-signature" },

  -- tagbar
  {
    "preservim/tagbar",
    cmd = { "TagbarToggle" },
  },
}
