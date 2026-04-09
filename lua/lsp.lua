vim.lsp.config('pylsp', {
    cmd = { 'pylsp' },
    filetypes = { 'python' },
    root_markers = {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        '.git',
    },
})

vim.lsp.enable 'pylsp'

vim.lsp.config('rust_analyzer', {
    -- Command and arguments to start the server.
    cmd = { 'rust-analyzer' },
    -- Filetypes to automatically attach to.
    filetypes = { 'rust' },
    root_markers = { { 'Cargo.toml' }, '.git' },
    settings = {
        ['rust-analyzer'] = {
            -- imports = {
            --     granularity = {
            --         enforce = true,
            --         group = 'item',
            --     },
            -- },
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

vim.lsp.enable 'rust_analyzer'

vim.lsp.config('bashls', {
    cmd = { 'bash-language-server', 'start' },
    settings = {
        bashIde = {
            -- Prevent recursive scanning which will cause issues when opening a file
            -- directly in the home directory (e.g. ~/foo.sh).
            -- Default upstream pattern is "**/*@(.sh|.inc|.bash|.command)".
            globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
        },
    },
    filetypes = { 'bash', 'sh' },
    root_markers = { '.git' },
})

vim.lsp.enable 'bashls'

vim.lsp.config('postgres_lsp', {
    cmd = { 'postgres-language-server', 'lsp-proxy' },
    filetypes = {
        'sql',
    },
    root_markers = { 'postgres-language-server.jsonc' },
})

vim.lsp.enable 'postgres_lsp'

vim.lsp.config('lua_ls', {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
                path ~= vim.fn.stdpath 'config'
                and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
            then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using (most
                -- likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Tell the language server how to find Lua modules same way as Neovim
                -- (see `:h lua-module-load`)
                path = {
                    'lua/?.lua',
                    'lua/?/init.lua',
                },
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    '${3rd}/luv/library',
                    -- '${3rd}/busted/library'
                },
            },
        })
    end,
    settings = {
        Lua = {},
    },
})

vim.lsp.enable 'lua_ls'

vim.lsp.config('jsonls', {
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    init_options = {
        provideFormatter = true,
    },
    root_markers = { '.git' },
})

vim.lsp.enable 'jsonls'

vim.lsp.config('docker_compose_language_service', {
    cmd = { 'docker-compose-langserver', '--stdio' },
    filetypes = { 'yaml.docker-compose' },
    root_markers = { 'docker-compose.yaml', 'docker-compose.yml', 'compose.yaml', 'compose.yml' },
})

vim.lsp.enable 'docker_compose_language_service'

vim.lsp.config('marksman', {
    cmd = { 'marksman', 'server' },
    filetypes = { 'markdown', 'markdown.mdx' },
    root_markers = { '.marksman.toml', '.git' },
})

vim.lsp.enable 'marksman'

vim.diagnostic.config {
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
    },
    virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
            local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
        end,
    },
}

vim.lsp.config('clangd', require 'clang')
vim.lsp.enable 'clangd'
