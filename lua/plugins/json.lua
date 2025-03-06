return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "b0o/SchemaStore.nvim",
      lazy = true,
      version = false, -- last release is way too old
    },
  },
  opts = {
    -- make sure mason installs the server
    servers = {
      jsonls = {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas({
              extra = {
                {
                  description = "Config schema",
                  fileMatch = "**/config.json",
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
      },
    },
  },
}
