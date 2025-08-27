-- Mason setup
require("mason").setup()

--Mason-LSPConfig setup
require("mason-lspconfig").setup {
  ensure_installed = { "jdtls", "ts_ls", "clangd", "lua_ls", "bashls" },
  automatic_installation = true,
}

-- Completion setup
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require("lspconfig")

-- Universal on_attach
local on_attach = function(_, bufnr)
  local opts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
end

-- Helper: fallback to current dir if no project root found
local function fallback_root(fname)
  local util = require("lspconfig.util")
  return util.root_pattern(".git")(fname)
      or util.root_pattern("package.json", "tsconfig.json")(fname)
      or util.root_pattern("pom.xml")(fname)
      or util.root_pattern("compile_commands.json", "compile_flags.txt")(fname)
      or util.root_pattern(".luarc.json", ".luacheckrc")(fname)
      or util.root_pattern(".bashrc")(fname)
      or util.path.dirname(fname)  -- fallback: file dir
end

-- Setup all servers
local servers = { "jdtls", "ts_ls", "clangd", "lua_ls", "bashls" }

for _, server in ipairs(servers) do
  lspconfig[server].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    root_dir = fallback_root,
    single_file_support = true,  -- important!
  }
end
