MiniDeps.later(function()
  MiniDeps.add({ source = "akinsho/bufferline.nvim" })

  local bufferline = require("bufferline")
  bufferline.setup({
    options = {
      close_command = function(n) require("mini.bufremove").delete(n) end,
      numbers = "none",
      diagnostics = "nvim_lsp",
      show_buffer_close_icons = false,
      show_close_icon = false,
      sort_by = "id",
    },
  })

  vim.keymap.set("n", "<leader>bd", function() require("mini.bufremove").delete() end, { desc = "Delete" })
  vim.keymap.set("n", "<leader>bo", function() bufferline.close_others() end, { desc = "Delete Other" })
  vim.keymap.set("n", "<leader>bp", function() bufferline.groups.toggle_pin() end, { desc = "Toggle Pin" })
  vim.keymap.set(
    "n",
    "<leader>bP",
    function() bufferline.groups.action("ungrouped", "close") end,
    { desc = "Delete Non-Pinned" }
  )
  vim.keymap.set(
    "n",
    "<leader>bl",
    function() bufferline.close_in_direction("right") end,
    { desc = "Delete to the Right" }
  )
  vim.keymap.set(
    "n",
    "<leader>bh",
    function() bufferline.close_in_direction("left") end,
    { desc = "Delete to the Left" }
  )
  vim.keymap.set("n", "[b", function() bufferline.cycle(-1) end, { desc = "Prev Buffer" })
  vim.keymap.set("n", "]b", function() bufferline.cycle(1) end, { desc = "Next Buffer" })
  vim.keymap.set("n", "[B", function() bufferline.move(-1) end, { desc = "Move Buffer Prev" })
  vim.keymap.set("n", "]B", function() bufferline.move(1) end, { desc = "Move Buffer Next" })
  vim.keymap.set("n", "<leader>bb", function() pcall(vim.cmd.e, "#") end, { desc = "Switch to Other Buffer" })
  vim.keymap.set("n", "<leader>`", function() pcall(vim.cmd.e, "#") end, { desc = "Switch to Other Buffer" })
  vim.keymap.set("n", "<leader>bn", function() vim.cmd.enew() end, { desc = "New File" })
  vim.keymap.set("n", "<leader>b0", function() vim.cmd("bfirst") end, { desc = "First Buffer" })
  vim.keymap.set("n", "<leader>b$", function() vim.cmd("blast") end, { desc = "Last Buffer" })
  vim.keymap.set("n", "<leader>b<tab>", function()
    local tabs = vim.api.nvim_list_tabpages()
    local current_tab = vim.api.nvim_get_current_tabpage()
    local items = {}

    for i, t in ipairs(tabs) do
      if t ~= current_tab then
        local tab_name = vim.g["TabPageCustomName" .. i] or i

        table.insert(items, {
          idx = i,
          text = "Tab: " .. tab_name,
          tab = t,
        })
      end
    end

    vim.ui.select(items, {
      prompt = "Select a tab page:",
      format_item = function(item) return item.text end,
    }, function(choice)
      if choice then
        vim.cmd("ScopeMoveBuf " .. choice.idx)
      end
    end)
  end, { desc = "Move current buffer to tab" })
end)
