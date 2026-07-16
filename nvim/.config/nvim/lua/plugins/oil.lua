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
