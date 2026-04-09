vim.lsp.config('rust', {
  -- Command and arguments to start the server.
  cmd = { 'rust-analyzer' },
  -- Filetypes to automatically attach to.
  filetypes = { 'rust' },
  root_markers = { { 'Cargo.toml', 'Cargo.lock' }, '.git' },
  settings = {
    ['rust-analyzer'] = {
      -- Disable 'inactive-code' warnings for disabled #[cfg(feature)]s
      -- diagnostics = {
      --     disabled = { 'inactive-code' },
      -- },
      check = {
        command = 'clippy',
        -- Change when working in embedded
        -- targets = { '<EMBEDDED_TARGET_TRIPLE>' }
        -- targets = { 'thumbv6m-none-eabi' },
      },
      completion = {
        postfix = { enable = true },
        snippets = {
          ['Ok'] = {
            postfix = 'ok',
            body = 'Ok(${receiver})',
            description = 'Wrap the expression in a `Result::Ok`',
            scope = 'expr',
          },
          ['Arc::new'] = {
            postfix = 'arc',
            body = 'Arc::new(${receiver})',
            description = 'Wrap the expression in an `Arc`',
            scope = 'expr',
          },
          ['Arc::clone'] = {
            postfix = 'aclone',
            body = 'Arc::clone(${receiver})',
            description = 'Explicitly annotate as an `Arc::clone`',
            scope = 'expr',
          },
          ['Some'] = {
            postfix = 'some',
            body = 'Some(${receiver})',
            description = 'Wrap the expression in an `Option::Some`',
            scope = 'expr',
          },
          ['Err'] = {
            postfix = 'err',
            body = 'Err(${receiver})',
            description = 'Wrap the expression in an `Result::Err`',
            scope = 'expr',
          },
        },
      },
    },
  },
})

vim.lsp.enable 'rust'

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('rust.lsp', {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local ns = vim.lsp.diagnostic.get_namespace(ev.data.client_id)

    vim.print(vim.diagnostic.get_namespace(ns).name)
  end,
})
