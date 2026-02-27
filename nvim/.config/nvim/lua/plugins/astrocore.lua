---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      tsdenofix = {
        event = { "LspAttach" },
        desc = "Fix ts_ls & deno lsp conflict",
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == "ts_ls" then
            local is_deno = not (vim.fn.findfile("deno.json", ".;") == "")
            if is_deno then client.stop() end
          end
        end,
      },
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
    },
  },
}
