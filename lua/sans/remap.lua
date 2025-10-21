-- to open file manager"Ex"
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>fm", vim.cmd.Ex)

-- copy
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "yank to the system's clipboard" })
vim.keymap.set({ "n" }, "<leader>Y", '"+Y', { desc = "yank to the system's clipboard" })

-- paste
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', { desc = "paste from system's clipboard" })

-- move lines with auto-indent
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")


-- paste content without adding highlight content to curr buffer
vim.keymap.set("x", "<leader>P", "\"_dP")
