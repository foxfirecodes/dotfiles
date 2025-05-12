-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        "biome",
      },
    },
  },
  {
    -- yoinked from https://github.com/OneOfOne/dotfiles/blob/master/.config/nvim/lua/plugins/code.lua
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls").builtins
      opts.sources = { --override lazyvim's default sources
        -- ts
        nls.formatting.biome.with {
          filetypes = {
            "javascript",
            "javascriptreact",
            "json",
            "jsonc",
            "typescript",
            "typescriptreact",
            "css",
            "vue",
          },
          -- args = {
          --   'check',
          --   '--write',
          --   '--unsafe',
          --   '--formatter-enabled=true',
          --   '--organize-imports-enabled=true',
          --   '--skip-errors',
          --   '--stdin-file-path=$FILENAME',
          -- },
          condition = function(utils) return utils.root_has_file { "biome.json" } end,
        },
        nls.formatting.prettierd.with {
          condition = function(utils) return utils.root_has_file { ".prettierrc" } end,
        },
      }
      -- opts.debug = true
      return opts
    end,
  },
}
