-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Indentation
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Display
vim.opt.timeoutlen = 200
vim.opt.wrap = true

-- Column guide handled by virt-column.nvim (lua/plugins/virt-column.lua)

-- Favorite colorschemes for <leader>uC picker
vim.g.favorite_colorschemes = {
  -- Light
  { name = "catppuccin-latte",     bg = "light" },
  { name = "dayfox",               bg = "light" },
  { name = "default",              bg = "light" },
  { name = "rose-pine-dawn",       bg = "light" },
  -- Dark
  { name = "carbonfox",            bg = "dark" },
  { name = "catppuccin-mocha",     bg = "dark" },
  { name = "default",              bg = "dark" },
  { name = "gruvbox",              bg = "dark" },
  { name = "kanagawa-dragon",      bg = "dark" },
  { name = "rose-pine-moon",       bg = "dark" },
}

-- Auto reload files changed outside Neovim
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  pattern = "*",
  callback = function()
    if vim.bo.buftype ~= "terminal" then
      vim.cmd("checktime")
    end
  end,
})
