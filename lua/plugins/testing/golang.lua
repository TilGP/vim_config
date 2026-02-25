---Neotest-golang adapter config for use in neotest opts.adapters["neotest-golang"].
---Module (not a Lazy spec); required by plugins.testing.init.
---Call get_config() at opts() time so vim.fn.getcwd() is correct.

---@return table Adapter config for neotest-golang.
local function get_config()
  return {
    go_test_args = {
      "-v",
      "-race",
      "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
    },
  }
end

return get_config
