local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "devastion/resolve.nvim",
    data = {
      config = function()
        require("resolve").setup({
          default_keymaps = false,
        })

        map("<Leader>gxd", "", "+[Diff]")
        map("]x", "<Plug>(resolve-next)", "Next conflict")
        map("[x", "<Plug>(resolve-prev)", "Previous conflict")
        map("<Leader>gxo", "<Plug>(resolve-ours)", "Choose ours")
        map("<Leader>gxt", "<Plug>(resolve-theirs)", "Choose theirs")
        map("<Leader>gxb", "<Plug>(resolve-both)", "Choose both")
        map("<Leader>gxB", "<Plug>(resolve-both-reverse)", "Choose both reverse")
        map("<Leader>gxm", "<Plug>(resolve-base)", "Choose base")
        map("<Leader>gxn", "<Plug>(resolve-none)", "Choose none")
        map("<Leader>gxdo", "<Plug>(resolve-diff-ours)", "Diff ours")
        map("<Leader>gxdt", "<Plug>(resolve-diff-theirs)", "Diff theirs")
        map("<Leader>gxdb", "<Plug>(resolve-diff-both)", "Diff both")
        map("<Leader>gxdv", "<Plug>(resolve-diff-vs)", "Diff ours → theirs")
        map("<Leader>gxdV", "<Plug>(resolve-diff-vs-reverse)", "Diff theirs → ours")
        map("<Leader>gxq", "<Plug>(resolve-list)", "List conflicts in qf")
      end,
    },
  },
})
