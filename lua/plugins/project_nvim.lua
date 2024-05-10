return {
  "ahmedkhalf/project.nvim",
  opts = {
    manual_mode = false,
    silent_chdir = false,
    detection_methods = { "lsp", "pattern" },
    patterns = { ".git", ".project", ".project.lua", ".project.toml" },
    scope_chdir = "global",
  },
  event = "VeryLazy",
  config = function(_, opts)
    require("project_nvim").setup(opts)
    require("lazyvim.util").on_load("telescope.nvim", function()
      require("telescope").load_extension("projects")
    end)
  end,
  keys = {
    { "<leader>fp", "<Cmd>Telescope projects<CR>", desc = "Projects" },
  },
}
