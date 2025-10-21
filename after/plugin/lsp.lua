-- ======================
-- 🧠 Core LSP + Mason Setup
-- ======================
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "jdtls",     -- Java
    "ts_ls",     -- TypeScript/JavaScript
    "pyright",   -- Python
    "omnisharp", -- C#
  },
  automatic_installation = true,
})

-- ======================
-- ⚙️ nvim-cmp Setup
-- ======================
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-- ======================
-- 🚀 LSP Config Setup
-- ======================
local lspconfig = require('lspconfig')
local lsp = vim.lsp.config
local util = require("lspconfig.util")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Common LspAttach: keymaps
local LspAttach = function(_, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)
end

-- Helper: fallback root (handles single files)
local function fallback_root(fname)
  return util.root_pattern(".git")(fname)
  or util.root_pattern(
    "package.json",
    "tsconfig.json",
    "setup.py",
    "pyproject.toml",
    "pom.xml",
    "*.csproj"
  )(fname)
  or util.path.dirname(fname)
end

-- ======================
-- 💻 Language Servers
-- ======================

-- TypeScript / JavaScript
lsp('ts_ls', {
  capabilities = capabilities,
  LspAttach = LspAttach,
  root_dir = fallback_root,
  single_file_support = true,
})

-- Python
lsp('pyright', {
  capabilities = capabilities,
  LspAttach = LspAttach,
  root_dir = fallback_root,
})

-- C#
local omnisharp_bin =
vim.fn.expand("~/.local/share/nvim/mason/packages/omnisharp/OmniSharp")
lsp('omnisharp', {
  cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
  capabilities = capabilities,
  LspAttach = LspAttach,
  root_dir = fallback_root,
})

-- ======================
-- ☕ Java (JDTLS) Setup — CORRECT WAY
-- ======================
-- We do NOT use lspconfig.jdtls.setup here
-- Instead, we use nvim-jdtls to prevent duplicate clients

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local jdtls = require("jdtls")
    local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml" })
    or vim.fn.getcwd()
    local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
    local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspace/") .. project_name

    local config = {
      cmd = {
        "jdtls",
        "-configuration", vim.fn.expand("~/.cache/jdtls/config"),
        "-data", workspace_dir,
      },
      root_dir = root_dir,
      capabilities = capabilities,
      LspAttach = LspAttach,
    }

    jdtls.start_or_attach(config)
  end,
})

-- ======================
-- 🧾 Diagnostic Settings
-- ======================
vim.diagnostic.config({
  virtual_text = true, -- inline errors like LazyVim
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
