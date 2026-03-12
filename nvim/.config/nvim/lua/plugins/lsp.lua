return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local function copy_to_clipboard(text)
        local ok = pcall(vim.fn.setreg, "+", text)
        if not ok then
          vim.fn.setreg('"', text)
        end
      end

      local function copy_line_diagnostic()
        local line = vim.api.nvim_win_get_cursor(0)[1] - 1
        local diagnostics = vim.diagnostic.get(0, { lnum = line })
        if not diagnostics or #diagnostics == 0 then
          vim.notify("No diagnostic on current line", vim.log.levels.INFO)
          return
        end
        copy_to_clipboard(diagnostics[1].message)
        vim.notify("Copied diagnostic message", vim.log.levels.INFO)
      end

      local function copy_buffer_diagnostics()
        local diagnostics = vim.diagnostic.get(0)
        if not diagnostics or #diagnostics == 0 then
          vim.notify("No diagnostics in current buffer", vim.log.levels.INFO)
          return
        end
        local messages = {}
        for _, d in ipairs(diagnostics) do
          table.insert(messages, d.message)
        end
        copy_to_clipboard(table.concat(messages, "\n"))
        vim.notify("Copied all diagnostics for current buffer", vim.log.levels.INFO)
      end

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
      })

      vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Line diagnostics" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show error at cursor" })
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics list" })
      vim.keymap.set("n", "<leader>ec", copy_line_diagnostic, { desc = "Copy line diagnostic" })
      vim.keymap.set("n", "<leader>ea", copy_buffer_diagnostics, { desc = "Copy all diagnostics (buffer)" })

      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr }

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
      end

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      pcall(function()
        require("mason").setup()
      end)

      local servers = {
        ts_ls = {},
        rust_analyzer = {},
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            },
          },
        },
      }

      for server, server_opts in pairs(servers) do
        local opts = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          on_attach = on_attach,
        }, server_opts)
        vim.lsp.config(server, opts)
        vim.lsp.enable(server)
      end

      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = {
          { name = "nvim_lsp" },
        },
      })
    end,
  },
}
