---Neotest plugin spec; adapter config from plugins.testing.cpp and plugins.testing.golang (same dir as dap adapters).
local golang_get_config = require("plugins.testing.golang")

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "folke/snacks.nvim",
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/neotest-plenary",
      "fredrikaverpil/neotest-golang",
      require("plugins.testing.cpp"),
    },
    opts = function(_, opts)
      if vim.bo.filetype == "cpp" then
        table.insert(opts.adapters, "neotest-cpp")
      end

      if vim.bo.filetype == "go" then
        opts.adapters["neotest-golang"] = golang_get_config()
      end
    end,
  },
}
