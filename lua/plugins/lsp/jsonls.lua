---Jsonls LSP server config (SchemaStore; project schemas live in per-project .nvim.lua).
---@return table
local function get()
  return {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        format = {
          enable = true,
        },
        validate = { enable = true },
      },
    },
  }
end

return { get = get }
