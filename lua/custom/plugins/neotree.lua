return {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
    },
    -- keys = {},
    opts = {
        sources = { "filesystem" },
        filesystem = {
            bind_to_cwd = false,
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true
        }

    },
    keys = {
      {'<leader>nt', "<cmd>Neotree toggle<CR>", desc = "Toggle Neotree"},
    },
    -- config = function ()
    --     vim.keymap.set("n", "<leader>ne", '<cmd>Neotree toggle<CR>', { desc = "Neotree toggle" })
    -- end
}
