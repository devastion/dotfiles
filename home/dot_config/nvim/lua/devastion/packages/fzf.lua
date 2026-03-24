local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  "nvim-mini/mini.icons",
  {
    src = "ibhagwan/fzf-lua",
    data = {
      config = function()
        local fzf = require("fzf-lua")
        local actions = fzf.actions

        fzf.register_ui_select()

        local img_previewer ---@type string[]?
        for _, v in ipairs({
          { cmd = "ueberzug", args = {} },
          { cmd = "chafa", args = { "{file}", "--format=symbols" } },
          { cmd = "viu", args = { "-b" } },
        }) do
          if vim.fn.executable(v.cmd) == 1 then
            img_previewer = vim.list_extend({ v.cmd }, v.args)
            break
          end
        end

        fzf.setup({
          { "fzf-native", "hide" },
          keymap = {
            builtin = {
              ["<c-f>"] = "preview-page-down",
              ["<c-b>"] = "preview-page-up",
            },
            fzf = {
              ["ctrl-q"] = "select-all+accept",
              ["ctrl-u"] = "half-page-up",
              ["ctrl-d"] = "half-page-down",
              ["ctrl-x"] = "jump",
              ["ctrl-f"] = "preview-page-down",
              ["ctrl-b"] = "preview-page-up",
              ["alt-j"] = "preview-down",
              ["alt-k"] = "preview-up",
            },
          },
          fzf_colors = true,
          fzf_opts = {
            ["--no-scrollbar"] = true,
          },
          defaults = {
            formatter = "path.dirname_first",
          },
          previewers = {
            builtin = {
              extensions = {
                ["png"] = img_previewer,
                ["jpg"] = img_previewer,
                ["jpeg"] = img_previewer,
                ["gif"] = img_previewer,
                ["webp"] = img_previewer,
              },
              ueberzug_scaler = "fit_contain",
            },
          },
          winopts = function()
            return {
              width = vim.o.columns < 160 and 1.0 or 0.80,
              height = vim.o.columns < 160 and 1.0 or 0.80,
              row = 0.5,
              col = 0.5,
              preview = {
                default = "bat_native",
                scrollchars = { "┃", "" },
                wrap = true,
              },
            }
          end,
          files = {
            cwd_prompt = false,
            actions = {
              ["alt-i"] = { actions.toggle_ignore },
              ["alt-h"] = { actions.toggle_hidden },
            },
          },
          grep = {
            actions = {
              ["alt-i"] = { actions.toggle_ignore },
              ["alt-h"] = { actions.toggle_hidden },
            },
          },
          lsp = {
            code_actions = { previewer = "codeaction_native" },
          },
          oldfiles = {
            cwd_only = true,
            include_current_session = true,
            winopts = {
              preview = {
                hidden = true,
              },
            },
          },
          undotree = {
            previewer = "undotree_native",
            locate = true,
          },
          autocmds = {
            previewer = "hide",
          },
          marks = {
            marks = "%a",
          },
        })

        map("<leader>:", function()
          require("fzf-lua").command_history()
        end, "Command History")

        map("<leader>U", function()
          require("fzf-lua").undotree()
        end, "Undotree")

        -- Find
        map("<leader>ff", function()
          require("fzf-lua").files()
        end, "Files (root)")

        map("<leader>fF", function()
          require("fzf-lua").files({ cwd = require("devastion.utils.path").get_cwd() })
        end, "Files (cwd)")

        map("<leader>fg", function()
          require("fzf-lua").git_files()
        end, "Git Files (root)")

        map("<leader>fG", function()
          require("fzf-lua").git_files({ cwd = require("devastion.utils.path").get_cwd() })
        end, "Git Files (cwd)")

        map("<leader>fb", function()
          require("fzf-lua").buffers()
        end, "Buffers (root)")

        map("<leader>fB", function()
          require("fzf-lua").buffers({ cwd = require("devastion.utils.path").get_cwd() })
        end, "Buffers (cwd)")

        map("<leader>fg", function()
          require("fzf-lua").git_files()
        end, "Git Files")

        map("<leader>fr", function()
          require("fzf-lua").oldfiles()
        end, "Recent Files")

        map("<leader>fT", function()
          require("fzf-lua").filetypes()
        end, "File Types")

        map("<leader>f<tab>", function()
          require("fzf-lua").tabs()
        end, "Tabs")

        -- Search
        map("<leader>sg", function()
          require("fzf-lua").live_grep()
        end, "Live Grep")

        map("<leader>sg", function()
          require("fzf-lua").grep_visual()
        end, "Visual Grep", "v")

        map("<leader>sm", function()
          require("fzf-lua").marks()
        end, "Marks")

        map("<leader>s'", function()
          require("fzf-lua").marks()
        end, "Marks")

        map('<leader>s"', function()
          require("fzf-lua").registers()
        end, "Registers")

        map("<leader>sa", function()
          require("fzf-lua").autocmds()
        end, "Autocommands")

        map("<leader>sb", function()
          require("fzf-lua").lgrep_curbuf()
        end, "Grep Buffer")

        map("<leader>sB", function()
          require("fzf-lua").builtin()
        end, "Builtin Commands")

        map("<leader>sc", function()
          require("fzf-lua").commands()
        end, "Commands")

        map("<leader>sd", function()
          require("fzf-lua").diagnostics_workspace({ severity_limit = vim.diagnostic.severity.WARN })
        end, "Diagnostics (Workspace)")

        map("<leader>sD", function()
          require("fzf-lua").diagnostics_document({ severity_limit = vim.diagnostic.severity.WARN })
        end, "Diagnostics (Document)")

        map("<leader>sh", function()
          require("fzf-lua").help_tags()
        end, "Help Tags")

        map("<leader>sH", function()
          require("fzf-lua").highlights()
        end, "Highlights")

        map("<leader>sj", function()
          require("fzf-lua").jumps()
        end, "Jumps")

        map("<leader>sk", function()
          require("fzf-lua").keymaps()
        end, "Keymaps")

        map("<leader>sl", function()
          require("fzf-lua").loclist()
        end, "Location List")

        map("<leader>sM", function()
          require("fzf-lua").man_pages()
        end, "Man Pages")

        map("<leader>sq", function()
          require("fzf-lua").quickfix()
        end, "Quickfix List")

        map("<leader>sr", function()
          require("fzf-lua").resume()
        end, "Resume")

        map("<leader>sR", function()
          require("fzf-lua").grep_last()
        end, "Repeat Grep")

        map("<leader>sw", function()
          require("fzf-lua").grep_cword()
        end, "Grep Word")

        map("<leader>sW", function()
          require("fzf-lua").grep_cWORD()
        end, "Grep WORD")

        -- Git
        map("<leader>gb", function()
          require("fzf-lua").git_blame()
        end, "Blame")

        map("<leader>gB", function()
          require("fzf-lua").git_branches()
        end, "Branches")

        map("<leader>gs", function()
          require("fzf-lua").git_status()
        end, "Status")

        map("<leader>gS", function()
          require("fzf-lua").git_stash()
        end, "Stash")

        map("<leader>gl", function()
          require("fzf-lua").git_commits()
        end, "Log")

        map("<leader>gL", function()
          require("fzf-lua").git_bcommits()
        end, "Log (File)")

        map("<leader>gt", function()
          require("fzf-lua").git_tags()
        end, "Tags")

        map("<leader>gd", function()
          require("fzf-lua").git_diff()
        end, "Diff")
      end,
    },
  },
})
