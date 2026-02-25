---Jsonls LSP server config (SchemaStore + project-specific schema).
---@return table
local function get()
  return {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas({
          extra = {
            {
              description = "Config schema",
              fileMatch = { "**/integrationtest/import_and_search/data/v2/**/config.json" },
              name = "config.json",
              url = "file:///Users/til.pockrandt/projects/reda-engine/libs/testruntime/schema/models/config_schema.json",
            },
          },
        }),
        format = {
          enable = true,
        },
        validate = { enable = true },
      },
    },
  }
end

return { get = get }
