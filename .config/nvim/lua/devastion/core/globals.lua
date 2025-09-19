vim.g.mapleader = vim.keycode("<Space>")
vim.g.maplocalleader = vim.keycode("<Bslash>")

-- Disable some default providers
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.g.autolint_enabled = true
vim.g.autoformat_enabled = false

---Install packages
---@param specs (string|vim.pack.Spec)[]
vim.g.package_manager_install = function(specs) vim.pack.add(specs, { confirm = false }) end
vim.g.package_manager_update = function() vim.pack.update() end

vim.g.custom_foldtext = function()
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

vim.g.word_cycle = function(decrement)
  local toggle_groups = {
    { "true", "false" },
    { "on", "off" },
    { "now", "later" },
  }

  local function match_case(original, new)
    if original:match("^%u+$") then
      return new:upper()
    end
    if original:match("^%l+$") then
      return new:lower()
    end
    if original:match("^%u%l+$") then
      return new:sub(1, 1):upper() .. new:sub(2):lower()
    end
    return new
  end

  local function get_next_word(word)
    local lower = word:lower()
    for _, group in ipairs(toggle_groups) do
      for i, w in ipairs(group) do
        if w == lower then
          local swap = group[(i % #group) + (decrement and -1 or 1)]
          return match_case(word, swap)
        end
      end
    end
    return nil
  end

  local word = vim.fn.expand("<cword>")
  local replacement = get_next_word(word)
  if not replacement then
    return
  end

  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  local start_col = col
  while start_col > 0 and line:sub(start_col, start_col):match("[%w_]") do
    start_col = start_col - 1
  end
  start_col = start_col + 1

  local end_col = col + 1
  while line:sub(end_col, end_col):match("[%w_]") do
    end_col = end_col + 1
  end
  end_col = end_col - 1

  local new_line = line:sub(1, start_col - 1) .. replacement .. line:sub(end_col + 1)
  vim.api.nvim_set_current_line(new_line)
end

---Checks if composer.json contains laravel/framework
---@return boolean
vim.g.is_laravel_project = (function()
  local composer = vim.fn.getcwd() .. "/composer.json"

  if vim.fn.filereadable(composer) == 0 then
    return false
  end

  local is_laravel = vim.system({ "jq", '.require."laravel/framework"', composer }, {}):wait().stdout
  if is_laravel then
    vim.schedule(function() vim.notify("Laravel detected", vim.log.levels.INFO) end)
    return true
  end

  return false
end)()

vim.g.is_tailwind_project = (function()
  local package_json = vim.fn.getcwd() .. "/package.json"

  if vim.fn.filereadable(package_json) == 0 then
    return false
  end

  local function has_tailwind(query)
    local result = vim.system({ "jq", "-r", query, package_json }):wait()

    if result.code == 0 then
      local out = vim.trim(result.stdout or "")
      return out ~= "" and out ~= "null"
    end

    return false
  end

  if has_tailwind(".dependencies.tailwindcss") or has_tailwind(".devDependencies.tailwindcss") then
    vim.schedule(function() vim.notify("TailwindCSS detected", vim.log.levels.INFO) end)
    return true
  end

  return false
end)()
