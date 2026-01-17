-- UI/UX enhancement plugins ported from dotfiles-nvim

return {
  -- Inline diagnostics (prettier than virtual text)
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup({
        signs = {
          left = "",
          right = "",
          diag = "●",
          arrow = "    ",
          up_arrow = "    ",
          vertical = " │",
          vertical_end = " └",
        },
        blend = {
          factor = 0.22,
        },
      })
      vim.diagnostic.config({ virtual_text = false })
    end,
  },

  -- Centerpad for focus mode
  { "smithbm2316/centerpad.nvim" },

  -- Git conflict resolution
  { "akinsho/git-conflict.nvim", version = "*", config = true },

  -- Comment.nvim for better commenting
  {
    "numToStr/Comment.nvim",
    lazy = false,
    opts = {
      toggler = {
        line = "gcc",
        block = "gbc",
      },
    },
    config = function(_, opts)
      require("Comment").setup(opts)

      -- Create toggle comment command
      vim.api.nvim_create_user_command("ToggleComment", function()
        require("Comment.api").toggle.linewise.current()
      end, {})
    end,
  },
}
