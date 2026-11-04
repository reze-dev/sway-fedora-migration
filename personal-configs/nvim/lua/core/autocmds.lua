-- ─── Autocommands ─────────────────────────────────────────────
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Resize splits when window is resized
autocmd("VimResized", {
  group = augroup("ResizeSplits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Go to last cursor position when opening a file
autocmd("BufReadPost", {
  group = augroup("LastPosition", { clear = true }),
  callback = function(event)
    local exclude = { "gitcommit", "gitrebase", "hgcommit" }
    local buf = event.buf
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    if vim.bo[buf].buftype ~= "" then
      return
    end
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
      pcall(vim.cmd, "normal! zv")
    end
  end,
})

-- Close certain filetypes with q
autocmd("FileType", {
  group = augroup("CloseWithQ", { clear = true }),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns.blame",
    "grug-far",
    "help",
    "lspinfo",
    "man",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "oil",
    "qf",
    "snacks_win",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", function()
      pcall(vim.cmd, "close")
    end, { buffer = event.buf, silent = true, nowait = true, desc = "Close window" })
  end,
})

-- Auto create directories when saving a file
autocmd("BufWritePre", {
  group = augroup("AutoCreateDir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    local dir = vim.fn.fnamemodify(file, ":p:h")
    if not vim.uv.fs_stat(dir) then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- Remove trailing whitespace on save (opt-out via :TrimToggle, skips markdown)
vim.g.trim_whitespace = vim.g.trim_whitespace == nil and true or vim.g.trim_whitespace
vim.api.nvim_create_user_command("TrimToggle", function()
  vim.g.trim_whitespace = not vim.g.trim_whitespace
  vim.notify("Trim whitespace on save " .. (vim.g.trim_whitespace and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle trailing-whitespace trimming on save" })

autocmd("BufWritePre", {
  group = augroup("TrimWhitespace", { clear = true }),
  pattern = "*",
  callback = function(event)
    if not vim.g.trim_whitespace then
      return
    end
    local buf = event.buf
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    local ft = vim.bo[buf].filetype
    if ft == "markdown" or ft == "gitcommit" or ft == "diff" or ft == "patch" then
      return
    end
    -- Operate on the buffer being written, not whichever buffer happens to
    -- be current when the write is triggered from another window.
    vim.api.nvim_buf_call(buf, function()
      local view = vim.fn.winsaveview()
      pcall(function()
        vim.cmd([[keeppatterns %s/\s\+$//e]])
      end)
      vim.fn.winrestview(view)
    end)
  end,
})

-- Check if file changed when its window is focused
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("Checktime", { clear = true }),
  callback = function()
    if vim.bo.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Wrap and spell check in text filetypes
autocmd("FileType", {
  group = augroup("WrapSpell", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- ─── Filetype detection ──────────────────────────────────────
-- Neovim's runtime detects compose files as plain yaml; the compose language
-- service targets `yaml.docker-compose`, so route those files explicitly.
vim.filetype.add({
  pattern = {
    ["docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
    ["compose.*%.ya?ml"] = "yaml.docker-compose",
  },
})

-- Don't auto-continue comments with o/O or Enter
autocmd("FileType", {
  group = augroup("NoAutoComment", { clear = true }),
  pattern = { "*" },
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Terminal: no line numbers or signs. `:terminal` already enters insert mode,
-- so do not force `startinsert` here (it steals focus from floating terms).
local function auto_term_window_opts(win)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
end

local term_settings = augroup("TermSettings", { clear = true })

autocmd("TermOpen", {
  group = term_settings,
  callback = function(event)
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_buf(win) == event.buf then
      auto_term_window_opts(win)
    end
  end,
})

-- Covers terminals displayed after creation (e.g. from a hidden buffer).
autocmd("BufWinEnter", {
  group = term_settings,
  callback = function(event)
    if vim.bo[event.buf].buftype == "terminal" then
      auto_term_window_opts(vim.api.nvim_get_current_win())
    end
  end,
})

-- Big files: disable treesitter fold + heavy adornments for perf.
-- Window-local options are applied when the buffer is actually displayed.
local bigfile_group = augroup("BigFile", { clear = true })

autocmd("BufReadPre", {
  group = bigfile_group,
  callback = function(event)
    local ok, stat = pcall(vim.uv.fs_stat, event.match)
    if ok and stat and stat.size and stat.size > 1024 * 1024 then
      vim.b[event.buf].bigfile = true
      vim.b[event.buf].illuminate_disabled = true
    end
  end,
})

autocmd("BufWinEnter", {
  group = bigfile_group,
  callback = function(event)
    if not vim.b[event.buf].bigfile then
      return
    end
    local win = vim.api.nvim_get_current_win()
    vim.wo[win].foldmethod = "manual"
    vim.wo[win].foldexpr = "0"
    vim.wo[win].spell = false
  end,
})

-- Fix conceallevel for json files
autocmd("FileType", {
  group = augroup("JsonConceal", { clear = true }),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})
