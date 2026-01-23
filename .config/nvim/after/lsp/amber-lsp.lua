local function ensure_binary(name, install)
  if vim.fn.executable(name) == 1 then
    return
  end
  install()
end

local fn = vim.fn

local mason_root = fn.stdpath("data") .. "/mason"
local pkg_name = "amber-lsp"
local version = "0.1.16"

local pkg_dir = mason_root .. "/packages/" .. pkg_name
local bin_dir = mason_root .. "/bin"
local bin_path = bin_dir .. "/amber-lsp"

local url = "https://github.com/amber-lang/amber-lsp/releases/download/v"
  .. version
  .. "/amber-lsp-aarch64-apple-darwin.tar.gz"

local function install_amber_lsp()
  if fn.executable("amber-lsp") == 1 then
    return
  end

  fn.mkdir(pkg_dir, "p")
  fn.mkdir(bin_dir, "p")

  local archive = pkg_dir .. "/amber-lsp.tar.gz"

  -- download
  fn.system({
    "curl",
    "-fL",
    url,
    "-o",
    archive,
  })

  -- extract
  fn.system({
    "tar",
    "-xzf",
    archive,
    "-C",
    pkg_dir,
  })

  -- make executable (binary name is amber-lsp)
  fn.system({
    "chmod",
    "+x",
    pkg_dir .. "/amber-lsp-aarch64-apple-darwin/amber-lsp",
  })

  -- symlink into mason/bin
  fn.system({
    "cp",
    "-f",
    pkg_dir .. "/amber-lsp-aarch64-apple-darwin/amber-lsp",
    bin_path,
  })

  -- delete pkg dir
  fn.system({
    "rm",
    "-rf",
    pkg_dir,
  })
end

ensure_binary("amber-lsp", install_amber_lsp)

---@type vim.lsp.Config
return {
  cmd = { "amber-lsp" },
  filetypes = { "amber" },
}
