---Collect plugin specs from this directory for Lazy.
local specs = {}
for _, name in ipairs({ "lualine", "bufferline", "colorscheme", "windowpicker", "which_key", "snacks" }) do
  local mod = require("plugins.ui." .. name)
  if type(mod) == "table" then
    if mod[1] and type(mod[1]) == "table" then
      for _, s in ipairs(mod) do
        specs[#specs + 1] = s
      end
    else
      specs[#specs + 1] = mod
    end
  end
end
return specs
