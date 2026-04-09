# Keybinds

- `gx`: open current fpath/url w/ system default handler
- `{Visual}gx`: open selected text w/ system default handler

# Config

```lua
vim.keymap
vim.api.nvim_set_keymap
```

# Misc

```lua
vim.cmd
vim.notify
vim.paste
vim.lpeg    -- Parsing Expression Grammars
vim.re      -- regex-like interface for lpeg
vim.regex   -- vim regex
vim.net     -- networking?!
vim.version -- cmp semver versions?
```

# Text

```lua
vim.text.diff     -> diff two strings
vim.text.indent   -> indent lines
vim.text.deindent -> deindent lines
```

# Debugging

```lua
:set pp?
:echo nvim_list_runtime_paths()
vim.inspect
vim.keycode
vim.print
vim.show_pos
```

# FS

```lua
vim.fn.filecopy  -- copy a file
vim.fs.abspath   -- mk path absolute
vim.fs.basename  -- basename of given path
vim.fs.dir       -- iterate over entries
vim.fs.dirname   -- get parent dirname
vim.fs.ext       -- ret file extension
vim.fs.find      -- like the `find` sh util
vim.fs.joinpath  -- join paths... duh
vim.fs.normalize -- tilde/env expansion
vim.fs.readblob  -- read file contents
vim.uv.fs_stat   -- get ftype and existence
vim.fs.rm        -- rm file/dir
vim.fs.parents   -- iterate over parent dirs
vim.fs.relpath   -- gets rel path to base
vim.fs.root      -- find first parent containing marker
```

# Strings

```lua
vim.endswith   -- chk if str ends with
vim.gsplit     -- split at terminator (greed)
vim.pesc       -- remove pattern from str
vim.split      -- split at terminator (greed)
vim.startswith -- chk if str starts with
vim.stricmp    -- strcmp
vim.trim       -- trim ws from front/back
```

# Lua Tables

```lua
vim.spairs
vim.tbl_contains
vim.tbl_deep_extend
vim.tbl_extend
vim.tbl_filter
vim.tbl_get
vim.tbl_isempty
vim.tbl_keys
vim.tbl_map
vim.tbl_values
vim.iter
```

# Lua Lists

```lua
vim.list.unique
vim.list_contains
vim.list_extend
vim.list_slice
vim.iter
```

# Filetype

```lua
vim.filetype.add
vim.filetype.match
vim.filetype.get_option
```
