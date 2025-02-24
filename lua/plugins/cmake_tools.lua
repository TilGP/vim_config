local function getNumberOfCores()
  local handle = io.popen("nproc")
  local result = handle:read("*a")
  handle:close()
  return tonumber(result)
end

local cmake_command = os.getenv("CMAKE_COMMAND") or "cmake"

return {
  "Civitasv/cmake-tools.nvim",
  lazy = true,
  keys = {
    { "<leader>cb", "<cmd>CMakeBuild<cr>", desc = "Build the configured target with cmake" },
  },
  init = function()
    local loaded = false
    local function check()
      local cwd = vim.uv.cwd()
      if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
        require("lazy").load({ plugins = { "cmake-tools.nvim" } })
        loaded = true
      end
    end
    check()
    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function()
        if not loaded then
          check()
        end
      end,
    })
  end,
  opts = {
    cmake_command = cmake_command,
    cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" }, -- this will be passed when invoke `CMakeGenerate`
    cmake_build_options = { "-j " .. getNumberOfCores() - 2 }, -- this will be passed when invoke `CMakeBuild`
  },
}
