---Groovyls LSP server config.
---@return table
local function get()
  return {
    cmd = {
      "java",
      "-jar",
      "groovy-langauge-server-all.jar",
    },
  }
end

return { get = get }
