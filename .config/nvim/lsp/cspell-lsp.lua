return {
  cmd = { "cspell-lsp", "--stdio", "--sortWords", "--config", vim.fn.stdpath("config") .. "/cspell.json" },
  root_markers = {
    ".git",
    "cspell.json",
    ".cspell.json",
    "cspell.json",
    ".cSpell.json",
    "cSpell.json",
    "cspell.config.js",
    "cspell.config.cjs",
    "cspell.config.json",
    "cspell.config.yaml",
    "cspell.config.yml",
    "cspell.yaml",
    "cspell.yml",
  },
}
