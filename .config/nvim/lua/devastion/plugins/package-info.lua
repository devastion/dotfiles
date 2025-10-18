vim.pack.add({
  { src = "https://github.com/vuki656/package-info.nvim" },
  { src = "https://github.com/muniftanjim/nui.nvim" },
}, { confirm = false })

require("package-info").setup()

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "package.json",
  callback = function(args)
    local map = require("devastion.utils").remap
    local bufnr = args.buf

    require("which-key").add({ "<leader>n", group = "+[Package Info]" })

    map(
      "<leader>ns",
      function() require("package-info").show() end,
      "Show",
      "n",
      { silent = true, noremap = true, buffer = bufnr }
    )
    map(
      "<leader>nh",
      function() require("package-info").hide() end,
      "Hide",
      "n",
      { silent = true, noremap = true, buffer = bufnr }
    )
    map(
      "<leader>nt",
      function() require("package-info").toggle() end,
      "Toggle",
      "n",
      { silent = true, noremap = true, buffer = bufnr }
    )
    map(
      "<leader>nu",
      function() require("package-info").update() end,
      "Update",
      "n",
      { silent = true, noremap = true, buffer = bufnr }
    )
    map(
      "<leader>nd",
      function() require("package-info").delete() end,
      "Delete",
      "n",
      { silent = true, noremap = true, buffer = bufnr }
    )
    map(
      "<leader>ni",
      function() require("package-info").install() end,
      "Install",
      "n",
      { silent = true, noremap = true, buffer = bufnr }
    )
    map(
      "<leader>nc",
      function() require("package-info").change_version() end,
      "Change Version",
      "n",
      { silent = true, noremap = true, buffer = bufnr }
    )
  end,
})
