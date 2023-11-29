return {
  "cdelledonne/vim-cmake",
  keys = {
    { "<Leader>cg", "<cmd>CMakeGenerate<cr>", desc = "Generate build system" },
    { "<Leader>cb", "<cmd>CMakeBuild<cr>", desc = "Build a project" },
  },
  opts = function()
    vim.g.cmake_build_dir_location = "./cmake-build-"
    vim.g.cmake_generate_options = {
      "-D CMAKE_C_COMPILER=reda-clang",
      "-D CMAKE_CXX_COMPILER=reda-clang++",
    }
  end,
}
