---@module 'lib'
local M = {}

---Require all .lua modules in a directory (except init.lua) and return their results as a list.
---@param module_path string Lua module path (e.g. "plugins.ui") whose directory to scan.
---@return table List of return values from each required module.
function M.require_plugin_specs(module_path)
  local dir = vim.fn.stdpath("config") .. "/lua/" .. module_path:gsub("%.", "/")
  local names = {}
  for name in vim.fs.dir(dir) do
    if name:match("%.lua$") and name ~= "init.lua" then
      names[#names + 1] = name:gsub("%.lua$", "")
    end
  end
  table.sort(names)
  local result = {}
  for _, mod in ipairs(names) do
    result[#result + 1] = require(module_path .. "." .. mod)
  end
  return result
end

---@param bool boolean
---@return string
local function bool2str(bool)
  return bool and "enabled" or "disabled"
end

---Returns true if running inside an SSH session, false otherwise.
---@return boolean
function M.is_ssh_session()
  return os.getenv("SSH_CLIENT") ~= nil
    or os.getenv("SSH_CONNECTION") ~= nil
    or os.getenv("SSH_TTY") ~= nil
end

---Open kitty docs for the first word on the current line.
function M.open_kitty_docs()
  local current_line = vim.fn.getline(".")
  local first_word = current_line:match("^%s*(%S+)")
  if first_word then
    local url = "https://sw.kovidgoyal.net/kitty/conf/#opt-kitty." .. first_word
    vim.fn.system({ "open", url })
  else
    print("No valid option found on the current line.")
  end
end

---Print file path, line/col, and filetype to a snacks notification.
function M.print_file_info()
  local snacks = require("snacks")
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")
  local total_lines = vim.fn.line("$")
  local col = vim.fn.col(".")
  local filetype = vim.bo.filetype
  local percent = math.floor((line / total_lines) * 100)

  local msg =
    string.format("%s\nline: %d of %d %d%% col: %d\nfiletype: %s", file, line, total_lines, percent, col, filetype)

  snacks.notify.info(msg)
end

---Open a Telescope picker to change the buffer's filetype.
function M.change_filetype_window()
  local actions = require("telescope.actions")
  local actions_state = require("telescope.actions.state")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local sorters = require("telescope.sorters")

  local function enter(prompt_bufnr)
    local selected = actions_state.get_selected_entry()
    actions.close(prompt_bufnr)

    vim.cmd("setfiletype " .. selected[1])

    local lsp = vim.lsp.get_clients()
    if next(lsp) == nil then
      return
    end

    vim.cmd([[LspRestart<cr>]])
  end

  local filetypes_list = vim.fn.getcompletion("", "filetype")

  local opts = {
    finder = finders.new_table(filetypes_list),
    sorter = sorters.get_generic_fuzzy_sorter({}),

    attach_mappings = function(_, map)
      map("i", "<CR>", enter)
      return true
    end,
  }

  local filetypes = pickers.new(opts, {})

  filetypes:find()
end

---Toggle buffer semantic token highlighting for all language servers that support it.
---@param bufnr? number Buffer to toggle the clients on (default: current).
function M.toggle_buffer_semantic_tokens(bufnr)
  bufnr = bufnr or 0
  vim.b[bufnr].semantic_tokens_enabled = not vim.b[bufnr].semantic_tokens_enabled
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens[vim.b[bufnr].semantic_tokens_enabled and "start" or "stop"](bufnr, client.id)
      vim.notify(string.format("Buffer lsp semantic highlighting %s", bool2str(vim.b[bufnr].semantic_tokens_enabled)))
    end
  end
end

---Find identifier under/before cursor, treating `_` and `-` as part of the word.
---Looks at the char under the cursor first, then the char before it (insert/cmdline friendly).
---@param line string
---@param cursor_col integer 0-based byte offset
---@return string|nil word
---@return integer|nil start_col 1-based byte column
---@return integer|nil end_col 1-based inclusive byte column
local function case_word_at(line, cursor_col)
  local function is_id(i)
    return i >= 1 and i <= #line and line:sub(i, i):match("[%w_%-]") ~= nil
  end

  local col
  if is_id(cursor_col + 1) then
    col = cursor_col + 1
  elseif is_id(cursor_col) then
    col = cursor_col
  else
    return nil
  end

  local start_col = col
  while start_col > 1 and is_id(start_col - 1) do
    start_col = start_col - 1
  end

  local end_col = col
  while end_col < #line and is_id(end_col + 1) do
    end_col = end_col + 1
  end

  return line:sub(start_col, end_col), start_col, end_col
end

---@return string line
---@return integer cursor_col 0-based byte offset
local function get_edit_line()
  if vim.fn.mode() == "c" then
    return vim.fn.getcmdline(), vim.fn.getcmdpos() - 1
  end
  return vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2]
end

---@param line string
---@param cursor_col integer 0-based byte offset
local function set_edit_line(line, cursor_col)
  if vim.fn.mode() == "c" then
    vim.fn.setcmdline(line, cursor_col + 1)
    return
  end
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_set_current_line(line)
  vim.api.nvim_win_set_cursor(0, { row, cursor_col })
end

---Split camelCase, kebab-case, or snake_case into lowercase parts.
---@param word string
---@return string[]
local function split_identifier(word)
  local normalized = word
    :gsub("([a-z0-9])([A-Z])", "%1 %2")
    :gsub("([A-Z]+)([A-Z][a-z])", "%1 %2")
    :gsub("[_%-]+", " ")
    :lower()

  local parts = {}
  for part in normalized:gmatch("%S+") do
    parts[#parts + 1] = part
  end
  return parts
end

---@param parts string[]
---@return string
local function to_camel_case(parts)
  local result = parts[1]
  for i = 2, #parts do
    result = result .. parts[i]:sub(1, 1):upper() .. parts[i]:sub(2)
  end
  return result
end

---@param parts string[]
---@param sep string
---@return string
local function join_parts(parts, sep)
  return table.concat(parts, sep)
end

---Convert the identifier under the cursor to camelCase, kebab-case, or snake_case.
---Works in normal, insert, and command-line mode.
---@param style "camel"|"kebab"|"snake"
function M.change_word_case(style)
  local line, cursor_col = get_edit_line()
  local word, start_col, end_col = case_word_at(line, cursor_col)
  if not word then
    vim.notify("No word under cursor", vim.log.levels.WARN)
    return
  end

  local parts = split_identifier(word)
  if #parts == 0 then
    return
  end

  local converted
  if style == "camel" then
    converted = to_camel_case(parts)
  elseif style == "kebab" then
    converted = join_parts(parts, "-")
  elseif style == "snake" then
    converted = join_parts(parts, "_")
  else
    error("unknown case style: " .. tostring(style))
  end

  if converted == word then
    return
  end

  local new_line = line:sub(1, start_col - 1) .. converted .. line:sub(end_col + 1)
  -- Place cursor after the converted word (natural for insert/cmdline).
  set_edit_line(new_line, start_col - 1 + #converted)
end

return M
