return {
  "nvim-neotest/neotest",
  dependencies = { "nvim-neotest/nvim-nio", "alfaix/neotest-gtest", "orjangj/neotest-ctest" },
  opts = {
    -- Can be a list of adapters like what neotest expects,
    -- or a list of adapter names,
    -- or a table of adapter names, mapped to adapter configs.
    -- The adapter will then be automatically loaded with the config.
    adapters = {
      require("neotest-ctest").setup({
        -- fun(string) -> string: Find the project root directory given a current directory
        -- to work from.
        root = function(dir)
          -- by default, it will use neotest.lib.files.match_root_pattern with the following entries
          return require("neotest.lib").files.match_root_pattern(
            -- NOTE: CMakeLists.txt is not a good candidate as it can be found in
            -- more than one directory
            "CMakePresets.json",
            "compile_commands.json",
            ".clangd",
            ".clang-format",
            ".clang-tidy",
            "build",
            "out",
            ".git"
          )(dir)
        end,

        -- fun(string) -> bool: Takes a file path as string and returns true if it contains tests.
        -- This function is called often by neotest, so make sure you don't do any heavy duty work.
        is_test_file = function(file)
          if file:match("_test.cpp$") or file:match(".test.cpp$") or file:match("^tst-") then
            return true
          end
          return false
        end,

        -- fun(string, string, string) -> bool: Filter directories when searching for test files.
        -- Best to keep this as-is and set per-project settings in neotest instead.
        -- See :h neotest.Config.discovery.
        filter_dir = function(name, rel_path, root)
          -- If you don't configure filter_dir through neotest, and you leave it as-is,
          -- it will filter the following directories by default: build, cmake, doc,
          -- docs, examples, out, scripts, tools, venv.
        end,

        -- What frameworks to consider when performing auto-detection of test files.
        -- Priority can be configured by ordering/removing list items to your needs.
        -- By default, each test file will be queried with the given frameworks in the
        -- following order.
        frameworks = { "gtest", "catch2", "doctest" },

        -- What extra args should ALWAYS be sent to CTest? Note that most of CTest arguments
        -- are not expected to be used (or work) with this plugin, but some might be useful
        -- depending on your needs. For instance:
        --   extra_args = {
        --     "--stop-on-failure",
        --     "--schedule-random",
        --     "--timeout",
        --     "<seconds>",
        --   }
        -- If you want to send extra_args for one given invocation only, send them to
        -- `neotest.run.run({extra_args = ...})` instead. see :h neotest.RunArgs for details.
        extra_args = {},
      }),
      -- require("neotest-gtest").setup({}),
    },
    -- Example for loading neotest-go with a custom config
    -- adapters = {
    --   ["neotest-go"] = {
    --     args = { "-tags=integration" },
    --   },
    -- },
    status = { virtual_text = true },
    output = { open_on_run = true },
    quickfix = {
      open = function()
        if LazyVim.has("trouble.nvim") then
          require("trouble").open({ mode = "quickfix", focus = false })
        else
          vim.cmd("copen")
        end
      end,
    },
  },
  config = function(_, opts)
    local neotest_ns = vim.api.nvim_create_namespace("neotest")
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          -- Replace newline and tab characters with space for more compact diagnostics
          local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          return message
        end,
      },
    }, neotest_ns)

    if LazyVim.has("trouble.nvim") then
      opts.consumers = opts.consumers or {}
      -- Refresh and auto close trouble after running tests
      ---@type neotest.Consumer
      opts.consumers.trouble = function(client)
        client.listeners.results = function(adapter_id, results, partial)
          if partial then
            return
          end
          local tree = assert(client:get_position(nil, { adapter = adapter_id }))

          local failed = 0
          for pos_id, result in pairs(results) do
            if result.status == "failed" and tree:get_key(pos_id) then
              failed = failed + 1
            end
          end
          vim.schedule(function()
            local trouble = require("trouble")
            if trouble.is_open() then
              trouble.refresh()
              if failed == 0 then
                trouble.close()
              end
            end
          end)
          return {}
        end
      end
    end

    if opts.adapters then
      local adapters = {}
      for name, config in pairs(opts.adapters or {}) do
        if type(name) == "number" then
          if type(config) == "string" then
            config = require(config)
          end
          adapters[#adapters + 1] = config
        elseif config ~= false then
          local adapter = require(name)
          if type(config) == "table" and not vim.tbl_isempty(config) then
            local meta = getmetatable(adapter)
            if adapter.setup then
              adapter.setup(config)
            elseif meta and meta.__call then
              adapter(config)
            else
              error("Adapter " .. name .. " does not support setup")
            end
          end
          adapters[#adapters + 1] = adapter
        end
      end
      opts.adapters = adapters
    end

    require("neotest").setup(opts)
  end,
  -- stylua: ignore
  keys = {
    {"<leader>t", "", desc = "+test"},
    { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File" },
    { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All Test Files" },
    { "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest" },
    { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last" },
    { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary" },
    { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },
    { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
    { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop" },
    { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle Watch" },
  },
}
