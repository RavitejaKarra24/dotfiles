return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "williamboman/mason.nvim" },
  opts = {
    ensure_installed = {
      "basedpyright",
      "lua-language-server",
      "prettier",
      "ruff",
      "rust-analyzer",
      "stylua",
      "typescript-language-server",
    },
    run_on_start = vim.env.CI == nil and vim.env.DOTFILES_DOCTOR == nil,
    start_delay = 3000,
    debounce_hours = 24,
  },
}
