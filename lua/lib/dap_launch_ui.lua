---Interactive helpers for nvim-dap launch configurations:
---a fuzzy picker (with file preview) and a checkbox/value form that
---produce argument lists. Both are async and meant to be wrapped with
---`M.async_option` so they can be used as `args`/`program` values.
---@module 'lib.dap_launch_ui'
local M = {}

---@class lib.dap_launch_ui.PickItem
---@field text string Shown in the list and used for fuzzy matching.
---@field file? string Previewed on the right when set.

---@class lib.dap_launch_ui.Flag
---@field flag string Boolean switch, e.g. "-v".
---@field desc? string
---@field default? boolean

---@class lib.dap_launch_ui.Field
---@field flag string Option taking a value, e.g. "-w". An empty value omits the option.
---@field desc? string
---@field default? string

---@class lib.dap_launch_ui.FormSpec
---@field id string Key under which the last submitted values are remembered.
---@field title string
---@field header? string[] Informational lines shown above the form.
---@field flags lib.dap_launch_ui.Flag[]
---@field fields lib.dap_launch_ui.Field[]

local EXTRA_LABEL = "extra args"

---Remembered values per `FormSpec.id`, so re-opening a form shows the last run.
---@type table<string, { flags: table<string, boolean>, fields: table<string, string> }>
local memory = {}

---Wrap an async UI flow so it can be used as a function-valued nvim-dap option.
---`fn` receives `done(value)`; calling `done()` with `nil` aborts the launch.
---@generic T
---@param fn fun(done: fun(value?: T))
---@return fun(): thread
function M.async_option(fn)
  return function()
    return coroutine.create(function(dap_co)
      local finished = false
      fn(function(value)
        if finished then
          return
        end
        finished = true
        if value == nil then
          value = require("dap").ABORT
        end
        coroutine.resume(dap_co, value)
      end)
    end)
  end
end

---Fuzzy-pick one item; `cb(nil)` on cancel.
---@param opts { title: string, items: lib.dap_launch_ui.PickItem[] }
---@param cb fun(item?: lib.dap_launch_ui.PickItem)
function M.pick(opts, cb)
  local finished = false
  local function finish(item)
    if finished then
      return
    end
    finished = true
    vim.schedule(function()
      cb(item)
    end)
  end

  Snacks.picker.pick({
    source = "dap_launch_ui",
    title = opts.title,
    items = opts.items,
    format = "text",
    preview = "file",
    confirm = function(picker, item)
      -- close() runs on_close synchronously, which would record a cancel.
      finish(item)
      picker:close()
    end,
    on_close = function()
      finish(nil)
    end,
  })
end

local ns = vim.api.nvim_create_namespace("dap_launch_ui_form")

---@param spec lib.dap_launch_ui.FormSpec
---@return string[] lines
---@return table<integer, string> hints 1-based line -> description shown as virtual text
local function render(spec)
  local mem = memory[spec.id] or { flags = {}, fields = {} }
  local label_w = #EXTRA_LABEL
  for _, f in ipairs(spec.flags) do
    label_w = math.max(label_w, #f.flag)
  end
  for _, f in ipairs(spec.fields) do
    label_w = math.max(label_w, #f.flag)
  end
  local function pad(s)
    return s .. string.rep(" ", label_w - #s)
  end

  local lines = {}
  for _, h in ipairs(spec.header or {}) do
    lines[#lines + 1] = " " .. h
  end
  if #lines > 0 then
    lines[#lines + 1] = ""
  end
  for _, f in ipairs(spec.flags) do
    local on = mem.flags[f.flag]
    if on == nil then
      on = f.default or false
    end
    lines[#lines + 1] = string.format(" [%s] %s  %s", on and "x" or " ", pad(f.flag), f.desc or "")
  end
  if #spec.flags > 0 and #spec.fields > 0 then
    lines[#lines + 1] = ""
  end
  -- Field descriptions can't be part of the line (everything after `=` is the
  -- value), so they are attached as end-of-line virtual text.
  local hints = {}
  for _, f in ipairs(spec.fields) do
    local value = mem.fields[f.flag] or f.default or ""
    lines[#lines + 1] = string.format("     %s = %s", pad(f.flag), value)
    if f.desc then
      hints[#lines] = f.desc
    end
  end
  lines[#lines + 1] = string.format("     %s = %s", pad(EXTRA_LABEL), mem.fields[EXTRA_LABEL] or "")
  hints[#lines] = "whitespace separated, appended verbatim"
  return lines, hints
end

---Parse the edited buffer back into an argument list and update memory.
---@param spec lib.dap_launch_ui.FormSpec
---@param lines string[]
---@return string[] args
local function parse(spec, lines)
  local known = { [EXTRA_LABEL] = true }
  for _, f in ipairs(spec.fields) do
    known[f.flag] = true
  end

  local mem = { flags = {}, fields = {} }
  local flags, values = {}, {}
  for _, line in ipairs(lines) do
    local box, flag = line:match("^%s*%[(.)%]%s+(%S+)")
    if box then
      local on = box ~= " "
      mem.flags[flag] = on
      if on then
        flags[#flags + 1] = flag
      end
    else
      local key, value = line:match("^%s*(.-)%s*=%s*(.-)%s*$")
      if key and known[key] then
        mem.fields[key] = value
        values[key] = value
      end
    end
  end
  memory[spec.id] = mem

  local args = vim.deepcopy(flags)
  for _, f in ipairs(spec.fields) do
    local v = values[f.flag]
    if v and v ~= "" then
      args[#args + 1] = f.flag
      args[#args + 1] = v
    end
  end
  for _, part in ipairs(vim.split(values[EXTRA_LABEL] or "", "%s+", { trimempty = true })) do
    args[#args + 1] = part
  end
  return args
end

---Open a form window: `<Space>` toggles a checkbox, values are edited in place,
---`<CR>` (normal mode) submits, `q`/`<Esc>` aborts. `cb(nil)` on abort.
---@param spec lib.dap_launch_ui.FormSpec
---@param cb fun(args?: string[])
function M.form(spec, cb)
  local lines, hints = render(spec)
  local width = 0
  for i, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l) + (hints[i] and #hints[i] + 12 or 0))
  end
  width = math.min(math.max(width + 4, 60), vim.o.columns - 4)

  local finished = false
  local function finish(args)
    if finished then
      return
    end
    finished = true
    vim.schedule(function()
      cb(args)
    end)
  end

  local function toggle(self)
    local row = vim.api.nvim_win_get_cursor(self.win)[1]
    local line = vim.api.nvim_buf_get_lines(self.buf, row - 1, row, false)[1] or ""
    local new = line:gsub("^(%s*)%[ %]", "%1[x]", 1)
    if new == line then
      new = line:gsub("^(%s*)%[x%]", "%1[ ]", 1)
    end
    if new ~= line then
      vim.api.nvim_buf_set_lines(self.buf, row - 1, row, false, { new })
    end
  end

  local function submit(self)
    local buf_lines = vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)
    local args = parse(spec, buf_lines)
    finished = true
    self:close()
    vim.schedule(function()
      cb(args)
    end)
  end

  require("snacks.win")({
    text = lines,
    title = " " .. spec.title .. " ",
    border = "rounded",
    width = width,
    height = #lines,
    enter = true,
    footer_keys = true,
    bo = { filetype = "dap_launch_form", bufhidden = "wipe", buftype = "nofile" },
    wo = { cursorline = true, wrap = false },
    keys = {
      { "<Space>", toggle, desc = "toggle" },
      { "<CR>", submit, desc = "run", mode = { "n", "i" } },
      { "q", "close", desc = "abort" },
      { "<Esc>", "close", desc = "abort" },
    },
    on_close = function()
      finish(nil)
    end,
    on_buf = function(self)
      for row, desc in pairs(hints) do
        vim.api.nvim_buf_set_extmark(self.buf, ns, row - 1, 0, {
          virt_text = { { "  " .. desc, "Comment" } },
          virt_text_pos = "eol",
        })
      end
    end,
    on_win = function(self)
      -- Start on the first editable line rather than the header.
      local first = #(spec.header or {})
      first = first > 0 and first + 2 or 1
      vim.api.nvim_win_set_cursor(self.win, { math.min(first, #lines), 0 })
    end,
  })
end

---Convenience: pick an item, then show a form for it; `cb(nil)` on abort.
---@param pick_opts { title: string, items: lib.dap_launch_ui.PickItem[] }
---@param make_spec fun(item: lib.dap_launch_ui.PickItem): lib.dap_launch_ui.FormSpec
---@param cb fun(item?: lib.dap_launch_ui.PickItem, args?: string[])
function M.pick_then_form(pick_opts, make_spec, cb)
  M.pick(pick_opts, function(item)
    if not item then
      return cb(nil, nil)
    end
    M.form(make_spec(item), function(args)
      if not args then
        return cb(nil, nil)
      end
      cb(item, args)
    end)
  end)
end

return M
