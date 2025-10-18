vim.pack.add({
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",
    data = {
      post_update = function(_)
        vim.notify("Updating treesitter parsers...", vim.log.levels.INFO)
        require("nvim-treesitter.install").update(nil, { summary = true })
        vim.notify("Treesitter parsers updated!", vim.log.levels.INFO)
      end,
    },
  },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
  { src = "https://github.com/rrethy/nvim-treesitter-endwise" },
  { src = "https://github.com/windwp/nvim-ts-autotag" },
  "https://github.com/andersevenrud/nvim_context_vt",
}, { confirm = false })

local ensure_installed = {
  "bash",
  "c",
  "diff",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "jsonc",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "printf",
  "python",
  "query",
  "regex",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}
local ignored = { "tmux" }

local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0 end
local to_install = vim.tbl_filter(isnt_installed, ensure_installed)
if #to_install > 0 then
  require("nvim-treesitter").install(to_install)
end
local installed_filetypes = vim.iter(ensure_installed):map(vim.treesitter.language.get_filetypes):flatten():totable()

vim.api.nvim_create_autocmd("FileType", {
  pattern = installed_filetypes,
  callback = function(event)
    vim.treesitter.start(event.buf)
    vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

---Install treesitter parsers
---@param parsers table<string>
vim.g.ts_install = function(parsers) require("nvim-treesitter").install(parsers) end

-- Auto-install and start parsers for any buffer
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function(event)
    local bufnr = event.buf
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

    -- Skip if no filetype
    if filetype == "" then
      return
    end

    -- Check if this filetype is already handled by explicit ensure_installed config
    for _, filetypes in pairs(ensure_installed) do
      local ft_table = type(filetypes) == "table" and filetypes or { filetypes }
      if vim.tbl_contains(ft_table, filetype) then
        return -- Already handled above
      end
    end

    for _, filetypes in pairs(ignored) do
      local ft_table = type(filetypes) == "table" and filetypes or { filetypes }
      if vim.tbl_contains(ft_table, filetype) then
        return -- Already handled above
      end
    end

    -- Get parser name based on filetype
    local parser_name = vim.treesitter.language.get_lang(filetype) -- might return filetype (not helpful)
    if not parser_name then
      return
    end

    -- Try to get existing parser (helpful check if filetype was returned above)
    local parser_configs = require("nvim-treesitter.parsers")
    if not parser_configs[parser_name] then
      return -- Parser not available, skip silently
    end

    local parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

    if not parser_installed then
      -- If not installed, install parser synchronously
      require("nvim-treesitter").install({ parser_name }):wait(30000)
    end

    -- let's check again
    parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

    if parser_installed then
      -- Start treesitter for this buffer
      vim.treesitter.start(bufnr, parser_name)
      vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
  move = {
    set_jumps = true,
  },
  multiwindow = true,
})

local text_objects_outer = {
  f = "@function.outer",
  c = "@class.outer",
  p = "@parameter.outer",
  l = "@loop.outer",
  a = "@assignment.outer",
  r = "@return.outer",
}
local text_objects_inner = {
  f = "@function.inner",
  c = "@class.inner",
  p = "@parameter.inner",
  l = "@loop.inner",
  a = "@assignment.inner",
  r = "@return.inner",
}

local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
local goto_next_start = require("nvim-treesitter-textobjects.move").goto_next_start
local goto_next_end = require("nvim-treesitter-textobjects.move").goto_next_end
local goto_previous_start = require("nvim-treesitter-textobjects.move").goto_previous_start
local goto_previous_end = require("nvim-treesitter-textobjects.move").goto_previous_end

for k, v in pairs(text_objects_outer) do
  vim.keymap.set({ "x", "o" }, "a" .. k, function() select_textobject(v, "textobjects") end, { desc = "Select " .. v })
  vim.keymap.set(
    { "n", "x", "o" },
    "[" .. k,
    function() goto_previous_start(v, "textobjects") end,
    { desc = "Goto Previous Start " .. v }
  )
  vim.keymap.set(
    { "n", "x", "o" },
    "[" .. string.upper(k),
    function() goto_previous_end(v, "textobjects") end,
    { desc = "Goto Previous End " .. v }
  )
end

for k, v in pairs(text_objects_inner) do
  vim.keymap.set({ "x", "o" }, "i" .. k, function() select_textobject(v, "textobjects") end, { desc = "Select " .. v })
  vim.keymap.set(
    { "n", "x", "o" },
    "]" .. k,
    function() goto_next_start(v, "textobjects") end,
    { desc = "Goto Next Start " .. v }
  )
  vim.keymap.set(
    { "n", "x", "o" },
    "]" .. string.upper(k),
    function() goto_next_end(v, "textobjects") end,
    { desc = "Goto Next End " .. v }
  )
end

vim.keymap.set(
  "n",
  "<C-a><C-n>",
  function() require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner") end,
  { desc = "Swap @parameter with next" }
)
vim.keymap.set(
  "n",
  "<C-a><C-p>",
  function() require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner") end,
  { desc = "Swap @parameter with previous" }
)

require("treesitter-context").setup({
  enable = true,
  mode = "cursor",
  max_lines = 0,
  multiwindow = true,
})
vim.keymap.set(
  "n",
  "[c",
  function() require("treesitter-context").go_to_context(vim.v.count1) end,
  { desc = "Context" }
)

require("nvim-ts-autotag").setup()

require("nvim_context_vt").setup({ min_rows = 10 })
vim.keymap.set(
  "n",
  "<leader>Tc",
  function() require("nvim_context_vt").toggle_context() end,
  { desc = "Toggle context virtual text" }
)
