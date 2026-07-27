

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local clone_output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Could not install lazy.nvim. Check Git/network access and retry:\n" .. clone_output)
  end
end
vim.opt.rtp:prepend(lazypath)

-- setup lazy vim
require("vim-options")
require("set")
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
})
