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

    local function detect_package_manager()
      local markers = {
        { file = "bun.lockb",       cmd = "bun add" },
        { file = "bun.lock",        cmd = "bun add" },
        { file = "pnpm-lock.yaml",  cmd = "pnpm add" },
        { file = "yarn.lock",       cmd = "yarn add" },
        { file = "package-lock.json", cmd = "npm install" },
        { file = "requirements.txt", cmd = "pip install" },
        { file = "pyproject.toml",  cmd = "pip install" },
        { file = "Cargo.toml",      cmd = "cargo add" },
        { file = "go.mod",          cmd = "go get" },
      }
      local buf_dir = vim.fn.expand("%:p:h")
      for _, m in ipairs(markers) do
        local found = vim.fn.findfile(m.file, buf_dir .. ";")
        if found ~= "" then return m.cmd end
      end
      -- package.json as last-resort fallback for JS/TS projects
      if vim.fn.findfile("package.json", buf_dir .. ";") ~= "" then
        return "npm install"
      end
      return nil
    end

    local function parse_import_package()
      local line = vim.api.nvim_get_current_line()

      -- JS/TS: import ... from "pkg" or import ... from 'pkg'
      local pkg = line:match('from%s+["\']([^"\']+)["\']')
      -- JS/TS: require("pkg") or require('pkg')
      if not pkg then pkg = line:match('require%s*%(%s*["\']([^"\']+)["\']') end
      if pkg then
        -- Scoped packages: "@scope/name/deep" -> "@scope/name"
        if pkg:sub(1, 1) == "@" then
          pkg = pkg:match("^(@[^/]+/[^/]+)")
        else
          pkg = pkg:match("^([^/]+)")
        end
        return pkg
      end

      -- Python: from pkg import ... or import pkg
      pkg = line:match("^%s*from%s+([%w_]+)")
      if not pkg then pkg = line:match("^%s*import%s+([%w_]+)") end
      if pkg then return pkg end

      -- Go: import "github.com/user/repo"
      pkg = line:match('import%s+["\']([^"\']+)["\']')
      if pkg then return pkg end

      -- Rust: use crate_name::
      pkg = line:match("^%s*use%s+([%w_]+)::")
      if pkg then return pkg end

      return nil
    end

    local function install_package(skip_parse)
      local pm = detect_package_manager()
      if not pm then
        vim.notify("Could not detect package manager.\nNo lock file found in parent directories.", vim.log.levels.WARN)
        return
      end

      local pkg = nil
      if not skip_parse then
        pkg = parse_import_package()
      end

      if pkg then
        vim.cmd("botright 10split | terminal " .. pm .. " " .. pkg)
      else
        vim.ui.input({ prompt = pm .. " " }, function(input)
          if not input or input == "" then return end
          vim.cmd("botright 10split | terminal " .. pm .. " " .. input)
        end)
      end
    end

    -- Terminal keymaps
    vim.keymap.set("n", "<leader>th", ":split | terminal<CR>", { desc = "Open terminal in horizontal split" })
    vim.keymap.set("n", "<leader>tv", ":vsplit | terminal<CR>", { desc = "Open terminal in vertical split" })
    vim.keymap.set("n", "<leader>tt", ":term<CR>", { desc = "Open terminal in nvim" })
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

    -- Code runner keymaps
    vim.keymap.set("n", "<leader>rr", run_file, { desc = "Run current file" })
    vim.keymap.set("n", "<leader>rc", run_custom, { desc = "Run custom command" })

    -- Package installer keymaps
    vim.keymap.set("n", "<leader>ri", function() install_package(false) end, { desc = "Install package from import" })
    vim.keymap.set("n", "<leader>ra", function() install_package(true) end, { desc = "Add package (prompt)" })

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