#!/usr/bin/env bash
# install-lazyvim.sh — Install LazyVim with dependencies, custom config, and LunarVim migrated plugins
# Usage: bash install-lazyvim.sh
set -euo pipefail

echo "=== LazyVim Installer (with LunarVim migration) ==="

# ── 1. Check / Install Neovim ────────────────────────────────────────────────
if ! command -v nvim &>/dev/null; then
    echo "--- Installing Neovim v0.11.2 ---"
    OS=$(uname -s)
    ARCH=$(uname -m)
    if [[ "$OS" == "Darwin" ]]; then
        # macOS: use Homebrew
        if command -v brew &>/dev/null; then
            brew install neovim
        else
            # manual install via tarball
            if [[ "$ARCH" == "arm64" ]]; then
                curl -LO https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-macos-arm64.tar.gz
                sudo rm -rf /opt/nvim-macos-arm64
                sudo tar -C /opt -xzf nvim-macos-arm64.tar.gz
                sudo ln -sf /opt/nvim-macos-arm64/bin/nvim /usr/local/bin/nvim
                rm -f nvim-macos-arm64.tar.gz
            else
                curl -LO https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-macos-x86_64.tar.gz
                sudo rm -rf /opt/nvim-macos-x86_64
                sudo tar -C /opt -xzf nvim-macos-x86_64.tar.gz
                sudo ln -sf /opt/nvim-macos-x86_64/bin/nvim /usr/local/bin/nvim
                rm -f nvim-macos-x86_64.tar.gz
            fi
        fi
    elif [[ "$OS" == "Linux" ]]; then
        if [[ "$ARCH" == "x86_64" ]]; then
            curl -LO https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz
            sudo rm -rf /opt/nvim-linux-x86_64
            sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
            sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
            rm -f nvim-linux-x86_64.tar.gz
        elif [[ "$ARCH" == "aarch64" ]]; then
            curl -LO https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-arm64.tar.gz
            sudo rm -rf /opt/nvim-linux-arm64
            sudo tar -C /opt -xzf nvim-linux-arm64.tar.gz
            sudo ln -sf /opt/nvim-linux-arm64/bin/nvim /usr/local/bin/nvim
            rm -f nvim-linux-arm64.tar.gz
        else
            echo "ERROR: Unsupported architecture $ARCH. Please install Neovim >= 0.11.2 manually."
            exit 1
        fi
    else
        echo "ERROR: Unsupported OS $OS. Please install Neovim >= 0.11.2 manually."
        exit 1
    fi
fi

NVIM_VERSION=$(nvim --version | head -1)
echo "[ok] $NVIM_VERSION detected"

# ── 2. Install dependencies ──────────────────────────────────────────────────
echo ""
echo "--- Installing dependencies ---"

if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq ripgrep fd-find git gcc make curl
elif command -v dnf &>/dev/null; then
    sudo dnf install -y ripgrep fd-find git gcc make curl
elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm ripgrep fd git gcc make curl
elif command -v brew &>/dev/null; then
    brew install ripgrep fd git lazygit
else
    echo "WARNING: Unknown package manager. Please install ripgrep, fd, git, gcc, make manually."
fi

# lazygit
if ! command -v lazygit &>/dev/null; then
    echo "--- Installing lazygit ---"
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  LAZYGIT_ARCH="x86_64" ;;
        aarch64) LAZYGIT_ARCH="arm64" ;;
        *)       echo "WARNING: Unsupported arch $ARCH for lazygit auto-install"; LAZYGIT_ARCH="" ;;
    esac
    if [[ -n "$LAZYGIT_ARCH" ]]; then
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
        sudo install /tmp/lazygit /usr/local/bin/
        rm -f /tmp/lazygit /tmp/lazygit.tar.gz
    fi
fi

echo "[ok] Dependencies installed"

# ── 3. Backup existing Neovim config ─────────────────────────────────────────
echo ""
echo "--- Backing up existing Neovim config ---"

backup_if_exists() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        local backup="${dir}.bak.$(date +%Y%m%d%H%M%S)"
        echo "  Backing up $dir -> $backup"
        mv "$dir" "$backup"
    fi
}

backup_if_exists "${HOME}/.config/nvim"
backup_if_exists "${HOME}/.local/share/nvim"
backup_if_exists "${HOME}/.local/state/nvim"
backup_if_exists "${HOME}/.cache/nvim"

echo "[ok] Backup complete"

# ── 4. Clone LazyVim starter ─────────────────────────────────────────────────
echo ""
echo "--- Cloning LazyVim starter template ---"

git clone https://github.com/LazyVim/starter "${HOME}/.config/nvim"
rm -rf "${HOME}/.config/nvim/.git"

echo "[ok] LazyVim starter cloned"

# ── 5. Write config files ────────────────────────────────────────────────────
echo ""
echo "--- Writing config files ---"

# ── config/options.lua ──
cat > "${HOME}/.config/nvim/lua/config/options.lua" << 'LUA'
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
LUA

# ── config/keymaps.lua ──
cat > "${HOME}/.config/nvim/lua/config/keymaps.lua" << 'LUA'
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
LUA

echo "[ok] config/ written"

# ── 6. Write plugin files ────────────────────────────────────────────────────
echo ""
echo "--- Writing plugin files ---"

# ── plugins/example.lua (base: colorscheme + treesitter + presenting + mason) ──
cat > "${HOME}/.config/nvim/lua/plugins/example.lua" << 'LUA'
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
LUA

# ── plugins/dap.lua ──
cat > "${HOME}/.config/nvim/lua/plugins/dap.lua" << 'LUA'
return {
  -- nvim-dap core
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap = require("dap")

      -- GDB adapter
      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "-i", "dap" },
      }

      -- codelldb adapter
      dap.adapters.codelldb = function(on_adapter)
        local tcp = vim.loop.new_tcp()
        tcp:bind("127.0.0.1", 0)
        local port = tcp:getsockname().port
        tcp:shutdown()
        tcp:close()

        local cmd
        local ok, registry = pcall(require, "mason-registry")
        if ok and registry.is_installed and registry.is_installed("codelldb") then
          local pkg = registry.get_package("codelldb")
          cmd = pkg:get_install_path() .. "/codelldb"
        else
          cmd = os.getenv("HOME") .. "/.config/lvim/codelldb-1.11.5/target/release/codelldb"
        end

        local stdout = vim.loop.new_pipe(false)
        local stderr = vim.loop.new_pipe(false)
        local handle, pid_or_err
        handle, pid_or_err = vim.loop.spawn(cmd, {
          stdio = { nil, stdout, stderr },
          args = {
            "--port", tostring(port),
            "--settings",
            '{"sourceLanguages":["cpp"],"expressions":"simple","showDisassembly":"never"}',
          },
        }, function(code)
          stdout:close()
          stderr:close()
          handle:close()
          if code ~= 0 then
            print("codelldb exited with code", code)
          end
        end)
        if not handle then
          vim.notify("Error running codelldb: " .. tostring(pid_or_err), vim.log.levels.ERROR)
          stdout:close()
          stderr:close()
          return
        end
        vim.notify("codelldb started. pid=" .. pid_or_err)
        stderr:read_start(function(err, chunk)
          assert(not err, err)
          if chunk then
            vim.schedule(function()
              require("dap.repl").append(chunk)
            end)
          end
        end)
        vim.defer_fn(function()
          on_adapter({ type = "server", host = "127.0.0.1", port = port })
        end, 500)
      end

      -- C/C++/Rust configurations
      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          runInTerminal = true,
          expressions = "simple",
          sourceLanguages = { "cpp" },
        },
        {
          name = "Launch with Python",
          type = "codelldb",
          request = "launch",
          program = "~/projs/triton-related/triton/venv-triton/bin/python3",
          args = function()
            local script = vim.fn.input("Path to Python script: ", vim.fn.getcwd() .. "/", "file")
            return { script }
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          runInTerminal = true,
        },
        {
          name = "Launch file with args (codelldb)",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          args = function()
            local input = vim.fn.input("Program arguments (space separated): ")
            return vim.split(input, "%s+", { trimempty = true })
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          runInTerminal = true,
        },
        {
          name = "Launch file with args (gdb)",
          type = "gdb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          args = function()
            local input = vim.fn.input("Program arguments (space separated): ")
            return vim.split(input, "%s+", { trimempty = true })
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          runInTerminal = true,
          stopAtBeginningOfMainSubprogram = false,
        },
        {
          name = "Debug with GDB",
          type = "gdb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          args = function()
            local input = vim.fn.input("Program arguments (space separated): ")
            return vim.split(input, "%s+", { trimempty = true })
          end,
          cwd = "${workspaceFolder}",
          stopAtBeginningOfMainSubprogram = false,
        },
      }
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp

      -- Python adapter
      dap.adapters.python = {
        type = "executable",
        command = "python3",
        args = { "-m", "debugpy.adapter" },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonpath = function()
            return "/usr/bin/python3"
          end,
        },
      }

      -- dap-python via Mason
      local mason_path = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/")
      pcall(function()
        require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python")
      end)
    end,
  },

  -- dap-ui
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            position = "right",
            size = 60,
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            position = "bottom",
            size = 10,
          },
          {
            elements = { { id = "console", size = 1 } },
            position = "bottom",
            size = 10,
          },
          {
            elements = { { id = "stacks", size = 1 } },
            position = "right",
            size = 60,
          },
          {
            elements = { { id = "repl", size = 1 } },
            position = "bottom",
            size = 10,
          },
          {
            elements = { { id = "watches", size = 1 } },
            position = "right",
            size = 60,
          },
        },
      })
    end,
  },

  -- dap virtual text
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {},
  },

  -- neotest
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = {
              justMyCode = false,
              console = "integratedTerminal",
            },
            args = { "--log-level", "DEBUG", "--quiet" },
            runner = "pytest",
          }),
        },
      })
    end,
    keys = {
      { "<leader>dm", function() require("neotest").run.run() end, desc = "Test Method" },
      { "<leader>dM", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test Method DAP" },
      { "<leader>df", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test File" },
      { "<leader>dF", function() require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" }) end, desc = "Test File DAP" },
      { "<leader>dS", function() require("neotest").summary.toggle() end, desc = "Test Summary" },
    },
  },
}
LUA

# ── plugins/latex.lua ──
cat > "${HOME}/.config/nvim/lua/plugins/latex.lua" << 'LUA'
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
LUA

# ── plugins/markdown-extra.lua ──
cat > "${HOME}/.config/nvim/lua/plugins/markdown-extra.lua" << 'LUA'
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
LUA

# ── plugins/clangd.lua ──
cat > "${HOME}/.config/nvim/lua/plugins/clangd.lua" << 'LUA'
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
LUA

# ── plugins/formatter.lua ──
cat > "${HOME}/.config/nvim/lua/plugins/formatter.lua" << 'LUA'
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
LUA

# ── plugins/tools.lua ──
cat > "${HOME}/.config/nvim/lua/plugins/tools.lua" << 'LUA'
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
LUA

# ── plugins/lsp.lua ──
cat > "${HOME}/.config/nvim/lua/plugins/lsp.lua" << 'LUA'
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
LUA

echo "[ok] plugins/ written"

# ── 7. Write user modules ────────────────────────────────────────────────────
echo ""
echo "--- Writing user modules ---"

mkdir -p "${HOME}/.config/nvim/lua/user"

# ── user/clipboard.lua ──
cat > "${HOME}/.config/nvim/lua/user/clipboard.lua" << 'LUA'
vim.opt.clipboard = "unnamedplus"

if vim.env.SSH_CONNECTION then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
else
  if vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1 then
    vim.g.clipboard = {
      name = "pbcopy",
      copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
      paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
      cache_enabled = true,
    }
  elseif vim.fn.executable("wl-copy") == 1 then
    vim.g.clipboard = {
      name = "wl-copy",
      copy = { ["+"] = "wl-copy", ["*"] = "wl-copy" },
      paste = { ["+"] = "wl-paste", ["*"] = "wl-paste" },
      cache_enabled = true,
    }
  elseif vim.fn.executable("xclip") == 1 then
    vim.g.clipboard = {
      name = "xclip",
      copy = { ["+"] = "xclip -selection clipboard", ["*"] = "xclip -selection primary" },
      paste = { ["+"] = "xclip -selection clipboard -o", ["*"] = "xclip -selection primary -o" },
      cache_enabled = true,
    }
  end
end
LUA

# ── user/searchword.lua ──
cat > "${HOME}/.config/nvim/lua/user/searchword.lua" << 'LUA'
local function vimgrep_and_open(keyword)
  local current_position = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_command("vimgrep /" .. keyword .. "/ %")
  vim.api.nvim_command("copen")
  vim.cmd("wincmd p")
  vim.api.nvim_win_set_cursor(0, current_position)
end

vim.keymap.set("n", "<leader>swk", function()
  local keyword = vim.fn.input("Keyword: ")
  if keyword ~= "" then
    vimgrep_and_open(keyword)
  else
    print("No keyword provided")
  end
end, { desc = "Search keyword in file" })

vim.keymap.set("n", "<leader>swc", function()
  local current_word = vim.fn.expand("<cword>")
  if current_word ~= "" then
    print("Current word: " .. current_word)
    vimgrep_and_open(current_word)
  else
    print("No word under cursor")
  end
end, { desc = "Search word under cursor" })

vim.keymap.set("n", "<leader>swg", function()
  local telescope_builtin = require('telescope.builtin')
  local word = vim.fn.expand("<cword>")
  telescope_builtin.live_grep({ default_text = word })
end, { desc = "Grep word under cursor" })

vim.keymap.set("n", "<S-s>", ":Telescope current_buffer_fuzzy_find<cr>", { desc = "Buffer fuzzy find" })
vim.keymap.set("n", "<S-f>", ":Telescope find_files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<S-g>", ":Telescope live_grep<cr>", { desc = "Live grep" })
LUA

# ── user/jump.lua ──
cat > "${HOME}/.config/nvim/lua/user/jump.lua" << 'LUA'
local function FindVariableDefinition()
  local current_word = vim.fn.expand('<cword>')
  local pattern = "%" .. current_word
  vim.cmd('mark m')
  local current_pos = vim.fn.getpos('.')
  local result = vim.fn.search(pattern, 'bW')
  if result == 0 then
    print("No definition found for variable: %" .. current_word)
    vim.fn.setpos('.', current_pos)
  else
    vim.cmd('execute "normal! zz"')
  end
end

local function PreviewVariableDefinition()
  local current_word = vim.fn.expand('<cword>')
  local pattern = "%" .. current_word .. "\\>"
  local current_pos = vim.fn.getpos('.')
  vim.api.nvim_command("vimgrep /" .. pattern .. "/ %")
  vim.api.nvim_command("copen")
  vim.cmd('wincmd w')
  vim.fn.setpos('.', current_pos)
end

vim.keymap.set("n", "<leader>jj", FindVariableDefinition, { desc = "Jump to variable definition" })
vim.keymap.set("n", "<leader>kk", ":normal! `m<CR>", { desc = "Return to mark m" })
vim.keymap.set("n", "<leader>rr", PreviewVariableDefinition, { desc = "Preview variable references" })
LUA

# ── user/countlines.lua ──
cat > "${HOME}/.config/nvim/lua/user/countlines.lua" << 'LUA'
function CountLinesFromMark()
  local top_line = vim.fn.line("'a")
  local current_line = vim.fn.line(".")
  print(math.abs(current_line - top_line))
end

vim.api.nvim_create_user_command('CountLines', CountLinesFromMark, {})
LUA

# ── user/depends-tree.lua ──
cat > "${HOME}/.config/nvim/lua/user/depends-tree.lua" << 'LUAEOF'
local M = {}

function M.parse_file()
  local start_pos = vim.api.nvim_buf_get_mark(0, 'c')
  local end_pos = vim.api.nvim_buf_get_mark(0, 'd')

  local buf = 0
  local line_count = vim.api.nvim_buf_line_count(buf)

  if start_pos[1] == 0 then
     start_pos = {1, 0}
  end

  if end_pos[1] == 0 then
     end_pos = {line_count, 0}
  end

  local lines = vim.api.nvim_buf_get_lines(buf, start_pos[1] - 1, end_pos[1], false)

  local definitions = {}

  for _, line in ipairs(lines) do
    local var, expr = line:match("^%s*(%%[%w_]+)%s*=%s*(.+)$")
    if var and expr then
      definitions[var] = expr
    end
  end
  return definitions
end

function M.find_dependencies(var, definitions)
  local deps = {}
  local visited = {}

  local function dfs(current)
    if visited[current] then return end
    visited[current] = true

    local expr = definitions[current]
    if expr then
      deps[current] = expr
      for dep in expr:gmatch("%%[%w_]+") do
        if not visited[dep] then
          dfs(dep)
        end
      end
    else
      deps[current] = "Definition not found"
    end
  end

  dfs(var)
  return deps
end

function M.get_variable_at_cursor()
  local line = vim.fn.getline('.')
  local col = vim.fn.col('.') - 1
  local start_col = col

  while start_col > 0 and line:sub(start_col, start_col):match("[%%%w_]") do
    start_col = start_col - 1
  end

  if line:sub(start_col + 1, start_col + 1) == "%" then
    local end_col = col
    while end_col <= #line and line:sub(end_col + 1, end_col + 1):match("[%w_]") do
      end_col = end_col + 1
    end
    return line:sub(start_col + 1, end_col)
  else
    return nil
  end
end

function M.format_dependencies(deps, var)
  local output = {}
  local printed_nodes = {}

  local function add_dep(current, prefix, is_last)
    local expr = deps[current]
    if expr then
      local node_prefix = prefix .. (is_last and "└─ " or "├─ ")

      if printed_nodes[current] then
        table.insert(output, node_prefix .. current .. " (*)")
        return
      end

      printed_nodes[current] = true

      table.insert(output, node_prefix .. current .. " = " .. expr)

      local child_deps = {}
      for dep in expr:gmatch("%%[%w_]+") do
        if deps[dep] then
          table.insert(child_deps, dep)
        end
      end

      for i, dep in ipairs(child_deps) do
        local new_prefix = prefix .. (is_last and "   " or "│  ")
        add_dep(dep, new_prefix, i == #child_deps)
      end
    end
  end
  add_dep(var, "", true)
  return output
end

function M.show_dependencies(opts)
  opts = opts or {}
  local definitions = M.parse_file()
  local var = M.get_variable_at_cursor()

  if var and var:match("^%%[%w_]+$") then
    local deps = M.find_dependencies(var, definitions)
    local output = M.format_dependencies(deps, var)

    vim.cmd("new")

    if opts.name then
      vim.api.nvim_buf_set_name(0, opts.name)
    else
      vim.api.nvim_buf_set_name(0, "Dependencies_" .. var)
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false
    vim.bo.filetype = "mlir"
  else
    print("No valid variable found at cursor position")
  end
end

vim.api.nvim_create_user_command("ShowDependencies", function(args)
  local opts = {}
  if args.args ~= "" then
    opts.name = args.args
  end
  M.show_dependencies(opts)
end, { nargs = '?' })

return M
LUAEOF

# ── user/autoscroll.lua ──
cat > "${HOME}/.config/nvim/lua/user/autoscroll.lua" << 'LUA'
local M = {}
local timer = nil

function M.start(interval)
  if timer then timer:stop() end

  timer = vim.loop.new_timer()
  timer:start(0, interval, vim.schedule_wrap(function()
    if vim.fn.line('.') >= vim.fn.line('$') then
      timer:stop()
    else
      require("neoscroll").scroll(1, true, interval)
    end
  end))
end

function M.stop()
  if timer then
    timer:stop()
    timer = nil
  end
end

return M
LUA

# ── user/slide-split.lua ──
cat > "${HOME}/.config/nvim/lua/user/slide-split.lua" << 'LUA'
local M = {}

local function insert_sep(result)
  table.insert(result, "")
  table.insert(result, "---")
  table.insert(result, "")
end

local function is_table_line(line)
  return line:match("^%s*|") ~= nil
end

local function is_code_fence(line)
  return line:match("^%s*```") ~= nil
end

local function heading_level(line)
  local hashes = line:match("^(#+)%s")
  return hashes and #hashes or 0
end

local function strip_old_separators(lines)
  local cleaned = {}
  local in_code = false

  local fm_end = 0
  if lines[1] and lines[1]:match("^%-%-%-$") then
    for i = 2, #lines do
      if lines[i]:match("^%-%-%-$") then
        fm_end = i
        break
      end
    end
  end

  for i, line in ipairs(lines) do
    if i <= fm_end then
      table.insert(cleaned, line)
    elseif is_code_fence(line) then
      in_code = not in_code
      table.insert(cleaned, line)
    elseif in_code then
      table.insert(cleaned, line)
    elseif is_table_line(line) then
      table.insert(cleaned, line)
    elseif line:match("^%-%-%-$") then
      -- skip old separator
    else
      table.insert(cleaned, line)
    end
  end

  local result = {}
  for _, line in ipairs(cleaned) do
    local prev = result[#result]
    if not (line:match("^%s*$") and prev and prev:match("^%s*$")) then
      table.insert(result, line)
    end
  end
  return result
end

function M.split_slides()
  local buf = vim.api.nvim_get_current_buf()
  local raw_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local lines = strip_old_separators(raw_lines)
  local win_height = vim.api.nvim_win_get_height(0)
  local max_lines = win_height - 2

  local start = 1
  if lines[1] and lines[1]:match("^%-%-%-$") then
    for i = 2, #lines do
      if lines[i]:match("^%-%-%-$") then
        start = i + 1
        break
      end
    end
  end

  local result = {}
  for i = 1, start - 1 do
    table.insert(result, lines[i])
  end

  local count = 0
  local i = start
  while i <= #lines do
    local line = lines[i]

    if is_code_fence(line) then
      local block = { line }
      i = i + 1
      while i <= #lines do
        table.insert(block, lines[i])
        if is_code_fence(lines[i]) then
          break
        end
        i = i + 1
      end
      if count > 0 then
        insert_sep(result)
      end
      for _, l in ipairs(block) do
        table.insert(result, l)
      end
      insert_sep(result)
      count = 0

    elseif is_table_line(line) then
      local block = { line }
      while i + 1 <= #lines and is_table_line(lines[i + 1]) do
        i = i + 1
        table.insert(block, lines[i])
      end
      if count > 0 then
        insert_sep(result)
      end
      for _, l in ipairs(block) do
        table.insert(result, l)
      end
      insert_sep(result)
      count = 0

    elseif line:match("^%s*$") then
      if count >= max_lines then
        table.insert(result, "---")
        table.insert(result, "")
        count = 0
      else
        table.insert(result, line)
        count = count + 1
      end

    elseif heading_level(line) >= 1 then
      local level = heading_level(line)
      if count > 0 then
        insert_sep(result)
      end
      table.insert(result, line)
      if level == 1 then
        insert_sep(result)
        count = 0
      else
        count = 1
      end

    else
      if count >= max_lines then
        insert_sep(result)
        count = 0
      end
      table.insert(result, line)
      count = count + 1
    end

    i = i + 1
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
  vim.notify("Slide separators inserted", vim.log.levels.INFO)
end

return M
LUA

# ── user/inkscape_figure.lua ──
cat > "${HOME}/.config/nvim/lua/user/inkscape_figure.lua" << 'LUA'
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

function list_figures()
  local i, t, popen = 0, {}, io.popen
  local pfile = popen([[inkscape-figures-manager list]])
  for filename in pfile:lines() do
    i = i + 1
    t[i] = filename
  end
  pfile:close()
  return t
end

function find_svg_figures()
  return finders.new_table({
    results = list_figures(),
  })
end

function M.inkscape_figures()
  pickers
      .new(require("telescope.themes").get_dropdown({}), {
        prompt_title = "Figures",
        finder = find_svg_figures(),
        sorter = conf.file_sorter(),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            vim.fn.system({ "inkscape-figures-manager", "edit", selection[1] })
          end)
          return true
        end,
      })
      :find()
end

vim.keymap.set(
  "i",
  "<C-d>",
  "<Esc><cmd>exec 'r!inkscape-figures-manager new -f -d figures -l \"'.getline('.').'\"'<CR>kkkkkkddjjjf{a"
)

return M
LUA

# ── user/debug-window.lua ──
cat > "${HOME}/.config/nvim/lua/user/debug-window.lua" << 'LUA'
local M = {}
local dap = require('dap')
local dapui = require('dapui')

function M.add_to_dap_watch()
  local word = vim.fn.expand("<cword>")
  dapui.elements.watches.add(word)
end

function M.toggle_element(element)
  dapui.toggle({ layout = element })
end

local function open_single_float_element(element)
  if element == "watch" then
    local word = vim.fn.expand("<cword>")
    dapui.elements.watches.add(word)
    dapui.float_element("watches", { width = 50, height = 20 })
  elseif element == "breakpoints" then
    dapui.float_element("breakpoints")
  elseif element == "scopes" then
    dapui.float_element("scopes")
  elseif element == "stacks" then
    dapui.float_element("stacks", { width = 50, height = 20 })
  end
end

vim.keymap.set("n", "<leader>dwo", function() dapui.toggle() end, { desc = "Toggle DAP UI" })
vim.keymap.set("n", "<leader>dwa", function() M.add_to_dap_watch() end, { desc = "Add to DAP watch" })
vim.keymap.set("n", "<leader>dw1", function() M.toggle_element(1) end, { desc = "Toggle DAP layout 1" })
vim.keymap.set("n", "<leader>dw2", function() M.toggle_element(2) end, { desc = "Toggle DAP layout 2" })
vim.keymap.set("n", "<leader>dw3", function() M.toggle_element(3) end, { desc = "Toggle DAP layout 3" })
vim.keymap.set("n", "<leader>dw4", function() M.toggle_element(4) end, { desc = "Toggle DAP layout 4" })
vim.keymap.set("n", "<leader>dw5", function() M.toggle_element(5) end, { desc = "Toggle DAP layout 5" })
vim.keymap.set("n", "<leader>dw6", function() M.toggle_element(6) end, { desc = "Toggle DAP layout 6" })
vim.keymap.set("n", "<leader>dfw", function() open_single_float_element('watch') end, { desc = "Float watches" })
vim.keymap.set("n", "<leader>dfb", function() open_single_float_element('breakpoints') end, { desc = "Float breakpoints" })
vim.keymap.set("n", "<leader>dfs", function() open_single_float_element('stacks') end, { desc = "Float stacks" })
vim.keymap.set("n", "<leader>dfc", function() open_single_float_element('scopes') end, { desc = "Float scopes" })

return M
LUA

echo "[ok] user/ modules written"

# ── 8. Bootstrap plugins ─────────────────────────────────────────────────────
echo ""
echo "--- Bootstrapping plugins (this may take a minute) ---"

nvim --headless "+Lazy! sync" +qa 2>&1 || true

echo ""
echo "[ok] LazyVim installation complete!"
echo ""
echo "Run 'nvim' to start. Press <Space> to see all keybindings."
echo "Run ':LazyHealth' inside Neovim to verify everything is working."
