-- .NET/C# development plugins ported from dotfiles-nvim

return {
  -- Roslyn LSP (C#/Razor support)
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
  },

  -- Solution explorer, NuGet management, and .NET tooling
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    ft = { "cs", "fsharp", "vb" },
    config = function()
      require("easy-dotnet").setup({
        test_runner = {
          enable = true,
        },
        picker = "telescope",
      })
    end,
  },

  -- .NET testing framework
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "Issafalcon/neotest-dotnet",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-dotnet"),
        },
      })
    end,
  },

  -- neotest-dotnet adapter
  {
    "Issafalcon/neotest-dotnet",
    lazy = false,
    dependencies = { "nvim-neotest/neotest" },
  },

  -- Debugging framework
  {
    "mfussenegger/nvim-dap",
    dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
    event = "VeryLazy",
    config = function()
      local dap = require("dap")
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg"

      local netcoredbg_adapter = {
        type = "executable",
        command = mason_path,
        args = { "--interpreter=vscode" },
      }

      dap.adapters.netcoredbg = netcoredbg_adapter
      dap.adapters.coreclr = netcoredbg_adapter

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch .NET Core App",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
        },
      }
    end,
  },

  -- DAP UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dapui = require("dapui")
      local dap = require("dap")

      -- Open/close UI automatically
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Breakpoint signs
      vim.fn.sign_define("DapBreakpoint", {
        text = "⚪",
        texthl = "DapBreakpointSymbol",
        linehl = "DapBreakpoint",
        numhl = "DapBreakpoint",
      })
      vim.fn.sign_define("DapStopped", {
        text = "🔴",
        texthl = "yellow",
        linehl = "DapBreakpoint",
        numhl = "DapBreakpoint",
      })
      vim.fn.sign_define("DapBreakpointRejected", {
        text = "⭕",
        texthl = "DapStoppedSymbol",
        linehl = "DapBreakpoint",
        numhl = "DapBreakpoint",
      })

      -- Minimal UI layout
      dapui.setup({
        expand_lines = true,
        controls = { enabled = false },
        floating = { border = "rounded" },
        render = {
          max_type_length = 60,
          max_value_lines = 200,
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 1.0 },
            },
            size = 15,
            position = "bottom",
          },
        },
      })
    end,
  },

  -- Code formatting with csharpier
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
        xml = { "xmlformat" },
        csproj = { "xmlformat" },
      },
      formatters = {
        csharpier = {
          command = "csharpier",
          args = { "format", "--write-stdout" },
          stdin = true,
        },
        xmlformat = {
          command = "xmlformat",
        },
      },
    },
  },

  -- Extend LazyVim's mason config with .NET tools
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.registries = opts.registries or {}
      vim.list_extend(opts.registries, {
        "github:mason-org/mason-registry",
        "github:crashdummyy/mason-registry",
      })
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "csharpier",
        "xmlformatter",
        "bicep-lsp",
        "netcoredbg",
      })
    end,
  },

  -- Treesitter with C# support
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c_sharp",
        "razor",
        "bicep",
        "lua",
        "vim",
        "vimdoc",
        "html",
        "css",
        "yaml",
      },
    },
  },

  -- LuaSnip with C# snippets
  {
    "L3MON4D3/LuaSnip",
    lazy = false,
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local fmt = require("luasnip.extras.fmt").fmt

      -- C# summary snippet
      ls.add_snippets("cs", {
        s(
          "/// summary",
          fmt(
            [[
///<summary>
/// {}
///</summary>
]],
            { i(1) }
          )
        ),
      })
    end,
  },
}
