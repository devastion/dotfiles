local map = require("devastion.utils").map

require("devastion.utils.pkg").add({
  {
    src = "monaqa/dial.nvim",
    data = {
      config = function()
        ---@param increment boolean
        ---@param g? boolean
        local function dial(increment, g)
          local mode = vim.fn.mode(true)
          -- Use visual commands for VISUAL 'v', VISUAL LINE 'V' and VISUAL BLOCK '\22'
          local is_visual = mode == "v" or mode == "V" or mode == "\22"
          local func = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
          local group = vim.g.dials_by_ft[vim.bo.filetype] or "default"
          return require("dial.map")[func](group)
        end

        map("<c-a>", function()
          return dial(true)
        end, "Increment", { "n", "v" }, { expr = true })
        map("<c-x>", function()
          return dial(false)
        end, "Decrement", { "n", "v" }, { expr = true })
        map("g<c-a>", function()
          return dial(true, true)
        end, "Increment", { "n", "x" }, { expr = true })
        map("g<c-x>", function()
          return dial(false, true)
        end, "Decrement", { "n", "x" }, { expr = true })

        local augend = require("dial.augend")

        local logical_alias = augend.constant.new({
          elements = { "&&", "||" },
          word = false,
          cyclic = true,
        })

        local ordinal_numbers = augend.constant.new({
          -- elements through which we cycle. When we increment, we go down
          -- On decrement we go up
          elements = {
            "first",
            "second",
            "third",
            "fourth",
            "fifth",
            "sixth",
            "seventh",
            "eighth",
            "ninth",
            "tenth",
          },
          -- if true, it only matches strings with word boundary. firstDate wouldn't work for example
          word = false,
          -- do we cycle back and forth (tenth to first on increment, first to tenth on decrement).
          -- Otherwise nothing will happen when there are no further values
          cyclic = true,
        })

        local weekdays = augend.constant.new({
          elements = {
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
            "Sunday",
          },
          word = true,
          cyclic = true,
        })

        local months = augend.constant.new({
          elements = {
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December",
          },
          word = true,
          cyclic = true,
        })

        local capitalized_boolean = augend.constant.new({
          elements = {
            "True",
            "False",
          },
          word = true,
          cyclic = true,
        })

        local enable_disable = augend.constant.new({
          elements = {
            "enable",
            "disable",
          },
          word = true,
          cyclic = true,
        })

        local on_off = augend.constant.new({
          elements = {
            "on",
            "off",
          },
          word = true,
          cyclic = true,
        })

        local dial_opts = {
          dials_by_ft = {
            css = "css",
            vue = "vue",
            javascript = "typescript",
            typescript = "typescript",
            typescriptreact = "typescript",
            javascriptreact = "typescript",
            json = "json",
            lua = "lua",
            markdown = "markdown",
            sass = "css",
            scss = "css",
            python = "python",
            php = "php",
          },
          groups = {
            default = {
              augend.integer.alias.decimal, -- nonnegative decimal number (0, 1, 2, 3, ...)
              augend.integer.alias.decimal_int, -- nonnegative and negative decimal number
              augend.integer.alias.hex, -- nonnegative hex number  (0x01, 0x1a1f, etc.)
              augend.date.alias["%Y/%m/%d"], -- date (2022/02/19, etc.)
              ordinal_numbers,
              weekdays,
              months,
              capitalized_boolean,
              augend.constant.alias.bool, -- boolean value (true <-> false)
              logical_alias,
              enable_disable,
              on_off,
            },
            vue = {
              augend.constant.new({ elements = { "let", "const" } }),
              augend.hexcolor.new({ case = "lower" }),
              augend.hexcolor.new({ case = "upper" }),
            },
            typescript = {
              augend.constant.new({ elements = { "let", "const" } }),
            },
            css = {
              augend.hexcolor.new({
                case = "lower",
              }),
              augend.hexcolor.new({
                case = "upper",
              }),
            },
            markdown = {
              augend.constant.new({
                elements = { "[ ]", "[x]" },
                word = false,
                cyclic = true,
              }),
              augend.misc.alias.markdown_header,
            },
            json = {
              augend.semver.alias.semver, -- versioning (v1.1.2)
            },
            lua = {
              augend.constant.new({
                elements = { "and", "or" },
                word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
                cyclic = true, -- "or" is incremented into "and".
              }),
            },
            python = {
              augend.constant.new({
                elements = { "and", "or" },
              }),
            },
            php = {
              augend.constant.new({
                elements = {
                  "public",
                  "private",
                  "protected",
                },
                words = true,
                cyclic = true,
              }),
            },
          },
        }

        for name, group in pairs(dial_opts.groups) do
          if name ~= "default" then
            vim.list_extend(group, dial_opts.groups.default)
          end
        end
        require("dial.config").augends:register_group(dial_opts.groups)
        vim.g.dials_by_ft = dial_opts.dials_by_ft
      end,
    },
  },
})
