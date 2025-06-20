local function get_cmd()
  local home = vim.fn.expand("~")
  local ls_jar = home .. "/.local/sonarlint/server/sonarlint-ls.jar"
  if vim.fn.filereadable(ls_jar) == 0 then
    vim.notify("sonarlint-ls.jar not found at " .. ls_jar, vim.log.levels.ERROR)
    return {}
  end

  local analyzers_dir = home .. "/.local/sonarlint/analyzers/"
  local analyzers = vim.fn.glob(analyzers_dir .. "*.jar", false, true)
  local cmd = { "java", "-jar", ls_jar, "-stdio" }
  if #analyzers > 0 then
    table.insert(cmd, "-analyzers")
    table.insert(cmd, table.concat(analyzers, ","))
  end
  return cmd
end

return {
  "iamkarasik/sonarqube.nvim",
  branch = "feat/cfamily",
  config = function()
    require("sonarqube").setup({
      lsp = {
        cmd = get_cmd(),
        log_level = "OFF",
      },
      cpp = {
        enabled = true,
      },
      json = {
        enabled = false,
      },
    })
  end,
}
