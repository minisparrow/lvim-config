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
