vim.filetype.add({
  filename = {
    [".env"] = "dotenv",
  },
  pattern = {
    ["%.env%.[%w_.-]+"] = "dotenv",
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.ghaction",
    [".*/docker%-compose%.ya?ml"] = "yaml.docker-compose",
    [".*/compose%.ya?ml"] = "yaml.docker-compose",
  },
})
