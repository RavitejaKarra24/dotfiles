return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 400,
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add({
      { "<leader>g", group = "git" },
      { "<leader>h", group = "hunks" },
      { "<leader>p", group = "project/find" },
      { "<leader>r", group = "run/packages" },
      { "<leader>t", group = "terminal" },
      { "<leader>c", group = "code" },
      { "<leader>e", group = "diagnostics" },
    })
  end,
}
