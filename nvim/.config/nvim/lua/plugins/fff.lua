return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  lazy = false,
  opts = {
    lazy_sync = true,
    keymaps = {
      close = { "<Esc>", "<C-c>" },
      select = "<CR>",
      select_split = "<C-s>",
      select_vsplit = "<C-v>",
      select_tab = "<C-t>",
      move_up = { "<Up>", "<C-p>" },
      move_down = { "<Down>", "<C-n>" },
      preview_scroll_up = "<C-u>",
      preview_scroll_down = "<C-d>",
      toggle_debug = "<F2>",
    },
  },
  keys = {
    {
      "<leader>pf",
      function()
        require("fff").find_files()
      end,
      desc = "Find files",
    },
    {
      "<C-p>",
      function()
        require("fff").find_in_git_root()
      end,
      desc = "Find files in git root",
    },
  },
}
