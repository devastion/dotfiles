---@type LazySpec
return {
  "bennypowers/nvim-regexplainer",
  lazy = true,
  cmd = {
    "RegexplainerShowSplit",
    "RegexplainerShowPopup",
    "RegexplainerHide",
    "RegexplainerToggle",
  },
  opts = {
    auto = true,
  },
}
