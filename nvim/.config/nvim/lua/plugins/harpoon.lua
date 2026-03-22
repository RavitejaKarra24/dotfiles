return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")

        -- REQUIRED
        harpoon:setup()

        -- Add file to harpoon list
        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end,
            { desc = "Harpoon: add file" })

        -- Toggle harpoon quick menu
        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
            { desc = "Harpoon: toggle quick menu" })

        -- Navigate to harpooned files (1-4)
        vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end,
            { desc = "Harpoon: file 1" })
        vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end,
            { desc = "Harpoon: file 2" })
        vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end,
            { desc = "Harpoon: file 3" })
        vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end,
            { desc = "Harpoon: file 4" })

        -- Navigate to next/previous harpoon file
        vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end,
            { desc = "Harpoon: next file" })
        vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end,
            { desc = "Harpoon: previous file" })

        -- Open harpooned files in splits from the quick menu
        harpoon:extend({
            UI_CREATE = function(cx)
                vim.keymap.set("n", "<C-v>", function()
                    harpoon.ui:select_menu_item({ vsplit = true })
                end, { buffer = cx.bufnr })

                vim.keymap.set("n", "<C-x>", function()
                    harpoon.ui:select_menu_item({ split = true })
                end, { buffer = cx.bufnr })
            end,
        })
    end,
}
