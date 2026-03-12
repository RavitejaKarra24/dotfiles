return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  config = function()
    local ok, conform = pcall(require, "conform")
    if not ok then
      vim.notify("conform.nvim failed to load", vim.log.levels.ERROR)
      return
    end

    conform.setup({
      formatters_by_ft = {
        html = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
      },
      formatters = {
        prettier = {
          condition = function(ctx)
            -- Prefer prettier if project has a config or package dependency.
            -- Use the context provided by conform; if unavailable, allow fallback.
            if not ctx or not ctx.bufnr then
              return true
            end
            local ok_info, info = pcall(conform.get_formatter_info, "prettier", ctx)
            if ok_info and info then
              return info.available
            end
            return true
          end,
        },
      },
      format_on_save = function(bufnr)
        local max_size = 1024 * 1024 -- 1MB safeguard
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == "" then
          return { lsp_fallback = true }
        end

        local stat = vim.loop.fs_stat(name)
        if stat and stat.size > max_size then
          return false
        end

        return { lsp_fallback = true }
      end,
    })

    vim.api.nvim_create_user_command("Format", function(args)
      local range
      if args.count ~= -1 then
        local start_line = args.line1
        local end_line = args.line2
        range = {
          start = { start_line - 1, 0 },
          ["end"] = { end_line, 0 },
        }
      end

      conform.format({ async = true, lsp_fallback = true, range = range })
    end, { range = true })

    vim.keymap.set({ "n", "v" }, "<leader>cf", function()
      conform.format({ async = false, lsp_fallback = true })
    end, { desc = "Format with Prettier" })
  end,
}
