---@type LazySpec
return {
  {
    "folke/tokyonight.nvim",
    opts = { style = "night" },
  },
  {
    "axelvc/template-string.nvim",
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue" },
    config = function()
      require("template-string").setup({})
    end
  },
  {
    "rayzr522/diagnostic-filter.nvim",
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue" },
    config = function()
      require('diagnostic-filter').setup({
        diagnostic_filters = {
          ["eslint_d"] = { "^Error: No ESLint configuration found in .*$" }
        }
      })
    end
  },
  {
    "catgoose/vue-goto-definition.nvim",
    event = "BufReadPre",
    opts = {
      filters = {
        auto_imports = true,
        auto_components = true,
        import_same_file = true,
        declaration = true,
        duplicate_filename = true,
      },
      filetypes = { "vue", "typescript" },
      detection = {
        nuxt = function()
          return vim.fn.glob(".nuxt/") ~= ""
        end,
        vue3 = function()
          return vim.fn.filereadable("vite.config.ts") == 1 or vim.fn.filereadable("src/App.vue") == 1
        end,
        priority = { "nuxt", "vue3" },
      },
      lsp = {
        override_definition = true, -- override vim.lsp.buf.definition
      },
      debounce = 0
    }
  },
  -- {
  --   "danymat/neogen",
  --   config = function()
  --     require("neogen").setup({
  --       languages = {
  --         ["svelte"] = require("neogen.configurations.javascript")
  --       }
  --     })
  --   end
  -- },
}
