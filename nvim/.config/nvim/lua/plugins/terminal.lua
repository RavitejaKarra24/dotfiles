return {
  "nvim-lua/plenary.nvim",
  config = function()
    local run_commands = {
      javascript = "node %s",
      typescript = "bun run %s",
      python = "python3 %s",
      rust = "cargo run",
      go = "go run %s",
      c = "gcc %s -o /tmp/c_out && /tmp/c_out",
      cpp = "g++ %s -o /tmp/cpp_out && /tmp/cpp_out",
      lua = "lua %s",
      sh = "bash %s",
      bash = "bash %s",
      zsh = "zsh %s",
      ruby = "ruby %s",
      java = "javac %s && java %s",
    }

    local function run_file()
      local ft = vim.bo.filetype
      local template = run_commands[ft]
      if not template then
        vim.notify("No run command for filetype: " .. ft .. "\nAdd one to run_commands in terminal.lua", vim.log.levels.WARN)
        return
      end

      local file = vim.fn.expand("%:p")
      vim.cmd("write")

      -- Java needs the class name (filename without extension) for the second arg
      local cmd
      if ft == "java" then
        local classname = vim.fn.expand("%:t:r")
        cmd = string.format(template, vim.fn.shellescape(file), classname)
      else
        cmd = string.format(template, vim.fn.shellescape(file))
      end

      vim.cmd("botright 15split | terminal " .. cmd)
    end

    local function run_custom()
      vim.ui.input({ prompt = "Run command: " }, function(cmd)
        if not cmd or cmd == "" then return end
        vim.cmd("botright 15split | terminal " .. cmd)
      end)
    end

    -- Terminal keymaps
    vim.keymap.set("n", "<leader>th", ":split | terminal<CR>", { desc = "Open terminal in horizontal split" })
    vim.keymap.set("n", "<leader>tv", ":vsplit | terminal<CR>", { desc = "Open terminal in vertical split" })
    vim.keymap.set("n", "<leader>tt", ":term<CR>", { desc = "Open terminal in nvim" })
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

    -- Code runner keymaps
    vim.keymap.set("n", "<leader>rr", run_file, { desc = "Run current file" })
    vim.keymap.set("n", "<leader>rc", run_custom, { desc = "Run custom command" })

    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "*",
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.cmd("setlocal winfixheight")
        vim.cmd("setlocal winfixwidth")
        vim.cmd("startinsert")
        vim.keymap.set("n", "q", "<cmd>bdelete!<CR>", { buffer = buf, desc = "Close terminal" })
      end
    })
  end
}