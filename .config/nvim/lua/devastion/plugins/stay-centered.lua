vim.pack.add({ "https://github.com/arnamak/stay-centered.nvim" }, { confirm = false })

require("stay-centered").setup({ skip_filetypes = { "minifiles" } })
