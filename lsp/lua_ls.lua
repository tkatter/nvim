return {
  on_init = function(client)
    -- use .luarc.json(ck if present
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath 'config'
        and (vim.uv.fs_stat(path .. '/.luarc.json')
        or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
          return
      end
    end

    local lua_libs = vim.api.nvim_get_runtime_file("", true)
    if vim.uv.os_uname()['sysname'] == 'Linux' then
      lua_libs = vim.tbl_extend('keep',
        { '/opt/lua-language-server/meta/3rd/luv/library' }, lua_libs)
      else
      lua_libs = vim.tbl_extend('keep',
        { '${3rd}/luv/library' }, lua_libs)
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
        library = lua_libs,
      },
    })
  end,
  cmd = {
    'lua-language-server',
    '--logpath',
    '/home/thomas/.cache/lua_ls',
    '--metapath',
    '/home/thomas/.cache/lua_ls/meta/',
  },
  root_markers = { {'.luarc.json', '.luarc.jsonc'}, 'stylua.toml', '.git' },
  filetypes= { 'lua' },
  settings = {
      Lua = {},
  },
  on_attach = function(client, bufnr)
    vim.lsp.completion.enable(true, client.id, bufnr, {
      autotrigger = true,
      convert = function(item)
        return { abbr = item.label:gsub('%b()', '') }
      end,
    })
  end,
}
