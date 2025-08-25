-- colors for tags
vim.api.nvim_set_hl(0, "CommentTodo", { fg = "#f7768e", bold = true })  -- TODO/FIXME
vim.api.nvim_set_hl(0, "CommentNote", { fg = "#e0af68", bold = true })  -- NOTE
vim.api.nvim_set_hl(0, "CommentHack", { fg = "#ff9e64", bold = true })  -- HACK

-- add window-local matches (works alongside Treesitter)
local patterns = {
  { "CommentTodo", [[\v(^\s*([#/;]|--|\*)\s*)@<=(TODO|FIXME):]] },
  { "CommentNote", [[\v(^\s*([#/;]|--|\*)\s*)@<=NOTE:]] },
  { "CommentHack", [[\v(^\s*([#/;]|--|\*)\s*)@<=HACK:]] },
}

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function()
    if vim.w._comment_kw_applied then return end
    for _, p in ipairs(patterns) do
      vim.fn.matchadd(p[1], p[2])
    end
    vim.w._comment_kw_applied = true
  end,
})
