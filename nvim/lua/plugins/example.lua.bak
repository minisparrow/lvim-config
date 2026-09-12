return {
  -- catppuccin colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
    },
  },

  -- set colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- treesitter: extra language parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "c",
        "cpp",
        "dockerfile",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      })
    end,
  },

  -- presenting.nvim: markdown slides in neovim
  {
    "minisparrow/presenting.nvim",
    opts = {
      options = {
        width = 120,
        toc_width = 40,
        toc_gap = 6,
        toc_separator = "┃",
        toc_separator_highlight = "FloatBorder",
        toc_padding = 1,
        toc_bullet = "•",
      },
      separator = {
        markdown = "^---$",
      },
      keep_separator = false,
      keymaps = {
        ["l"] = nil,
        ["L"] = function() _G.Presenting.last() end,
        ["t"] = function() _G.Presenting.toggle_toc() end,
        ["e"] = function() _G.Presenting.goto_source() end,
        ["r"] = function() _G.Presenting.refresh_from_source() end,
        ["s"] = function() _G.Presenting.goto_slide_prompt() end,
        ["+"] = function() _G.Presenting.toc_wider(5) end,
        ["-"] = function() _G.Presenting.toc_narrower(5) end,
        [">"] = function() _G.Presenting.slide_wider(10) end,
      },
    },
    cmd = { "Presenting" },
    keys = {
      { "<leader>ms", "<cmd>Presenting<CR>", desc = "Start Presenting" },
    },
  },

  -- mason: extra tools
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "shellcheck",
      },
    },
  },
}
