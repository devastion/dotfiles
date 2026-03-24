if vim.env.PROF then
  local snacks = vim.fn.stdpath("data") .. "/site/pack/core/opt/snacks.nvim"
  vim.opt.rtp:append(snacks)
  require("snacks.profiler").startup({
    startup = {
      event = "VimEnter",
    },
  })
end

require("devastion.config")
