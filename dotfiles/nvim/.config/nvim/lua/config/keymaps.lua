-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- Quick command mode
map("n", ";", ":", { desc = "Enter command mode" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("i", "<C-h>", "<C-w>", { desc = "Delete word backward" })

-- Buffer navigation
map("n", "<S-Tab>", ":b#<CR>", { desc = "Switch to previous buffer" })

-- DAP keymaps
map("n", "<F5>", function()
  require("dap").continue()
end, { desc = "DAP: Continue/Start" })
map("n", "<F9>", function()
  require("dap").toggle_breakpoint()
end, { desc = "DAP: Toggle breakpoint" })
map("n", "<F10>", function()
  require("dap").step_over()
end, { desc = "DAP: Step over" })
map("n", "<F11>", function()
  require("dap").step_into()
end, { desc = "DAP: Step into" })
map("n", "<F8>", function()
  require("dap").step_out()
end, { desc = "DAP: Step out" })
map("n", "<leader>dr", function()
  require("dap").repl.open()
end, { desc = "DAP: REPL open" })
map("n", "<leader>dl", function()
  require("dap").run_last()
end, { desc = "DAP: Run last" })

-- DAP UI keymaps
map("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "DAP UI toggle" })
map({ "n", "v" }, "<leader>dw", function()
  require("dapui").eval(nil, { enter = true })
end, { desc = "DAP Add to Watches" })
map({ "n", "v" }, "Q", function()
  require("dapui").eval()
end, { desc = "DAP Peek" })

-- Test debugging
map("n", "<leader>dt", function()
  require("neotest").run.run({ strategy = "dap" })
end, { desc = "Debug nearest test" })
map("n", "<F6>", function()
  require("neotest").run.run({ strategy = "dap" })
end, { desc = "Debug nearest test" })

-- LSP keymaps
map("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "LSP Go to Implementation" })
map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "LSP Signature help" })
map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "LSP Workspace add" })
map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "LSP Workspace remove" })
map("n", "<leader>wl", function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, { desc = "LSP Workspace list" })
map("n", "<leader>ra", vim.lsp.buf.rename, { desc = "LSP Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code action" })
map("v", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code action" })
map("n", "<F12>", vim.lsp.buf.definition, { desc = "LSP Definition" })

-- Comment toggle (Visual Studio style)
map("n", "<C-k>c", "<cmd>ToggleComment<CR>", { desc = "Toggle comment" })
map("n", "<C-k><C-c>", "<cmd>ToggleComment<CR>", { desc = "Toggle comment" })

-- Centerpad toggle
map("n", "<leader>z", function()
  require("centerpad").toggle({ leftpad = 22, rightpad = 22 })
end, { desc = "Toggle centerpad" })
