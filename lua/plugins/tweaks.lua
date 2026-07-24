return {
  -- Claude Code model names → DeepSeek
  {
    "coder/claudecode.nvim",
    opts = {
      models = {
        { name = "DeepSeek V4 Pro (1M)", value = "opus" },
        { name = "DeepSeek V4 Flash (1M)", value = "haiku" },
        { name = "Default", value = "default" },
      },
    },
  },

  -- Smooth scroll / resize (cursor left to smear-cursor)
  {
    "nvim-mini/mini.animate",
    opts = function(_, opts)
      local animate = require("mini.animate")
      return vim.tbl_deep_extend("force", opts, {
        cursor = { enable = false },
        scroll = {
          timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
        },
        resize = {
          timing = animate.gen_timing.linear({ duration = 250, unit = "total" }),
        },
      })
    end,
  },

  -- Subtle 120-column guide
  {
    "lukas-reineke/virt-column.nvim",
    event = "VeryLazy",
    opts = {
      char = "▏",
      virtcolumn = "120",
      highlight = "Comment",
    },
  },
}
