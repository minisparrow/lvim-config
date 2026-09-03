return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = { "clangd" },
          filetypes = { "c", "cpp", "objc", "objcpp" },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "compile_commands.json",
              "compile_flags.txt",
              ".git"
            )(fname)
          end,
        },
      },
    },
  },
}
