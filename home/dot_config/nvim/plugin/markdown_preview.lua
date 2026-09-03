local config = {
  markdown_css_url = 'https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.2.0/github-markdown.min.css',
  marked_js_url = 'https://cdn.jsdelivr.net/npm/marked/marked.min.js',
  poll_interval_ms = 1000,
  debounce_ms = 250,
  ---@type table<string, string | false>
  keys = {
    preview = false,
  },
}

---@class MarkdownPreview
---@field group integer
---@field timer uv.uv_timer_t | vim.uv.Timer
---@field dir string
---@field html_path string
---@field js_path string

---@type table<integer, MarkdownPreview>
local active = {}

---@generic F: function
---@param fn F
---@param ms integer
---@return F debounced, uv.uv_timer_t | vim.uv.Timer timer
local function debounce(fn, ms)
  local timer = assert(vim.uv.new_timer(), 'failed creating a timer')
  local wrapped = function(...)
    local argc, args = select('#', ...), { ... }
    timer:stop()
    timer:start(ms, 0, function()
      vim.schedule(function()
        fn(unpack(args, 1, argc))
      end)
    end)
  end
  return wrapped, timer
end

---Create or truncate `path` and write `content`, looping on short writes.
---@param path string
---@param content string
local function write_file(path, content)
  vim.uv.fs_open(path, 'w', tonumber('644', 8), function(open_err, fd)
    if open_err or not fd then
      vim.schedule(function()
        vim.notify(
          'Markdown preview: cannot write '
            .. path
            .. ': '
            .. tostring(open_err),
          vim.log.levels.ERROR
        )
      end)
      return
    end

    local function write_at(offset)
      if offset >= #content then
        vim.uv.fs_close(fd)
        return
      end
      vim.uv.fs_write(
        fd,
        content:sub(offset + 1),
        offset,
        function(write_err, written)
          if write_err or not written or written == 0 then
            vim.uv.fs_close(fd)
            return
          end
          write_at(offset + written)
        end
      )
    end

    write_at(0)
  end)
end

-- Placeholders are substituted below; the CSS contains `%` so string.format is unusable.
local html_template = [[
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Markdown Preview</title>
  <link rel="stylesheet" href="__CSS_URL__">
  <script src="__MARKED_URL__"></script>
  <style>
    body {
      box-sizing: border-box;
      min-height: 100vh;
      margin: 0;
      padding: 45px;
      display: flex;
      justify-content: center;
      background-color: var(--color-canvas-subtle) !important;
    }
    .preview-container {
      box-sizing: border-box;
      min-width: 200px;
      max-width: 980px;
      width: 100%;
      padding: 45px;
      background-color: var(--color-canvas-default);
      border: 1px solid var(--color-border-default);
      border-radius: 6px;
      height: fit-content;
    }
    @media (max-width: 767px) {
      body { padding: 15px; }
      .preview-container { padding: 20px; }
    }
  </style>
</head>
<body class="markdown-body">
  <div id="content" class="preview-container">Loading...</div>
  <script>
    function render() {
      var el = document.getElementById('content');
      if (typeof window.md_content !== 'string') return;
      if (window.marked && typeof window.marked.parse === 'function') {
        el.style.whiteSpace = '';
        el.innerHTML = window.marked.parse(window.md_content, { breaks: true });
      } else {
        // marked.js did not load (offline?). Show the source instead of nothing.
        el.style.whiteSpace = 'pre-wrap';
        el.textContent = window.md_content;
      }
    }
    function update() {
      var old = document.getElementById('content-script');
      if (old) old.remove();
      var script = document.createElement('script');
      script.id = 'content-script';
      script.src = 'md_content.js?t=' + new Date().getTime();
      script.onload = render;
      document.head.appendChild(script);
    }
    setInterval(update, __POLL_MS__);
    update();
  </script>
</body>
</html>
]]

---@return string
local function render_html()
  local values = {
    CSS_URL = config.markdown_css_url,
    MARKED_URL = config.marked_js_url,
    POLL_MS = tostring(config.poll_interval_ms),
  }
  return (
    html_template:gsub('__(%u[%u_]*)__', function(key)
      return values[key]
    end)
  )
end

---@param bufnr integer
local function stop(bufnr)
  local preview = active[bufnr]
  if not preview then return end
  active[bufnr] = nil

  pcall(vim.api.nvim_del_augroup_by_id, preview.group)

  if not preview.timer:is_closing() then
    preview.timer:stop()
    preview.timer:close()
  end

  pcall(os.remove, preview.js_path)
  pcall(os.remove, preview.html_path)
  pcall(os.remove, preview.dir)
end

local function start()
  local bufnr = vim.api.nvim_get_current_buf()

  local existing = active[bufnr]
  if existing then
    vim.ui.open(vim.uri_from_fname(existing.html_path))
    return
  end

  local dir = vim.fn.tempname()
  local ok, mkdir_result = pcall(vim.fn.mkdir, dir, 'p')
  if not ok or mkdir_result == 0 then
    vim.notify(
      'Markdown preview: cannot create '
        .. dir
        .. ': '
        .. tostring(mkdir_result),
      vim.log.levels.ERROR
    )
    return
  end

  local html_path = vim.fs.joinpath(dir, 'preview.html')
  local js_path = vim.fs.joinpath(dir, 'md_content.js')

  local function write_content()
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    local text =
      table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')
    write_file(js_path, 'window.md_content = ' .. vim.json.encode(text) .. ';')
  end

  local write_debounced, timer = debounce(write_content, config.debounce_ms)

  write_file(html_path, render_html())
  write_content()

  local group = vim.api.nvim_create_augroup(
    'devastion.markdown_preview.' .. bufnr,
    { clear = true }
  )

  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    buffer = bufnr,
    group = group,
    callback = write_debounced,
  })

  vim.api.nvim_create_autocmd('BufWritePost', {
    buffer = bufnr,
    group = group,
    callback = write_content,
  })

  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
    buffer = bufnr,
    group = group,
    callback = function()
      stop(bufnr)
    end,
  })

  active[bufnr] = {
    group = group,
    timer = timer,
    dir = dir,
    html_path = html_path,
    js_path = js_path,
  }

  vim.ui.open(vim.uri_from_fname(html_path))
  vim.notify('Markdown preview started', vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('MDPreview', function()
  if vim.bo.filetype ~= 'markdown' then
    vim.notify('MDPreview requires a markdown buffer', vim.log.levels.WARN)
    return
  end
  start()
end, { desc = 'Preview the current markdown buffer in a browser' })

vim.api.nvim_create_user_command('MDPreviewStop', function()
  local bufnr = vim.api.nvim_get_current_buf()
  if not active[bufnr] then
    vim.notify(
      'No markdown preview running for this buffer',
      vim.log.levels.INFO
    )
    return
  end
  stop(bufnr)
  vim.notify('Markdown preview stopped', vim.log.levels.INFO)
end, { desc = 'Stop the markdown preview for the current buffer' })

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = vim.api.nvim_create_augroup(
    'devastion.markdown_preview',
    { clear = true }
  ),
  callback = function()
    for bufnr in pairs(active) do
      stop(bufnr)
    end
  end,
})

if config.keys.preview then
  vim.keymap.set(
    'n',
    config.keys.preview,
    '<cmd>MDPreview<cr>',
    { desc = 'Markdown preview' }
  )
end
