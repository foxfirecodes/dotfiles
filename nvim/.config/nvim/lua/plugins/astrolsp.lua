---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    formatting = {
      disabled = {
        -- conflicts with biome/prettier
        "vtsls",
      },
    },
    --- @diagnostic disable: missing-fields
    config = {
      -- the key is the server name to configure
      -- the value is the configuration table
      tailwindcss = {
        settings = {
          tailwindCSS = {
            classFunctions = { "cva", "cx" },
          },
        },
      },
    },
  },
}
