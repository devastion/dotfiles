require("devastion.utils.pkg").add({
  {
    src = "nvim-mini/mini.pairs",
    data = {
      event = { "InsertEnter", "CmdlineEnter" },
      config = function()
        local pairs = require("mini.pairs")
        local pairs_opts = {
          modes = { insert = true, command = false, terminal = false },
          skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
          skip_ts = { "string" },
          skip_unbalanced = true,
          markdown = true,
        }
        pairs.setup(pairs_opts)
        local open = pairs.open
        pairs.open = function(pair, neigh_pattern)
          if vim.fn.getcmdline() ~= "" then
            return open(pair, neigh_pattern)
          end
          local o, c = pair:sub(1, 1), pair:sub(2, 2)
          local line = vim.api.nvim_get_current_line()
          local cursor = vim.api.nvim_win_get_cursor(0)
          local next = line:sub(cursor[2] + 1, cursor[2] + 1)
          local before = line:sub(1, cursor[2])
          if pairs_opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
            return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
          end
          if pairs_opts.skip_next and next ~= "" and next:match(pairs_opts.skip_next) then
            return o
          end
          if pairs_opts.skip_ts and #pairs_opts.skip_ts > 0 then
            local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
            for _, capture in ipairs(ok and captures or {}) do
              if vim.tbl_contains(pairs_opts.skip_ts, capture.capture) then
                return o
              end
            end
          end
          if pairs_opts.skip_unbalanced and next == c and c ~= o then
            local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
            local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
            if count_close > count_open then
              return o
            end
          end
          return open(pair, neigh_pattern)
        end
      end,
    },
  },
})
