-- Custom plugin configurations
-- Add your plugin specs here to extend or override LazyVim defaults

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      show_end_of_buffer = true,
      float = {
        transparent = true,
      },
      integrations = {
        gitsigns = {
          enabled = true,
          transparent = true,
        },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
