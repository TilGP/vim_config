if require("lib").is_ssh_session() then
  return {
    "ojroques/nvim-osc52",
    config = function()
      require("osc52").setup({
        max_length = 0,
        silent = false,
        trim = false,
      })

      local function copy()
        require("osc52").copy_register("+")
      end

      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          if vim.v.event.operator == "y" and vim.v.event.regname == "+" then
            copy()
          end
        end,
      })
    end,
  }
else
  return {}
end
