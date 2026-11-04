--- DAP setup: adapters, launch configurations, and visual state.
---
--- Kept out of lua/plugins/dap.lua so the plugin spec only describes loading
--- and UI options. Everything here runs when nvim-dap is first loaded.

local M = {}

local dap = require("dap")

-- ── Path discovery ────────────────────────────────────────────

local function mason_package(name)
  return vim.fn.stdpath("data") .. "/mason/packages/" .. name
end

---Return the first path that exists and is executable (or readable).
---@param paths string[]
---@return string?
local function first_existing(paths)
  for _, path in ipairs(paths) do
    if path and path ~= "" and (vim.fn.executable(path) == 1 or vim.fn.filereadable(path) == 1) then
      return path
    end
  end
end

---@return string
function M.codelldb_path()
  return first_existing({
    mason_package("codelldb") .. "/extension/adapter/codelldb",
    vim.fn.exepath("codelldb"),
  }) or "codelldb"
end

---@return string?
function M.codelldb_liblldb()
  local package = mason_package("codelldb")
  local sysname = vim.uv.os_uname().sysname
  local ext = sysname == "Darwin" and ".dylib" or sysname == "Windows_NT" and ".dll" or ".so"
  local path = package .. "/extension/lldb/lib/liblldb" .. ext
  if vim.fn.filereadable(path) == 1 then
    return path
  end
end

---@return string
local function delve_path()
  return first_existing({
    mason_package("delve") .. "/dlv",
    vim.fn.exepath("dlv"),
  }) or "dlv"
end

-- ── Adapters ──────────────────────────────────────────────────

---@return table
function M.codelldb_adapter()
  local args = { "--port", "${port}" }
  local liblldb = M.codelldb_liblldb()
  if liblldb then
    args = { "--liblldb", liblldb, "--port", "${port}" }
  end

  return {
    type = "server",
    host = "127.0.0.1",
    port = "${port}",
    executable = {
      command = M.codelldb_path(),
      args = args,
    },
  }
end

---@return table
local function delve_adapter()
  return {
    type = "server",
    host = "127.0.0.1",
    port = "${port}",
    executable = {
      command = delve_path(),
      args = { "dap", "-l", "127.0.0.1:${port}" },
    },
  }
end

-- ── Executable picker ─────────────────────────────────────────

local SEARCH_DIRS = {
  "target/debug",
  "target/release",
  "build",
  "build/bin",
  "bin",
  "out",
  "cmake-build-debug",
  "cmake-build-release",
  "zig-out/bin",
}

local IGNORED_EXTS = {
  o = true,
  a = true,
  so = true,
  dylib = true,
  dll = true,
  d = true,
  rlib = true,
  rmeta = true,
  pdb = true,
  txt = true,
  log = true,
  cmake = true,
  json = true,
  ninja = true,
  lock = true,
}

local SCRIPT_EXTS = {
  sh = true,
  bash = true,
  zsh = true,
  lua = true,
  py = true,
  pl = true,
  rb = true,
  js = true,
  ts = true,
  md = true,
}

---@param path string
---@return boolean
local function is_candidate(path)
  if vim.fn.isdirectory(path) == 1 or vim.fn.executable(path) ~= 1 then
    return false
  end

  local ext = vim.fn.fnamemodify(path, ":e"):lower()
  return not IGNORED_EXTS[ext] and not SCRIPT_EXTS[ext] and not path:match("/%.")
end

---@return string[]
local function binary_candidates()
  local cwd = vim.fn.getcwd()
  local found = {}
  local seen = {}

  local function add(path)
    if seen[path] or not is_candidate(path) then
      return
    end
    seen[path] = true
    found[#found + 1] = path
  end

  for _, dir in ipairs(SEARCH_DIRS) do
    local full_dir = cwd .. "/" .. dir
    if vim.fn.isdirectory(full_dir) == 1 then
      for _, file in ipairs(vim.fn.glob(full_dir .. "/*", false, true)) do
        add(file)
      end
    end
  end

  for _, file in ipairs(vim.fn.glob(cwd .. "/*", false, true)) do
    add(file)
  end

  return found
end

---@return string|table
local function prompt_path()
  local path = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
  return path ~= "" and path or dap.ABORT
end

---Return an executable path, or dap.ABORT when the user cancels.
---@return string|table
local function pick_binary()
  local candidates = binary_candidates()

  if #candidates == 0 then
    return prompt_path()
  end
  if #candidates == 1 then
    return candidates[1]
  end

  -- nvim-dap resolves function-valued configuration fields in a coroutine.
  -- If this is called from a normal callback, fall back to a plain prompt.
  local co = coroutine.running()
  if not co then
    return prompt_path()
  end

  local items = vim.deepcopy(candidates)
  items[#items + 1] = "Manually enter path..."

  local choice
  vim.ui.select(items, {
    prompt = "Select executable: ",
    format_item = function(item)
      return item == "Manually enter path..." and item or vim.fn.fnamemodify(item, ":.")
    end,
  }, function(item)
    choice = item
    coroutine.resume(co)
  end)

  coroutine.yield()

  if not choice then
    return dap.ABORT
  end
  if choice == "Manually enter path..." then
    return prompt_path()
  end
  return choice
end

-- ── Launch configurations ─────────────────────────────────────

---@return table[]
local function codelldb_configurations()
  return {
    {
      name = "Launch Binary (Smart Picker)",
      type = "codelldb",
      request = "launch",
      program = pick_binary,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},
    },
    {
      name = "Launch Binary with Arguments",
      type = "codelldb",
      request = "launch",
      program = pick_binary,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = function()
        local args = vim.fn.input("Arguments: ")
        return args == "" and {} or vim.split(args, "%s+", { trimempty = true })
      end,
    },
    {
      name = "Attach to Process",
      type = "codelldb",
      request = "attach",
      pid = function()
        return require("dap.utils").pick_process()
      end,
      cwd = "${workspaceFolder}",
    },
    {
      name = "Load Core Dump",
      type = "codelldb",
      request = "attach",
      program = pick_binary,
      coreDumpPath = function()
        local path = vim.fn.input("Path to core dump: ", vim.fn.getcwd() .. "/", "file")
        return path ~= "" and path or dap.ABORT
      end,
      cwd = "${workspaceFolder}",
    },
  }
end

---@return table[]
local function delve_configurations()
  return {
    {
      name = "Debug Current File",
      type = "delve",
      request = "launch",
      program = "${file}",
    },
    {
      name = "Debug Package",
      type = "delve",
      request = "launch",
      program = "${fileDirname}",
    },
    {
      name = "Debug Current File with Arguments",
      type = "delve",
      request = "launch",
      program = "${file}",
      args = function()
        local args = vim.fn.input("Arguments: ")
        return args == "" and {} or vim.split(args, "%s+", { trimempty = true })
      end,
    },
    {
      name = "Debug Test",
      type = "delve",
      request = "launch",
      mode = "test",
      program = "${file}",
    },
    {
      name = "Debug Test Package",
      type = "delve",
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}",
    },
    {
      name = "Attach to Process",
      type = "delve",
      request = "attach",
      mode = "local",
      processId = function()
        return require("dap.utils").pick_process()
      end,
    },
  }
end

-- ── Project frame restore ─────────────────────────────────────
--
-- Stepping into `println!` and other standard-library functions opens real
-- Rust sources from the toolchain. Those are ordinary editor buffers, so
-- closing the DAP session does not move the source window back to project
-- code. Remember the last frame inside the project and restore it when the
-- session ends while showing an external file.

local project_root
local session_origin
local last_user
local last_stop

---@param path? string
---@return string?
local function normalize(path)
  return path and path:gsub("\\", "/") or nil
end

---@param path? string
---@return boolean
local function is_external(path)
  path = normalize(path)
  if not path or path == "" then
    return false
  end

  -- Toolchain/package-manager sources are never the user's project files.
  -- Checking these explicitly also covers repositories opened from $HOME.
  if
    path:find("/.rustup/", 1, true)
    or path:find("/rustlib/", 1, true)
    or path:find("/.cargo/registry/", 1, true)
  then
    return true
  end

  local root = project_root
  return root ~= nil and root ~= "" and path ~= root and not vim.startswith(path, root .. "/")
end

---@param frame? dap.StackFrame
---@return table?
local function location(frame)
  local path = normalize(frame and frame.source and frame.source.path)
  if not path then
    return nil
  end
  return { path = path, line = frame.line, column = frame.column }
end

local function reset_project_frame()
  project_root = nil
  session_origin = nil
  last_user = nil
  last_stop = nil
end

---@param session dap.Session
local function on_initialized(session)
  reset_project_frame()

  local cwd = session.config and session.config.cwd
  if type(cwd) ~= "string" or cwd:find("${", 1, true) or vim.fn.isdirectory(cwd) ~= 1 then
    cwd = vim.fn.getcwd()
  end
  project_root = normalize(cwd):gsub("/+$", "")

  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype == "" then
    local path = normalize(vim.api.nvim_buf_get_name(bufnr))
    if path and path ~= "" and not is_external(path) then
      local cursor = vim.api.nvim_win_get_cursor(0)
      session_origin = { path = path, line = cursor[1], column = cursor[2] + 1 }
    end
  end
end

---Record the frame the debugger is about to display. The stack trace response
---is used instead of `current_frame` because the event listeners run before
---the session's coroutine finishes updating it.
---@param session dap.Session
---@param _? dap.ErrorResponse
---@param response? dap.StackTraceResponse
---@param request? dap.StackTraceArguments
local function on_stack_trace(session, _, response, request)
  local thread_id = request and request.threadId
  if session.stopped_thread_id and thread_id and thread_id ~= session.stopped_thread_id then
    return
  end

  local frames = response and response.stackFrames
  local top = frames and frames[1]
  if not top then
    return
  end

  local stop = location(top)
  if not stop then
    return
  end
  last_stop = stop

  if not is_external(stop.path) then
    last_user = stop
    return
  end

  -- Stepping into stdlib can push the project frame further down the stack.
  for _, frame in ipairs(frames) do
    local candidate = location(frame)
    if candidate and not is_external(candidate.path) then
      last_user = candidate
      return
    end
  end
end

local function is_dap_window(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local filetype = vim.bo[buf].filetype
  return vim.bo[buf].buftype ~= ""
    or filetype == "dap-view"
    or filetype == "dap-view-term"
    or filetype == "dap-repl"
end

---@param win number
---@return boolean
local function is_floating_window(win)
  return vim.api.nvim_win_get_config(win).relative ~= ""
end

---@param win number
---@param target table
---@return boolean
local function show_target(win, target)
  local buf = vim.fn.bufnr(target.path)
  if buf == -1 then
    buf = vim.fn.bufadd(target.path)
  end
  vim.fn.bufload(buf)

  local line = math.max(1, math.min(target.line or 1, vim.api.nvim_buf_line_count(buf)))
  local column = math.max((target.column or 1) - 1, 0)
  if not pcall(vim.api.nvim_win_set_buf, win, buf) then
    return false
  end
  pcall(vim.api.nvim_win_set_cursor, win, { line, column })
  return true
end

---Replace the external source in every window that displays it.
---@param target table
---@return number? window that was changed first
local function replace_external_windows(target)
  if not last_stop or not is_external(last_stop.path) then
    return nil
  end

  local external_buf = vim.fn.bufnr(last_stop.path)
  if external_buf == -1 then
    return nil
  end

  local changed
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    -- The DAP windows themselves never show source files, but skip winfixbuf
    -- and floating windows just in case.
    if
      vim.api.nvim_win_get_buf(win) == external_buf
      and not vim.wo[win].winfixbuf
      and not is_floating_window(win)
    then
      if show_target(win, target) then
        changed = changed or win
      end
    end
  end
  return changed
end

local function restore_project_frame()
  local target = last_user or session_origin
  if not target then
    return
  end
  replace_external_windows(target)
  last_stop = nil
end

---Jump the source window back to the last frame inside the project. Useful
---while the session is still stopped in stdlib, not only after it ends.
function M.focus_project_frame()
  local target = last_user or session_origin
  if not target then
    vim.notify("No project frame recorded for this session", vim.log.levels.INFO)
    return
  end

  local changed = replace_external_windows(target)
  if changed then
    vim.api.nvim_set_current_win(changed)
    return
  end

  local win = vim.api.nvim_get_current_win()
  if is_dap_window(win) then
    for _, candidate in ipairs(vim.api.nvim_list_wins()) do
      if not is_dap_window(candidate) and not is_floating_window(candidate) then
        if show_target(candidate, target) then
          vim.api.nvim_set_current_win(candidate)
        end
        return
      end
    end
    vim.notify("No source window is available", vim.log.levels.INFO)
    return
  end

  show_target(win, target)
end

-- ── Signs ─────────────────────────────────────────────────────

local function setup_signs()
  vim.fn.sign_define("DapBreakpoint", {
    text = "●",
    texthl = "DiagnosticError",
  })
  vim.fn.sign_define("DapBreakpointCondition", {
    text = "◆",
    texthl = "DiagnosticWarn",
  })
  vim.fn.sign_define("DapBreakpointRejected", {
    text = "✕",
    texthl = "DiagnosticError",
  })
  vim.fn.sign_define("DapLogPoint", {
    text = "◆",
    texthl = "DiagnosticInfo",
  })
  vim.fn.sign_define("DapStopped", {
    text = "▶",
    texthl = "DiagnosticOk",
    linehl = "DapStoppedLine",
  })

  vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
end

-- ── Setup ─────────────────────────────────────────────────────

local function setup_project_focus()
  local group = "core.dap.project_focus"
  dap.listeners.after.event_initialized[group] = on_initialized
  dap.listeners.after.stackTrace[group] = on_stack_trace
  dap.listeners.after.event_exited[group] = restore_project_frame
  dap.listeners.after.event_terminated[group] = restore_project_frame
end

function M.setup()
  setup_signs()
  setup_project_focus()

  dap.adapters.codelldb = M.codelldb_adapter()
  dap.adapters.lldb = vim.deepcopy(dap.adapters.codelldb)

  dap.adapters.delve = delve_adapter()
  dap.adapters.go = dap.adapters.delve

  local native = codelldb_configurations()
  dap.configurations.c = native
  dap.configurations.cpp = vim.deepcopy(native)
  dap.configurations.rust = vim.deepcopy(native)
  dap.configurations.go = delve_configurations()
end

return M
