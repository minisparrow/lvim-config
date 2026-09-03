return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "shellcheck",
        "pyright",
        "ruff",
        "debugpy",
        "clang-format",
      },
    },
  },
}
