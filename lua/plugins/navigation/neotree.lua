return {
  "nvim-neo-tree/neo-tree.nvim",
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline", "edgy" },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
}
