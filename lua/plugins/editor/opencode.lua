return {
  {
    "nvim-lua/plenary.nvim",
    load_before = "opencode.nvim",
  },
  {
    "sudo-tee/opencode.nvim",
    event = "DeferredUIEnter",
    cmd = {
      "OpencodeOpen",
      "OpencodeAsk",
      "OpencodeExplain",
      "OpencodeRefactor",
      "OpencodeFix",
      "OpencodeTest",
    },
    opts = {
      -- Opencode 的自定义选项
      enable_signs = true,
      auto_scroll = true,
      default_global_keymaps = false,

      keymap = {
        editor = {
          ["<leader>ag"] = { "toggle" }, -- Open opencode. Close if opened
          ["<leader>ai"] = { "open_input" }, -- Opens and focuses on input window on insert mode
          ["<leader>aI"] = { "open_input_new_session" }, -- Opens and focuses on input window on insert mode. Creates a new session
          ["<leader>ao"] = { "open_output" }, -- Opens and focuses on output window
          ["<leader>at"] = { "toggle_focus" }, -- Toggle focus between opencode and last window
          ["<leader>aT"] = { "timeline" }, -- Display timeline picker to navigate/undo/redo/fork messages
          ["<leader>aq"] = { "close" }, -- Close UI windows
          ["<leader>as"] = { "select_session" }, -- Select and load a opencode session
          ["<leader>aR"] = { "rename_session" }, -- Rename current session
          ["<leader>ap"] = { "configure_provider" }, -- Quick provider and model switch from predefined list
          ["<leader>aV"] = { "configure_variant" }, -- Switch model variant for the current model
          ["<leader>ay"] = { "add_visual_selection", mode = { "v" } },
          ["<leader>aY"] = { "add_visual_selection_inline", mode = { "v" } }, -- Insert visual selection as inline code block in the input buffer
          ["<leader>az"] = { "toggle_zoom" }, -- Zoom in/out on the Opencode windows
          ["<leader>av"] = { "paste_image" }, -- Paste image from clipboard into current session
          ["<leader>ad"] = { "diff_open" }, -- Opens a diff tab of a modified file since the last opencode prompt
          ["<leader>a]"] = { "diff_next" }, -- Navigate to next file diff
          ["<leader>a["] = { "diff_prev" }, -- Navigate to previous file diff
          ["<leader>ac"] = { "diff_close" }, -- Close diff view tab and return to normal editing
          ["<leader>ara"] = { "diff_revert_all_last_prompt" }, -- Revert all file changes since the last opencode prompt
          ["<leader>art"] = { "diff_revert_this_last_prompt" }, -- Revert current file changes since the last opencode prompt
          ["<leader>arA"] = { "diff_revert_all" }, -- Revert all file changes since the last opencode session
          ["<leader>arT"] = { "diff_revert_this" }, -- Revert current file changes since the last opencode session
          ["<leader>arr"] = { "diff_restore_snapshot_file" }, -- Restore a file to a restore point
          ["<leader>arR"] = { "diff_restore_snapshot_all" }, -- Restore all files to a restore point
          ["<leader>ax"] = { "swap_position" }, -- Swap Opencode pane left/right
          ["<leader>att"] = { "toggle_tool_output" }, -- Toggle tools output (diffs, cmd output, etc.)
          ["<leader>atr"] = { "toggle_reasoning_output" }, -- Toggle reasoning output (thinking steps)
          ["<leader>a/"] = { "quick_chat", mode = { "n", "x" } }, -- Open quick chat input with selection context in visual mode or current line context in normal mode
        },
        input_window = {
          ["<S-cr>"] = { "submit_input_prompt", mode = { "n", "i" } }, -- Submit prompt (normal mode and insert mode)
          ["<esc>"] = { "close", defer_to_completion = true }, -- Close UI windows
          ["<C-c>"] = { "cancel", defer_to_completion = true }, -- Cancel opencode request while it is running
          ["~"] = { "mention_file", mode = "i" }, -- Pick a file and add to context. See File Mentions section
          ["@"] = { "mention", mode = "i" }, -- Insert mention (file/agent)
          ["/"] = { "slash_commands", mode = "i" }, -- Pick a command to run in the input window
          ["#"] = { "context_items", mode = "i" }, -- Manage context items (current file, selection, diagnostics, mentioned files)
          ["<M-v>"] = { "paste_image", mode = "i" }, -- Paste image from clipboard as attachment
          ["<tab>"] = { "toggle_pane", mode = { "n", "i" }, defer_to_completion = true }, -- Toggle between input and output panes
          ["<up>"] = { "prev_prompt_history", mode = { "n", "i" }, defer_to_completion = true }, -- Navigate to previous prompt in history
          ["<down>"] = { "next_prompt_history", mode = { "n", "i" }, defer_to_completion = true }, -- Navigate to next prompt in history
          ["<M-m>"] = { "switch_mode" }, -- Switch between modes (build/plan)
          ["<M-r>"] = { "cycle_variant", mode = { "n", "i" } }, -- Cycle through available model variants
        },
        output_window = {
          ["<esc>"] = { "close" }, -- Close UI windows
          ["<C-c>"] = { "cancel" }, -- Cancel opencode request while it is running
          ["]]"] = { "next_message" }, -- Navigate to next message in the conversation
          ["[["] = { "prev_message" }, -- Navigate to previous message in the conversation
          ["<tab>"] = { "toggle_pane", mode = { "n", "i" } }, -- Toggle between input and output panes
          ["i"] = { "focus_input", "n" }, -- Focus on input window and enter insert mode at the end of the input from the output window
          ["<M-r>"] = { "cycle_variant", mode = { "n" } }, -- Cycle through available model variants
          ["<leader>aS"] = { "select_child_session" }, -- Select and load a child session
          ["<leader>aP"] = { "select_parent_session" }, -- Go to parent session
          ["<leader>aB"] = { "select_sibling_session" }, -- Select sibling session (children of same parent)
          ["<leader>aD"] = { "debug_message" }, -- Open raw message in new buffer for debugging
          ["<leader>aO"] = { "debug_output" }, -- Open raw output in new buffer for debugging
          ["<leader>ads"] = { "debug_session" }, -- Open raw session in new buffer for debugging
        },
        session_picker = {
          rename_session = { "<C-r>" }, -- Rename selected session in the session picker
          delete_session = { "<C-d>" }, -- Delete selected session in the session picker
          new_session = { "<C-s>" }, -- Create and switch to a new session in the session picker
        },
        timeline_picker = {
          undo = { "<C-u>", mode = { "i", "n" } }, -- Undo to selected message in timeline picker
          fork = { "<C-f>", mode = { "i", "n" } }, -- Fork from selected message in timeline picker
        },
        history_picker = {
          delete_entry = { "<C-d>", mode = { "i", "n" } }, -- Delete selected entry in the history picker
          clear_all = { "<C-X>", mode = { "i", "n" } }, -- Clear all entries in the history picker
        },
        model_picker = {
          toggle_favorite = { "<C-f>", mode = { "i", "n" } },
        },
        mcp_picker = {
          toggle_connection = { "<C-t>", mode = { "i", "n" } }, -- Toggle MCP server connection in the MCP picker
        },
      },
    },
  },
}
