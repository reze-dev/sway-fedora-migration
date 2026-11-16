-- ─── LSP capabilities ─────────────────────────────────────────
-- Blink.cmp advertises a few completion capabilities that servers rely on
-- (snippet support, resolve support, itemDefaults, ...). Inlining them here
-- lets us configure LSP without requiring blink.cmp at startup, which keeps
-- the completion engine out of the startup path entirely.
--
-- Mirrors blink.cmp's `get_lsp_capabilities()` (v1.x). Keep in sync when
-- upgrading blink.cmp.
local M = {}

M.blink = {
  textDocument = {
    completion = {
      completionItem = {
        snippetSupport = true,
        commitCharactersSupport = false,
        documentationFormat = { "markdown", "plaintext" },
        deprecatedSupport = true,
        preselectSupport = false,
        tagSupport = { valueSet = { 1 } },
        insertReplaceSupport = true,
        resolveSupport = {
          properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
            "command",
            "data",
          },
        },
        insertTextModeSupport = { valueSet = { 1 } },
        labelDetailsSupport = true,
      },
      completionList = {
        itemDefaults = {
          "commitCharacters",
          "editRange",
          "insertTextFormat",
          "insertTextMode",
          "data",
        },
      },
      contextSupport = true,
      insertTextMode = 1,
    },
  },
}

---@param capabilities table? defaults to Neovim's base client capabilities
function M.with_blink(capabilities)
  return vim.tbl_deep_extend("force", capabilities or vim.lsp.protocol.make_client_capabilities(), M.blink)
end

return M
