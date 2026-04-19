vim.lsp.config('rust', {
  cmd          = { 'rust-analyzer' },
  filetypes    = { 'rust' },
  root_markers = { { 'Cargo.toml', 'Cargo.lock' }, '.git' },
  settings = {
    ['rust-analyzer'] = {
      -- Disable 'inactive-code' warnings for disabled #[cfg(feature)]s
      diagnostics = {
        disabled = { 'inactive-code' },
      },
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
            body        = 'Ok(${receiver})',
            description = 'Wrap the expression in a `Result::Ok`',
            postfix     = 'ok',
            scope       = 'expr',
          },
          ['Arc::new'] = {
            body        = 'Arc::new(${receiver})',
            description = 'Wrap the expression in an `Arc`',
            postfix     = 'arc',
            scope       = 'expr',
          },
          ['Arc::clone'] = {
            body        = 'Arc::clone(${receiver})',
            description = 'Explicitly annotate as an `Arc::clone`',
            postfix     = 'aclone',
            scope       = 'expr',
          },
          ['Some'] = {
            body        = 'Some(${receiver})',
            description = 'Wrap the expression in an `Option::Some`',
            postfix     = 'some',
            scope       = 'expr',
          },
          ['Err'] = {
            body        = 'Err(${receiver})',
            description = 'Wrap the expression in an `Result::Err`',
            postfix     = 'err',
            scope       = 'expr',
          },
        },
      },
    },
  },
  on_attach = function(client, bufnr)
    vim.lsp.completion.enable(true, client.id, bufnr, {
      autotrigger = true,
      convert = function(item)
        return { abbr = item.label:gsub('%b()', '') }
      end,
    })
  end,
})

vim.lsp.enable 'rust'
