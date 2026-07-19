local function current_directory()
  local directory = require("oil").get_current_dir()
  if not directory then
    vim.notify("Could not determine the current directory", vim.log.levels.ERROR)
  end
  return directory
end

local function create_directory()
  local directory = current_directory()
  if not directory then
    return
  end

  vim.ui.input({ prompt = "New directory: " }, function(name)
    if not name or name:match("^%s*$") then
      return
    end

    local path = vim.fs.joinpath(directory, name)
    if (vim.uv or vim.loop).fs_stat(path) then
      vim.notify("Already exists: " .. path, vim.log.levels.ERROR)
      return
    end

    local ok, result = pcall(vim.fn.mkdir, path, "p")
    if not ok or result == 0 then
      vim.notify("Could not create directory: " .. path, vim.log.levels.ERROR)
      return
    end

    require("oil.actions").refresh.callback({ force = true })
  end)
end

local function create_file()
  local directory = current_directory()
  if not directory then
    return
  end

  vim.ui.input({ prompt = "New file: " }, function(name)
    if not name or name:match("^%s*$") then
      return
    end

    local path = vim.fs.joinpath(directory, name)
    if (vim.uv or vim.loop).fs_stat(path) then
      vim.notify("Already exists: " .. path, vim.log.levels.ERROR)
      return
    end

    vim.cmd.edit(vim.fn.fnameescape(path))
  end)
end

return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  opts = {
    default_file_explorer = true,
    view_options = {
      show_hidden = true,
    },
    keymaps = {
      ["q"] = "actions.close",
      ["<C-h>"] = false,
      ["<C-l>"] = false,
      ["d"] = { create_directory, desc = "Create directory", nowait = true },
      ["%"] = { create_file, desc = "Create file" },
    },
  },
  keys = {
    {
      "<leader>pv",
      function()
        require("oil").open()
      end,
      desc = "Open parent directory (oil)",
    },
    {
      "-",
      function()
        require("oil").open()
      end,
      desc = "Open parent directory (oil)",
    },
  },
}
