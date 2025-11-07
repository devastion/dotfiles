vim.filetype.add({
  filename = {
    [".env"] = "dotenv",
  },
  pattern = {
    ["%.env%.[%w_.-]+"] = "dotenv",

    -- github actions
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.ghaction",

    -- docker
    [".*/docker%-compose%.ya?ml"] = "yaml.docker-compose",
    [".*/compose%.ya?ml"] = "yaml.docker-compose",

    -- ansible
    [".*/defaults/.*%.ya?ml"] = "yaml.ansible",
    [".*/host_vars/.*%.ya?ml"] = "yaml.ansible",
    [".*/group_vars/.*%.ya?ml"] = "yaml.ansible",
    [".*/group_vars/.*/.*%.ya?ml"] = "yaml.ansible",
    [".*/playbook.*%.ya?ml"] = "yaml.ansible",
    [".*/playbooks/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/tasks/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/handlers/.*%.ya?ml"] = "yaml.ansible",
    [".*/tasks/.*%.ya?ml"] = "yaml.ansible",
    [".*/molecule/.*%.ya?ml"] = "yaml.ansible",
  },
})
