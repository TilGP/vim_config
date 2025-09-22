return -- lazy.nvim
{
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    ---@type table<string, snacks.win.Config>
    styles = {
      scratch = {
        width = 100,
        height = 30,
        bo = { buftype = "", buflisted = false, bufhidden = "hide", swapfile = false },
        minimal = false,
        noautocmd = false,
        -- position = "right",
        zindex = 20,
        wo = { winhighlight = "NormalFloat:Normal" },
        border = "rounded",
        title_pos = "center",
        footer_pos = "center",
      },
      minimal = {
        wo = {
          cursorcolumn = false,
          cursorline = false,
          cursorlineopt = "both",
          colorcolumn = "",
          fillchars = "eob: ,lastline:…",
          list = false,
          listchars = "extends:…,tab:  ",
          number = false,
          relativenumber = false,
          signcolumn = "no",
          spell = false,
          winbar = "",
          statuscolumn = "",
          wrap = false,
          sidescrolloff = 0,
        },
      },
    },
    win = {
      -- your win configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    bigfile = {
      notify = true, -- show notification when big file detected
      size = 5 * 1024 * 1024 * 1024,
      line_length = 1000, -- average line length (useful for minified files)
      -- Enable or disable features when big file detected
      ---@param ctx {buf: number, ft:string}
      setup = function(ctx)
        if vim.fn.exists(":NoMatchParen") ~= 0 then
          vim.cmd([[NoMatchParen]])
        end
        Snacks.util.wo(0, { foldmethod = "indent", statuscolumn = "", conceallevel = 0 })
        vim.b.minianimate_disable = true
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ctx.buf) then
            vim.bo[ctx.buf].syntax = ctx.ft
            Snacks.indent.disable()
          end
        end)
      end,
    },
    lazygit = {
      config = {
        git = {
          paging = {
            colorArg = "always",
            pager = 'delta --side-by-side --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"',
          },
        },
      },
    },
    indent = {
      enabled = true,
    },
  },
}
