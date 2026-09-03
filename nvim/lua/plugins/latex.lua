return {
  -- vimtex
  {
    "lervag/vimtex",
    ft = { "tex" },
    config = function()
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
      vim.g.vimtex_log_verbose = 1
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
          "-pdf",
          "-pdflatex=pdflatex --shell-escape -interaction=nonstopmode -synctex=1",
          "-verbose",
        },
      }
      vim.g.vimtex_quickfix_mode = 0

      vim.cmd([[
        function! s:write_server_name() abort
          let nvim_server_file = (has('win32') ? $TEMP : '/tmp') . '/vimtexserver.txt'
          call writefile([v:servername], nvim_server_file)
        endfunction
        augroup vimtex_common
          autocmd!
          autocmd FileType tex call s:write_server_name()
        augroup END
      ]])

      vim.g.tex_conceal = "abdmg"

      -- inkscape-figures
      vim.keymap.set("i", "<C-f>", function()
        local cmd = string.format(
          'silent exec ".!inkscape-figures create \\"%s\\" \\"%s/figures/\\""',
          vim.fn.getline("."),
          vim.b.vimtex.root
        )
        vim.cmd(cmd)
        vim.cmd("write")
      end, { noremap = true, silent = true, desc = "Create Inkscape figure" })

      vim.keymap.set("n", "<C-f>", function()
        local cmd = string.format(
          'silent exec "!inkscape-figures edit \\"%s/figures/\\" > /dev/null 2>&1 &"',
          vim.b.vimtex.root
        )
        vim.cmd(cmd)
        vim.cmd("redraw!")
      end, { noremap = true, silent = true, desc = "Edit Inkscape figure" })
    end,
  },

  { "KeitaNakamura/tex-conceal.vim", ft = { "tex" } },

  {
    "SirVer/ultisnips",
    ft = { "tex" },
    config = function()
      vim.g.UltiSnipsExpandTrigger = "<tab>"
      vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
      vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
      vim.g.UltiSnipsSnippetDirectories = { "~/.config/nvim/snippets" }
    end,
  },

  { "jbyuki/nabla.nvim", ft = { "tex", "markdown" } },
}
