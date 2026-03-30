local cmd_exists = require("devastion.utils").cmd_exists
local map = require("devastion.utils").map
local autocmd = require("devastion.utils").autocmd
local augroup = require("devastion.utils").augroup

local chezmoi_prefixes = {
  "after_",
  "before_",
  "create_",
  "empty_",
  "encrypted_",
  "executable_",
  "literal_",
  "modify_",
  "once_",
  "onchange_",
  "private_",
  "readonly_",
  "remove_",
  "run_",
  "symlink_",
}

local function chezmoi_ft(path, bufnr)
  local name = vim.fs.basename(path)
  name = name:gsub("%.tmpl$", "")

  local changed = true
  while changed do
    changed = false
    for _, prefix in ipairs(chezmoi_prefixes) do
      if vim.startswith(name, prefix) then
        name = name:sub(#prefix + 1)
        changed = true
      end
    end
  end
  name = name:gsub("^dot_", ".")

  return vim.filetype.match({ filename = name, buf = bufnr })
end

vim.filetype.add({
  filename = {
    [".chezmoiignore"] = "gitignore",
    [".chezmoiremove"] = "gitignore",
    [".chezmoiroot"] = "text",
    [".chezmoiversion"] = "text",
  },
  pattern = {
    ["%.chezmoidata%.toml"] = "toml",
    ["%.chezmoidata%.yaml"] = "yaml",
    ["%.chezmoidata%.json"] = "json",
    ["%.chezmoiexternal%.toml"] = "toml",
    ["%.chezmoiexternal%.yaml"] = "yaml",
    ["%.chezmoiexternal%.json"] = "json",
    [".*%.tmpl"] = chezmoi_ft,
  },
})

require("devastion.utils.pkg").add({
  {
    src = "xvzc/chezmoi.nvim",
    data = {
      config = function()
        require("chezmoi").setup({})

        autocmd({ "BufRead", "BufNewFile" }, {
          group = augroup("chezmoi"),
          pattern = {
            os.getenv("HOME") .. "/.local/share/chezmoi/*",
            os.getenv("HOME") .. "/.dotfiles/*",
          },
          callback = function(ev)
            local bufnr = ev.buf
            local edit_watch = function()
              require("chezmoi.commands.__edit").watch(bufnr)
            end
            vim.schedule(edit_watch)
          end,
        })

        if cmd_exists("chezmoi") then
          map("<leader>fC", function()
            require("chezmoi.pick").fzf()
          end, "Chezmoi Files")
        end
      end,
    },
  },
})
