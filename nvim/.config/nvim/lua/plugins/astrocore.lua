---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      quickfix_close_on_select = {
        {
          -- trigger on entering quickfix filetype buffer
          event = "FileType",
          pattern = "qf",
          desc = "Set 'o' to select item and close quickfix",
          callback = function(args)
            -- Set buffer-local keymap for 'o'
            vim.keymap.set("n", "o", "<CR>:cclose<CR>", {
              buffer = args.buf,
              desc = "Select and close quickfix",
              remap = true,
            })
          end,
        },
      },
      markdown_wrap = {
        {
          event = "FileType",
          pattern = "markdown",
          desc = "Enable wrap in markdown files",
          callback = function() vim.opt_local.wrap = true end,
        },
      },
    },
  },
}
