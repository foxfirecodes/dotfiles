---@type LazySpec
return {
  {
    "folke/tokyonight.nvim",
    opts = { style = "night" },
  },
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
