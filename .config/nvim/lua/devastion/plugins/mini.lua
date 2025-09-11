require("mini.files").setup()
vim.keymap.set("n", "<leader>e", function() require("mini.files").open() end, { desc = "Files (root)" })
vim.keymap.set(
  "n",
  "<leader>E",
  function() require("mini.files").open(vim.api.nvim_buf_get_name(0), true) end,
  { desc = "Files (cwd)" }
)
require("mini.move").setup()
require("mini.comment").setup()
require("mini.cursorword").setup()
local function setup_mini_pairs(opts)
  local pairs = require("mini.pairs")
  pairs.setup(opts)
  local open = pairs.open
  ---@diagnostic disable-next-line: duplicate-set-field
  pairs.open = function(pair, neigh_pattern)
    if vim.fn.getcmdline() ~= "" then
      return open(pair, neigh_pattern)
    end
    local o, c = pair:sub(1, 1), pair:sub(2, 2)
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local next = line:sub(cursor[2] + 1, cursor[2] + 1)
    local before = line:sub(1, cursor[2])
    if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
      return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
    end
    if opts.skip_next and next ~= "" and next:match(opts.skip_next) then
      return o
    end
    if opts.skip_ts and #opts.skip_ts > 0 then
      local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
      for _, capture in ipairs(ok and captures or {}) do
        if vim.tbl_contains(opts.skip_ts, capture.capture) then
          return o
        end
      end
    end
    if opts.skip_unbalanced and next == c and c ~= o then
      local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
      local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
      if count_close > count_open then
        return o
      end
    end
    return open(pair, neigh_pattern)
  end
end
setup_mini_pairs({
  modes = { insert = true, command = true, terminal = false },
  skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
  skip_ts = { "string" },
  skip_unbalanced = true,
  markdown = true,
})
require("mini.splitjoin").setup({ mappings = { toggle = "J" } })
local mini_operators = require("mini.operators")
mini_operators.setup({
  evaluate = {
    prefix = "",
    func = nil,
  },
  exchange = {
    prefix = "",
    reindent_linewise = true,
  },
  multiply = {
    prefix = "",
    func = nil,
  },
  replace = {
    prefix = "",
    reindent_linewise = true,
  },
  sort = {
    prefix = "",
    func = nil,
  },
})
mini_operators.make_mappings("replace", { textobject = "ss", line = "sS", selection = "ss" })
mini_operators.make_mappings("sort", { textobject = "so", line = "sO", selection = "so" })
require("mini.indentscope").setup({
  draw = {
    animation = require("mini.indentscope").gen_animation.none(),
  },
  options = { try_as_border = true },
})
require("mini.surround").setup({
  mappings = {
    add = "sa",
    delete = "sd",
    replace = "sr",
    find = "",
    find_left = "",
    highlight = "",
    update_n_lines = "",
    suffix_last = "",
    suffix_next = "",
  },
  n_lines = 500,
})

vim.keymap.set({ "n", "x" }, "s", "<Nop>")
