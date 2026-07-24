return {
  -- Extra colorscheme plugins (used by favorites list in options.lua)
  { "rose-pine/neovim", name = "rose-pine" },
  { "rebelot/kanagawa.nvim" },
  { "EdenEast/nightfox.nvim" },
  { "ellisonleao/gruvbox.nvim" },

  -- Colorscheme picker + restore
  {
    "folke/snacks.nvim",

    -- Persist / restore chosen colorscheme across sessions
    init = function()
      local state = vim.fn.stdpath("state") .. "/colorscheme"
      local ok, lines = pcall(vim.fn.readfile, state)
      if ok and #lines >= 2 then
        vim.api.nvim_create_autocmd("User", {
          pattern = "LazyVimStarted",
          once = true,
          callback = function()
            vim.o.background = lines[2]
            pcall(vim.cmd.colorscheme, lines[1])
            vim.o.background = lines[2]
          end,
        })
      end
    end,

    keys = {
      {
        "<leader>uC",
        function()
          ------------------------------------------------------------------
          -- 1. Scanner — cached per session
          ------------------------------------------------------------------
          local installed = _G._cs_installed
          if not installed then
            local rtp = vim.o.rtp
            if package.loaded.lazy then
              rtp = rtp .. "," .. table.concat(require("lazy.core.util").get_unloaded_rtp(""), ",")
            end
            installed = {}
            for _, f in ipairs(vim.fn.globpath(rtp, "colors/*", false, true)) do
              local name = vim.fn.fnamemodify(f, ":t:r")
              local ext = vim.fn.fnamemodify(f, ":e")
              if not installed[name] and (ext == "vim" or ext == "lua") then
                installed[name] = f
              end
            end
            _G._cs_installed = installed
          end

          ------------------------------------------------------------------
          -- 2. Items — from favorites, each carrying bg metadata
          ------------------------------------------------------------------
          local items = {}
          for _, fav in ipairs(vim.g.favorite_colorschemes or {}) do
            if installed[fav.name] then
              items[#items + 1] = {
                text = fav.name,
                file = installed[fav.name],
                bg = fav.bg,
              }
            end
          end

          ------------------------------------------------------------------
          -- 3. Apply — full reset, no cross-theme pollution
          ------------------------------------------------------------------
          local function apply(item)
            for k, _ in pairs(package.loaded) do
              if k == item.text or vim.startswith(k, item.text .. ".") then
                package.loaded[k] = nil
              end
            end
            vim.o.background = item.bg
            pcall(vim.cmd.colorscheme, item.text)
            vim.o.background = item.bg -- re-enforce
            vim.cmd.redraw()
          end

          ------------------------------------------------------------------
          -- 4. Debounced preview — only the last hovered item takes effect
          ------------------------------------------------------------------
          local timer_preview ---@type uv_timer?
          local timer_apply  ---@type uv_timer?

          local function schedule_preview(item)
            if timer_preview then timer_preview:close() end
            timer_preview = vim.defer_fn(function()
              if timer_apply then timer_apply:close() end
              timer_apply = vim.defer_fn(function()
                apply(item)
                timer_apply = nil
              end, 0)
              timer_preview = nil
            end, 60)
          end

          local function cancel_timers()
            if timer_preview then timer_preview:close() end
            if timer_apply then timer_apply:close() end
          end

          ------------------------------------------------------------------
          -- 5. Picker (with save-on-enter, restore-on-escape)
          ------------------------------------------------------------------
          local original = { name = vim.g.colors_name, bg = vim.o.background }

          Snacks.picker({
            title = "Favorite Colorschemes",
            items = items,
            format = function(item)
              local icon = item.bg == "light" and "  " or "  "
              return { { icon, "SnacksPickerDir" }, { item.text } }
            end,
            preset = "select",
            preview = function(ctx)
              schedule_preview(ctx.item)
              require("snacks.picker.preview").file(ctx)
            end,
            confirm = function(p, item)
              if item then
                original = nil -- signal on_close: user confirmed, don't restore
                cancel_timers()
                vim.schedule(function() apply(item) end)
                local state = vim.fn.stdpath("state") .. "/colorscheme"
                vim.fn.writefile({ item.text, item.bg }, state)
              end
              p:close()
            end,
            on_close = function()
              cancel_timers()
              if original then
                vim.o.background = original.bg
                pcall(vim.cmd.colorscheme, original.name)
                vim.o.background = original.bg
              end
            end,
          })
        end,
        desc = "Favorite Colorschemes",
      },
    },
  },
}
