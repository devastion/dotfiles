---@type LazySpec
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    input = { enabled = true },
    words = { enabled = true },
    notifier = { enabled = true },
  },
  init = function()
    ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
    local progress = vim.defaulttable()
    vim.api.nvim_create_autocmd("LspProgress", {
      ---@param event {data: {client_id: integer, params: lsp.ProgressParams}}
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local value = event.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
        if not client or type(value) ~= "table" then
          return
        end
        local p = progress[client.id]

        for i = 1, #p + 1 do
          if i == #p + 1 or p[i].token == event.data.params.token then
            p[i] = {
              token = event.data.params.token,
              msg = ("[%3d%%] %s%s"):format(
                value.kind == "end" and 100 or value.percentage or 100,
                value.title or "",
                value.message and (" **%s**"):format(value.message) or ""
              ),
              done = value.kind == "end",
            }
            break
          end
        end

        local msg = {} ---@type string[]
        progress[client.id] = vim.tbl_filter(function(v) return table.insert(msg, v.msg) or not v.done end, p)

        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(table.concat(msg, "\n"), "info", {
          id = "lsp_progress",
          title = client.name,
          opts = function(notif)
            notif.icon = #progress[client.id] == 0 and " "
              or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end,
        })
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        ---@diagnostic disable-next-line: duplicate-set-field
        _G.dd = function(...) Snacks.debug.inspect(...) end
        ---@diagnostic disable-next-line: duplicate-set-field
        _G.bt = function() Snacks.debug.backtrace() end
        vim.print = _G.dd

        local toggle_key = require("devastion.utils.constants").leader_keys.toggles
        local map_toggle = function(key) return toggle_key .. key end

        -- Snacks Toggles
        Snacks.toggle.option("spell", { name = "Spelling" }):map(map_toggle("s"))
        Snacks.toggle.option("wrap", { name = "Wrap" }):map(map_toggle("w"))
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map(map_toggle("L"))
        Snacks.toggle.diagnostics():map(map_toggle("d"))
        Snacks.toggle.line_number():map(map_toggle("l"))
        Snacks.toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map(map_toggle("c"))
        Snacks.toggle.treesitter():map(map_toggle("T"))
        Snacks.toggle.inlay_hints():map(map_toggle("h"))
        Snacks.toggle
          .option("background", { off = "light", on = "dark", name = "Dark Background" })
          :map(map_toggle("B"))
        Snacks.toggle.option("showtabline", { off = 0, on = 2, name = "Bufferline" }):map(map_toggle("b"))
      end,
    })
  end,
  keys = {
    -- Snacks Notifier
    {
      "<leader>N",
      function() Snacks.notifier.show_history() end,
      desc = "Notify History",
    },
    {
      "<esc>",
      function()
        vim.cmd("nohl")
        Snacks.notifier.hide()
        return "<esc>"
      end,
      desc = "Escape and Clear hlsearch/notifications",
    },
    -- Snacks Words
    {
      "]]",
      function() Snacks.words.jump(vim.v.count1, false) end,
      desc = "Next Word Reference",
    },
    {
      "[[",
      function() Snacks.words.jump(-vim.v.count1, false) end,
      desc = "Prev Word Reference",
    },
    -- Snacks Scratch
    {
      "<leader>.",
      function() Snacks.scratch() end,
      desc = "Toggle Scratch Buffer",
    },
    -- Snacks GitBrowse
    {
      "<leader>go",
      function() Snacks.gitbrowse() end,
      desc = "Open File in Repository",
    },
    -- Snacks Rename
    {
      "grN",
      function() Snacks.rename.rename_file() end,
      desc = "Rename File",
    },
  },
}
