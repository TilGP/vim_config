---@meta
s = require("luasnip.nodes.snippet").S
sn = require("luasnip.nodes.snippet").SN
isn = require("luasnip.nodes.snippet").ISN
t = require("luasnip.nodes.textNode").T
i = require("luasnip.nodes.insertNode").I
f = require("luasnip.nodes.functionNode").F
c = require("luasnip.nodes.choiceNode").C
d = require("luasnip.nodes.dynamicNode").D
r = require("luasnip.nodes.restoreNode").R
events = require("luasnip.util.events")
k = require("luasnip.nodes.key_indexer").new_key
ai = require("luasnip.nodes.absolute_indexer")
extras = require("luasnip.extras")
l = require("luasnip.extras").lambda
rep = require("luasnip.extras").rep
p = require("luasnip.extras").partial
m = require("luasnip.extras").match
n = require("luasnip.extras").nonempty
dl = require("luasnip.extras").dynamic_lambda
fmt = require("luasnip.extras.fmt").fmt
fmta = require("luasnip.extras.fmt").fmta
conds = require("luasnip.extras.expand_conditions")
postfix = require("luasnip.extras.postfix").postfix
types = require("luasnip.util.types")
parse = require("luasnip.util.parser").parse_snippet
ms = require("luasnip.nodes.multiSnippet").new_multisnippet

local function random_chars()
  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  math.randomseed(os.time())
  local result = ""
  for i = 1, 12 do
    local rand_index = math.random(#chars)
    result = result .. chars:sub(rand_index, rand_index)
  end
  return result
end

-- Function to generate the include guard
local function include_guard()
  local filename = vim.fn.expand("%:t:r"):upper() -- get filename without extension
  return filename .. "_HPP_" .. random_chars()
end

return {
  s("guard", {
    f(function()
      return "#ifndef " .. include_guard()
    end),
    t({ "", "#define " }),
    f(function()
      return include_guard()
    end),
    t({ "", "", "" }),
    i(0),
    t({ "", "", "#endif" }),
    f(function()
      return " // " .. include_guard()
    end),
  }),
  s(
    "gtest",
    fmt(
      [[
#include "gtest/gtest.h"

class {} : public ::testing::Test
{{
protected:
    void SetUp() override
    {{
        {}
    }}

    void TearDown() override
    {{
    }}
}};
]],
      {
        i(1, "TestName"), -- class name
        i(0), -- cursor position inside SetUp
      }
    )
  ),
}, {
  postfix(".ret", {
    f(function(_, parent)
      return "return " .. parent.snippet.env.POSTFIX_MATCH .. ";"
    end),
  }),
}
