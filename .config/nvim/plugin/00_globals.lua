local g = vim.g

g.mapleader = vim.keycode("<Space>")
g.maplocalleader = vim.keycode("<Bslash>")

-- Disable some default providers
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

g.autolint_enabled = true
g.autoformat_enabled = false

---Install packages with mason
---@param packages table<string>
g.mason_install = function(packages)
  MiniDeps.later(function()
    local mr = require("mason-registry")

    mr.refresh(function()
      for _, tool in ipairs(packages) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end)
  end)
end

---Install treesitter parsers
---@param parsers table<string>
g.ts_install = function(parsers)
  MiniDeps.later(function() require("nvim-treesitter").install(parsers) end)
end

g.custom_foldtext = function()
  local function fold_virt_text(result, s, lnum, coloff)
    if not coloff then
      coloff = 0
    end
    local text = ""
    local hl
    for i = 1, #s do
      local char = s:sub(i, i)
      local hls = vim.treesitter.get_captures_at_pos(0, lnum, coloff + i - 1)
      local _hl = hls[#hls]
      if _hl then
        local new_hl = "@" .. _hl.capture
        if new_hl ~= hl then
          table.insert(result, { text, hl })
          text = ""
          hl = nil
        end
        text = text .. char
        hl = new_hl
      else
        text = text .. char
      end
    end
    table.insert(result, { text, hl })
  end

  local start = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", vim.o.tabstop))
  local end_str = vim.fn.getline(vim.v.foldend)
  local end_ = vim.trim(end_str)
  local result = {}
  fold_virt_text(result, start, vim.v.foldstart - 1)
  table.insert(result, { " ... ", "Delimiter" })
  fold_virt_text(result, end_, vim.v.foldend - 1, #(end_str:match("^(%s+)") or ""))
  return result
end

g.toggles = function(decrement)
  local increment_toggles = {
    ["false"] = "true",
  }

  local decrement_toggles = {
    ["true"] = "false",
  }

  local toggles = decrement and decrement_toggles or increment_toggles

  local cword = vim.fn.expand("<cword>")
  local newWord

  for word, opposite in pairs(toggles) do
    if cword == word then
      newWord = opposite
    end
    if cword == opposite then
      newWord = word
    end
  end

  if type(tonumber(cword)) == "number" then
    newWord = decrement and (cword - 1) or (cword + 1)
  end

  if newWord then
    local prevCursor = vim.api.nvim_win_get_cursor(0)
    vim.cmd.normal({ '"_ciw' .. newWord, bang = true })
    vim.api.nvim_win_set_cursor(0, prevCursor)
  end
end

vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH
vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, "/") .. ":" .. vim.env.PATH
