local constants = require("constants")
local colors = constants.colors

SBar.bar({
  color = colors.transparent,
  border_color = colors.transparent,
  height = 32,
  y_offset = constants.spacing.sm,
  display = "main",
})
