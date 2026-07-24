return {
  {
    "goolord/alpha-nvim",

    -- Hitokoto: fetch and cache one quote per session
    init = function()
      local cache = vim.fn.stdpath("cache") .. "/hitokoto"
      local nilp = function(v) return v == nil or v == vim.NIL end

      vim.api.nvim_create_autocmd("User", {
        pattern = "AlphaReady",
        callback = function()
          local q, s = _G._hitokoto_quote, _G._hitokoto_source
          if not q or not s then return end

          -- Display cached quote
          local ok, lines = pcall(vim.fn.readfile, cache)
          if ok and #lines >= 2 then
            q.val, s.val = { lines[1] }, { lines[2] }
            pcall(vim.cmd.AlphaRedraw)
          end

          -- Fetch next quote for next startup
          vim.fn.jobstart({ "curl", "-s", "--connect-timeout", "3",
            "https://v1.hitokoto.cn/?c=i&c=k" }, {
            stdout_buffered = true,
            on_stdout = function(_, out)
              if not out or #out == 0 then return end
              local ok2, d = pcall(vim.json.decode, table.concat(out, ""))
              if not ok2 or not d or not d.hitokoto then return end

              local src = ""
              if not nilp(d.from_who) and #d.from_who > 0 then
                src = d.from_who
              end
              if not nilp(d.from) and #d.from > 0 then
                src = src ~= "" and (src .. "「" .. d.from .. "」")
                               or "「" .. d.from .. "」"
              end

              vim.fn.mkdir(vim.fn.stdpath("cache"), "p")
              vim.fn.writefile({ " " .. d.hitokoto, src ~= "" and src or "一言" }, cache)
            end,
          })
        end,
      })
    end,

    -- Dashboard layout: logo + hitokoto + quit + stats
    opts = function(_, dashboard)
      local logo = {
        [[                                    ▄▀▀▄                 ]],
        [[                                    ▌■▀▐▌                ]],
        [[▀▓▄▄   ▄▄▄  ▄▄█▄▄   ▄▓██▄    ▄▓     ▀■▓▀ ▀▓▄▄░▄▓█▄▄   ▄▄▄]],
        [[ ▓▓█▀ ▀▓▓▌ ▓█▀ ▀▓▓ ▓▓▀  ▀▓  ▓▓▀   ▓  ▄▄▓▀ ▓▓█▀ ▀▓▓█▀ ▀▓▓▌]],
        [[▐▒▒   ▐▒▒ ▐▒▌  ▄▒▀▐▒▌   ▐▓▌▐▒▌   ▐▓▌ ▐▓▓ ▐▒▒   ▐▒▒   ▐▒▒ ]],
        [[░░▌   ░░▌  ▀░░▀   ▐░░▄ ▄▒▒  █░▄ ▄▒▒   ▒▒▌░░▌   ░░▌   ░░▌ ]],
        [[██   ▀░█    ▀█▄  ▄ ▀█░█░▀    ▀░█░▀   ▐░░ █░   ▀██   ▀██  ]],
        [[  ▀    ░▀      ▀▀     ▀        ▀     ██▀   ▀     ▀     ▀ ]],
        [[                                     ▀▄                  ]],
      }
      dashboard.section.header.val = logo
      dashboard.section.header.opts.hl = "AlphaHeader"

      -- Quote lines (populated by init autocmd above)
      local quote_text = {
        type = "text", val = {},
        opts = { hl = "String", position = "center" },
      }
      local source_text = {
        type = "text", val = {},
        opts = { hl = "Comment", position = "center" },
      }
      _G._hitokoto_quote = quote_text
      _G._hitokoto_source = source_text

      dashboard.section.buttons.val = {
        dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
      }
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end

      dashboard.config.layout = {
        {
          type = "group",
          val = {
            dashboard.section.header,
            { type = "padding", val = 2 },
            quote_text,
            source_text,
            { type = "padding", val = 2 },
            dashboard.section.buttons,
            { type = "padding", val = 1 },
            dashboard.section.footer,
          },
          opts = { spacing = 0, position = "v_center" },
        },
      }

      return dashboard
    end,
  },
}
