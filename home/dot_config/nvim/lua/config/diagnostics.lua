local icons = require('config.icons')

vim.diagnostic.config({
  severity_sort = true,
  float = function()
    return {
      source = false,
      suffix = '',
      prefix = '',
      max_width = math.floor(vim.o.columns * 0.5),
      max_height = math.floor(vim.o.lines * 0.25),
      format = function(diagnostic)
        if not diagnostic.source then return diagnostic.message end

        local code = diagnostic.code
          or vim.tbl_get(diagnostic, 'user_data', 'lsp', 'code')
        local suffix = code and (' [%s]'):format(code) or ''

        return ('%s\n(%s)%s'):format(
          diagnostic.message,
          diagnostic.source,
          suffix
        )
      end,
    }
  end,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      })
    end,
  },
  underline = {
    severity = {
      min = vim.diagnostic.severity.WARN,
    },
  },
  virtual_text = {
    severity = {
      min = vim.diagnostic.severity.WARN,
    },
    prefix = icons.ui.dot,
    severity_sort = true,
    source = false,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.lsp.error,
      [vim.diagnostic.severity.WARN] = icons.lsp.warn,
      [vim.diagnostic.severity.INFO] = icons.lsp.info,
      [vim.diagnostic.severity.HINT] = icons.lsp.hint,
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
      [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
      [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
    },
  },
})
