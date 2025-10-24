vim.filetype.add({
  pattern = {
    ["(^|/)%.?env[%.-]?[%w_]*$"] = "dotenv",
    [".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
    ["docker-compose%.yml"] = "yaml.docker-compose",
    ["docker-compose%.yaml"] = "yaml.docker-compose",
    ["compose%.yml"] = "yaml.docker-compose",
    ["compose%.yaml"] = "yaml.docker-compose",
  },
})
