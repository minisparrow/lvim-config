return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
    keys = {
      { "<leader>rm", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle Render Markdown" },
    },
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },

  {
    "preservim/vim-markdown",
    dependencies = { "godlygeek/tabular" },
    ft = { "markdown" },
    config = function()
      vim.g.vim_markdown_toc_autofit = 1
    end,
  },

  {
    "mzlogin/vim-markdown-toc",
    ft = { "markdown" },
    config = function()
      vim.g.vmt_auto_update_on_save = 1
      vim.g.vmt_dont_insert_fence = 1
    end,
  },

  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown" },
    config = function()
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_corner_corner = "|"
      vim.g.table_mode_header_fillchar = "-"
    end,
    keys = {
      { "<leader>tm", "<cmd>TableModeToggle<CR>", desc = "Toggle Table Mode" },
      { "<leader>tr", "<cmd>TableModeRealign<CR>", desc = "Realign Table" },
    },
  },

  {
    "godlygeek/tabular",
    cmd = { "Tabularize" },
    keys = {
      { "<leader>ma", ":Tabularize /|<CR>", mode = { "n", "v" }, desc = "Align table" },
    },
  },

  {
    "ellisonleao/glow.nvim",
    cmd = { "Glow" },
    config = function()
      require("glow").setup({
        glow_path = vim.fn.exepath("glow"),
        width = 120,
        border = "single",
        style = "dark",
      })
    end,
    keys = {
      { "<leader>mg", "<cmd>Glow<CR>", desc = "Glow preview" },
    },
  },
}
