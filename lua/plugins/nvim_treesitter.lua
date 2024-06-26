local script_dir = vim.fn.expand("%:p")

return {
    "nvim-treesitter/nvim-treesitter",
    opts = {
        ensure_installed = { "cpp", "python", "sql" },
    },
}
