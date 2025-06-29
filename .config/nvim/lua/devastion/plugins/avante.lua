---@type LazySpec
return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = "*",
  opts = {
    provider = "openai",
    auto_suggestions_provider = "openai",
    providers = {
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o",
        timeout = 30000,
        max_tokens = 4096,
        extra_request_body = {
          temperature = 0,
        },
      },
    },
    behaviour = {
      auto_set_keymaps = false,
    },
    mappings = {
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        none = "c0",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
      sidebar = {
        apply_all = "A",
        apply_cursor = "a",
        retry_user_request = "r",
        edit_user_request = "e",
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
        remove_file = "d",
        add_file = "@",
        close = { "<Esc>", "q" },
        close_from_input = { normal = { "<Esc>", "q" }, insert = "<C-c>" },
      },
    },
    windows = {
      sidebar_header = {
        enabled = true,
        align = "right",
        rounded = false,
      },
      ask = {
        floating = true,
        border = "single",
        start_insert = false,
      },
      edit = {
        border = "single",
        start_insert = false,
      },
    },
    hints = { enabled = true },
  },
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "echasnovski/mini.icons",
  },
  keys = function()
    -- prefil edit window with common scenarios to avoid repeating query and submit immediately
    local prefill_edit_window = function(request)
      require("avante.api").edit()
      local code_bufnr = vim.api.nvim_get_current_buf()
      local code_winid = vim.api.nvim_get_current_win()
      if code_bufnr == nil or code_winid == nil then
        return
      end
      vim.api.nvim_buf_set_lines(code_bufnr, 0, -1, false, { request })
      -- Optionally set the cursor position to the end of the input
      vim.api.nvim_win_set_cursor(code_winid, { 1, #request + 1 })
      -- Simulate Ctrl+S keypress to submit
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-s>", true, true, true), "v", true)
    end

    -- NOTE: most templates are inspired from ChatGPT.nvim -> chatgpt-actions.json
    local avante_grammar_correction = "Correct the text to standard English, but keep any code blocks inside intact."
    local avante_keywords = "Extract the main keywords from the following text"
    local avante_code_readability_analysis = [[
      You must identify any readability issues in the code snippet.
      Some readability issues to consider:
      - Unclear naming
      - Unclear purpose
      - Redundant or obvious comments
      - Lack of comments
      - Long or complex one liners
      - Too much nesting
      - Long variable names
      - Inconsistent naming and code style.
      - Code repetition
      You may identify additional problems. The user submits a small section of code from a larger file.
      Only list lines with readability issues, in the format <line_num>|<issue and proposed solution>
      If there's no issues with code respond with only: <OK>
    ]]
    local avante_optimize_code = "Optimize the following code"
    local avante_summarize = "Summarize the following text"
    local avante_translate = "Translate this into Chinese, but keep any code blocks inside intact"
    local avante_explain_code = "Explain the following code"
    local avante_complete_code = "Complete the following codes written in " .. vim.bo.filetype
    local avante_add_docstring = "Add docstring to the following codes"
    local avante_fix_bugs = "Fix the bugs inside the following codes if any"
    local avante_add_tests = "Implement tests for the following code"

    return {
      {
        "<leader>aa",
        function() require("avante.api").ask() end,
        desc = "Ask",
      },
      {
        "<leader>ae",
        function() require("avante.api").edit() end,
        mode = "v",
        desc = "Edit",
      },
      {
        "<leader>ar",
        function() require("avante.api").refresh() end,
        desc = "Refresh",
      },
      {
        "<leader>at",
        function() require("avante").toggle() end,
        desc = "Toggle",
      },
      {
        "<leader>ag",
        function() require("avante.api").ask({ question = avante_grammar_correction }) end,
        desc = "Grammar Correction(ask)",
      },
      {
        "<leader>ak",
        function() require("avante.api").ask({ question = avante_keywords }) end,
        desc = "Keywords(ask)",
      },
      {
        "<leader>al",
        function() require("avante.api").ask({ question = avante_code_readability_analysis }) end,
        desc = "Code Readability Analysis(ask)",
      },
      {
        "<leader>ao",
        function() require("avante.api").ask({ question = avante_optimize_code }) end,
        desc = "Optimize Code(ask)",
      },
      {
        "<leader>am",
        function() require("avante.api").ask({ question = avante_summarize }) end,
        desc = "Summarize text(ask)",
      },
      {
        "<leader>an",
        function() require("avante.api").ask({ question = avante_translate }) end,
        desc = "Translate text(ask)",
      },
      {
        "<leader>ax",
        function() require("avante.api").ask({ question = avante_explain_code }) end,
        desc = "Explain Code(ask)",
      },
      {
        "<leader>ac",
        function() require("avante.api").ask({ question = avante_complete_code }) end,
        desc = "Complete Code(ask)",
      },
      {
        "<leader>ad",
        function() require("avante.api").ask({ question = avante_add_docstring }) end,
        desc = "Docstring(ask)",
      },
      {
        "<leader>ab",
        function() require("avante.api").ask({ question = avante_fix_bugs }) end,
        desc = "Fix Bugs(ask)",
      },
      {
        "<leader>au",
        function() require("avante.api").ask({ question = avante_add_tests }) end,
        desc = "Add Tests(ask)",
      },
      {
        "<leader>ag",
        function() prefill_edit_window(avante_grammar_correction) end,
        mode = "v",
        desc = "Grammar Correction",
      },
      {
        "<leader>ak",
        function() prefill_edit_window(avante_keywords) end,
        mode = "v",
        desc = "Keywords",
      },
      {
        "<leader>ao",
        function() prefill_edit_window(avante_optimize_code) end,
        mode = "v",
        desc = "Optimize Code(edit)",
      },
      {
        "<leader>ac",
        function() prefill_edit_window(avante_complete_code) end,
        mode = "v",
        desc = "Complete Code(edit)",
      },
      {
        "<leader>ad",
        function() prefill_edit_window(avante_add_docstring) end,
        mode = "v",
        desc = "Docstring(edit)",
      },
      {
        "<leader>ab",
        function() prefill_edit_window(avante_fix_bugs) end,
        mode = "v",
        desc = "Fix Bugs(edit)",
      },
      {
        "<leader>au",
        function() prefill_edit_window(avante_add_tests) end,
        mode = "v",
        desc = "Add Tests(edit)",
      },
    }
  end,
}
