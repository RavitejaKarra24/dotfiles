return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit current file" },
    { "<leader>gl", "<cmd>LazyGitFilter<cr>", desc = "LazyGit commits" },
  },
}
