-- ─── DAP — Debug Adapter Protocol ─────────────────────────────
--
-- nvim-dap is the single lazy entry point for the whole debugger stack:
-- pressing any DAP key (or running a DAP command) loads nvim-dap and its
-- UI/config dependencies together. Keeping dap-view loaded with nvim-dap
-- (instead of lazy-loading it on its own commands) also means auto_toggle
-- works on the very first session.
--
-- The UI deliberately uses one dap-view window with the console embedded as
-- a section. A separate terminal window can become the last window in a tab,
-- and dap-view's cleanup then fails with E444 when it tries to hide it.
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "igorlfs/nvim-dap-view",
        opts = {
          winbar = {
            show = true,
            -- Skip the "(S)/(W)..." key hints: with them the section list is
            -- wider than 80 columns and the leading sections get clipped.
            show_keymap_hints = false,
            base_sections = {
              watches = { label = "Watch" },
              threads = { label = "Stack" },
              breakpoints = { label = "Breaks" },
            },
            sections = { "scopes", "watches", "threads", "breakpoints", "repl", "console", "exceptions" },
            default_section = "scopes",
            controls = {
              enabled = true,
              position = "right",
              buttons = { "play", "step_into", "step_over", "step_out", "step_back", "term_restart" },
              custom_buttons = {
                -- Left click terminates; a modified/double click disconnects.
                -- With no session, it re-runs the last configuration.
                term_restart = {
                  render = function(session)
                    local group = session and "ControlTerminate" or "ControlRunLast"
                    local icon = session and "\u{f04d}" or "\u{ead2}"
                    return "%#NvimDapView" .. group .. "#" .. icon .. "%*"
                  end,
                  action = function(clicks, button, modifiers)
                    local dap = require("dap")
                    local alt = clicks > 1 or button ~= "l" or modifiers:gsub(" ", "") ~= ""
                    if not dap.session() then
                      dap.run_last()
                    elseif alt then
                      dap.disconnect()
                    else
                      dap.terminate()
                    end
                  end,
                },
              },
            },
          },
          -- Keep the debugger in a stable bottom panel. A right sidebar
          -- truncates the winbar (sections and controls) on normal terminal
          -- widths, which hides most of the UI.
          windows = { position = "below", size = 12 },
          -- Open automatically, but don't close when the program exits. The
          -- console output and the last stack/variables stay available until
          -- the user toggles the UI closed.
          auto_toggle = "open",
        },
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          enabled = true,
          enabled_commands = true,
          highlight_changed_variables = true,
          highlight_new_as_changed = false,
          show_stop_reason = true,
          commented = false,
          only_first_definition = true,
          all_references = false,
          clear_on_continue = false,
          virt_text_pos = "eol",
          all_frames = false,
          virt_lines = false,
          virt_text_win_col = nil,
        },
      },
      {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        config = function()
          -- Prefer Mason's debugpy venv; fall back to the system interpreter.
          local mason_venv = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
          local python = vim.fn.filereadable(mason_venv) == 1 and mason_venv or vim.fn.exepath("python3")
          require("dap-python").setup(python)
        end,
      },
    },
    cmd = {
      "DapContinue",
      "DapNew",
      "DapPause",
      "DapRestartFrame",
      "DapRunLast",
      "DapSetLogLevel",
      "DapShowLog",
      "DapStepInto",
      "DapStepOut",
      "DapStepOver",
      "DapTerminate",
      "DapToggleBreakpoint",
      "DapToggleRepl",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: toggle breakpoint" },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "DAP: conditional breakpoint",
      },
      { "<leader>dc", function() require("dap").continue() end, desc = "DAP: continue" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "DAP: run to cursor" },
      { "<leader>di", function() require("dap").step_into() end, desc = "DAP: step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "DAP: step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "DAP: step out" },
      { "<leader>dp", function() require("dap").pause() end, desc = "DAP: pause" },
      { "<leader>dr", function() require("dap").restart() end, desc = "DAP: restart" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "DAP: run last" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "DAP: terminate" },
      { "<leader>du", function() require("dap-view").toggle() end, desc = "DAP: toggle UI" },
      {
        "<leader>df",
        function()
          require("core.dap").focus_project_frame()
        end,
        desc = "DAP: focus project frame",
      },
      {
        "<leader>de",
        function()
          require("dap-view").add_expr()
        end,
        desc = "DAP: eval expression",
        mode = { "n", "v" },
      },
      { "<leader>dw", function() require("dap-view").hover() end, desc = "DAP: hover value" },
    },
    config = function()
      require("core.dap").setup()
    end,
  },
}
