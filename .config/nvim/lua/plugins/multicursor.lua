return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    local set = vim.keymap.set

    -- Add or skip cursor above/below the main cursor.
    set({ "n", "x" }, "<up>", function() mc.lineAddCursor(-1) end)
    set({ "n", "x" }, "<down>", function() mc.lineAddCursor(1) end)
    set({ "n", "x" }, "<leader><up>", function() mc.lineSkipCursor(-1) end)
    set({ "n", "x" }, "<leader><down>", function() mc.lineSkipCursor(1) end)

    -- Add or skip adding a new cursor by matching word/selection
    set({ "n", "x" }, "<leader>cn", function() mc.matchAddCursor(1) end, { desc = "[C]ursor [n]ext Forwards" })
    set({ "n", "x" }, "<leader>cs", function() mc.matchSkipCursor(1) end, { desc = "[C]ursor [s]kip Forwards" })
    set({ "n", "x" }, "<leader>cN", function() mc.matchAddCursor(-1) end, { desc = "[C]ursor [N]ext Backwards" })
    set({ "n", "x" }, "<leader>cS", function() mc.matchSkipCursor(-1) end, { desc = "[C]ursor [S]kip Backwards" })

    -- Add and remove cursors with control + left click.
    set("n", "<c-leftmouse>", mc.handleMouse)
    set("n", "<c-leftdrag>", mc.handleMouseDrag)
    set("n", "<c-leftrelease>", mc.handleMouseRelease)

    -- Disable and enable cursors.
    set({ "n", "x" }, "<c-q>", mc.toggleCursor)

    -- Align Cursors
    set("n", "<leader>ca", mc.alignCursors, { desc = '[C]ursor [A]lign' })

    -- Restore Cursors
    set("n", "<leader>cr", mc.restoreCursors, { desc = "[C]ursor [R]estore" })

    -- Add a cursor and jump to the next/previous search result, with skips
    set("n", "<leader>c/n", function() mc.searchAddCursor(1) end, { desc = "[C]ursor [/] [n]ext Forwards" })
    set("n", "<leader>c/N", function() mc.searchAddCursor(-1) end, { desc = "[C]ursor [/] [N]ext Backwards" })
    set("n", "<leader>c/s", function() mc.searchSkipCursor(1) end, { desc = "[C]ursor [/] [s]kip Backwards" })
    set("n", "<leader>c/S", function() mc.searchSkipCursor(-1) end, { desc = "[C]ursor [/] [S]kip Backwards" })

    -- Add a cursor to every search result in the buffer.
    set("n", "<leader>c/a", mc.searchAllAddCursors, { desc = "[C]ursor [/] [A]ll" })

    -- Mappings defined in a keymap layer only apply when there are
    -- multiple cursors. This lets you have overlapping mappings.
    mc.addKeymapLayer(function(layerSet)
      -- Select a different cursor as the main one.
      layerSet({ "n", "x" }, "<left>", mc.prevCursor)
      layerSet({ "n", "x" }, "<right>", mc.nextCursor)

      -- Delete the main cursor.
      layerSet({ "n", "x" }, "<leader>cx", mc.deleteCursor, { desc = "[C]ursor Remove" })

      -- Enable and clear cursors using escape.
      layerSet("n", "<esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)

    -- Customize how cursors look.
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { reverse = true })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn" })
    hl(0, "MultiCursorMatchPreview", { link = "Search" })
    hl(0, "MultiCursorDisabledCursor", { reverse = true })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
  end
}
