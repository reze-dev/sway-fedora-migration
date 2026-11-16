--- Buffer switching helpers for windows that refuse buffer changes ('winfixbuf').
---
--- Plugins such as nvim-dap-view, neotest, and gitsigns intentionally set
--- 'winfixbuf' on their windows. Commands like `:buffer`, bufferline's mouse
--- handler, and nvim_set_current_buf() then fail with E1513. These helpers
--- route the switch to a normal window instead.

local M = {}

local api = vim.api

---@param win integer
---@return boolean
local function can_switch(win)
  -- Floating windows are not part of the editing layout.
  return api.nvim_win_get_config(win).relative == "" and not vim.wo[win].winfixbuf
end

---Return a window that can display a normal buffer, preferring the current
---tabpage and then other tabpages.
---@return integer? win
---@return integer? tabpage
function M.target_win()
  local current = api.nvim_get_current_win()
  if can_switch(current) then
    return current
  end

  local current_tab = api.nvim_get_current_tabpage()
  for _, win in ipairs(api.nvim_tabpage_list_wins(current_tab)) do
    if win ~= current and can_switch(win) then
      return win
    end
  end

  for _, tab in ipairs(api.nvim_list_tabpages()) do
    if tab ~= current_tab then
      for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
        if can_switch(win) then
          return win, tab
        end
      end
    end
  end
end

---Focus a normal window, creating a new tab if every window is fixed.
---@return integer
local function ensure_win()
  local win, tab = M.target_win()
  if win then
    if tab then
      api.nvim_set_current_tabpage(tab)
    end
    api.nvim_set_current_win(win)
    return win
  end

  -- The user closed every editor while a fixed window (e.g. the debugger UI)
  -- stayed open. A new tab guarantees a usable normal window.
  vim.cmd("tabnew")
  return api.nvim_get_current_win()
end

---Open `bufnr`, using a normal window when the current one is fixed.
---@param bufnr integer
---@return boolean
function M.open(bufnr)
  bufnr = tonumber(bufnr) or bufnr
  if type(bufnr) ~= "number" or not api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local win = ensure_win()
  local ok = pcall(api.nvim_win_set_buf, win, bufnr)
  if not ok then
    vim.notify(("Cannot open buffer %d"):format(bufnr), vim.log.levels.WARN)
  end
  return ok
end

---Cycle through bufferline's visible buffers.
---@param direction integer
function M.cycle(direction)
  local win = ensure_win()

  local ok, bufferline = pcall(require, "bufferline")
  if ok then
    local elements = bufferline.get_elements().elements or {}
    if #elements > 0 then
      local current = api.nvim_get_current_buf()
      local index
      for i, element in ipairs(elements) do
        if element.id == current then
          index = i
          break
        end
      end

      if not index then
        index = direction > 0 and 0 or (#elements + 1)
      end

      index = index + direction
      if index < 1 then
        index = #elements
      elseif index > #elements then
        index = 1
      end

      local target = elements[index]
      if target and target.id and pcall(api.nvim_win_set_buf, win, target.id) then
        return
      end
    end
  end

  -- Fallback for the first keypress, before bufferline has rendered its list.
  pcall(vim.cmd, direction > 0 and "bnext" or "bprev")
end

return M
