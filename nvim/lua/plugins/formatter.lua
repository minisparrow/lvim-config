return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        h = { "clang-format" },
        hpp = { "clang-format" },
        python = { "autopep8" },
      },
      formatters = {
        ["clang-format"] = {
          prepend_args = { "--style=llvm" },
        },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
    },
  },
}
