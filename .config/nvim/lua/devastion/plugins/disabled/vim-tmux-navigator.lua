---@type LazySpec
return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<c-h>", "<cmd><c-U>TmuxNavigateLeft<cr>" },
    { "<c-j>", "<cmd><c-U>TmuxNavigateDown<cr>" },
    { "<c-k>", "<cmd><c-U>TmuxNavigateUp<cr>" },
    { "<c-l>", "<cmd><c-U>TmuxNavigateRight<cr>" },
    { "<c-\\>", "<cmd><c-U>TmuxNavigatePrevious<cr>" },
  },
}
