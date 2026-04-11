# Treesitter

Make sure `tree-sitter-cli` is installed. It can be installed via Cargo:

```sh
cargo install --locked tree-sitter-cli
```

Treesitter parsers and queries are installed manually.
In [init.lua](init.lua) the following line makes them visible to Neovim:

```lua
vim.opt.rtp:prepend(vim.fn.stdpath('data'))
```

Then everything can be installed in `~/.local/share/nvim/{parser,queries}`.

```
/home/thomas/.local/share/nvim/
├── parser
│   ├── bash.so -> /usr/local/lib/libtree-sitter-bash.so
│   ├── just.so -> /usr/local/lib/libtree-sitter-just.so
│   └── rust.so -> /usr/local/lib/libtree-sitter-rust.so
└── queries
    ├── bash
    │   ├── folds.scm
    │   ├── highlights.scm
    │   ├── indents.scm
    │   ├── injections.scm
    │   └── locals.scm
    ├── just
    │   ├── folds.scm
    │   ├── highlights.scm
    │   ├── indents.scm
    │   ├── injections.scm
    │   ├── locals.scm
    │   └── textobjects.scm
    └── rust
        ├── folds.scm
        ├── highlights.scm
        ├── indents.scm
        ├── injections.scm
        └── locals.scm

6 directories, 19 files
```

It may be a good idea to read over the `Makefile` when installing these
parsers once more before running them, but so far, they all seem to be
following a standard. `make` simply builds the parser and `make install`
installs the files into their respective locations (machine dependent).

## Sh/Bash

Clone into the [repo][tree-sitter-bash] and run the following sequence of commands:

```sh
mkdir -p ~/.local/share/nvim/queries/bash/
cp queries/* ~/.local/share/nvim/queries/bash/
make
sudo make install
ln -s /usr/local/lib/libtree-sitter-bash.so ~/.local/share/nvim/parser/bash.so
```

I ended up using the queries from `nvim-treesitter/runtime/queries/bash/`.
They seem to be maintained by @clason and others separately from
`tree-sitter-bash`. Permalink to queries [here][runtime-queries-bash].

## Rust

Clone into the [repo][tree-sitter-rust] and run the following sequence of commands:

```sh
mkdir -p ~/.local/share/nvim/queries/rust/
cp queries/* ~/.local/share/nvim/queries/rust/
make
sudo make install
ln -s /usr/local/lib/libtree-sitter-rust.so ~/.local/share/nvim/parser/rust.so
```

I ended up using the queries from `nvim-treesitter/runtime/queries/rust/`.
They seem to be maintained by @clason and others separately from
`tree-sitter-rust`. Permalink to queries [here][runtime-queries-rust].

## Just

Clone into the [repo][tree-sitter-just] and run the following sequence of commands:

```sh
mkdir -p ~/.local/share/nvim/queries/just/
cp queries/just/* ~/.local/share/nvim/queries/just/
make
sudo make install
ln -s /usr/local/lib/libtree-sitter-just.so ~/.local/share/nvim/parser/just.so
```

# LSPs

## Sh/Bash

A full LSP for sh/bash files is a bit crazy, especially when it is written in
Typescript. It's not _terrible_, but definitely not ideal since I would have to
install it via npm/pnpm (which I despise), and I don't really need an LSP for
sh/bash scripts in the first place; most of the errors I run into are simply
runtime errors that the LSP wouldn't be able to catch.

Alternatively, there is `shellcheck` which can be installed as a binary on most
systems and is what `bash-language-server` calls anyway, since `shellcheck` is
the thing actually providing the error messages.

With `shellcheck` set as the `makeprg`, I can run `:mak` and then use a
`QuickFixCmdPost` autocmd to take the errors from `shellcheck` and turn them
into a list of `vim.Diagnostic[]` - to display like any other LSP diagnostic. 


```sh
# Ubuntu/Debian based
sudo apt install shellcheck
# FreeBSD
sudo pkg install hs-ShellCheck
```

## Rust

Just add the rust-analyzer component with `rustup`.
Configuration values can be found in the rust-analyzer [book][rust-analyzer].

## Lua

### Apple

Install with `brew install lua-language-server` and everything works.

On Mac, the `vim.lsp.config\['lua_ls'\].cmd` does not need to have the `--logpath`
and `--metapath` flags. So you can get away with just:

```lua
cmd = { 'lua-language-server' }
```

### Linux - Mint

Visited the [repo][lua_ls_repo] for lua-language-server which then directed me to
their [website][lua_ls_web] for installation instructions. There I found that they
only have 4 supported package mangers to install from... **3 of them are for Mac**;
they have a community maintained packaged with `asdf` but I'm not installing that.
So, naturally, I fetched the `.tar.gz` and extracted it to `/opt`:

```sh
wget https://github.com/LuaLS/lua-language-server/releases/download/3.18.1/lua-language-server-3.18.1-linux-x64.tar.gz
sudo tar -xzC /opt/lua-language-server lua-language-server-3.18.1-linux-x64.tar.gz
sudo ln -s /opt/lua-language-server/bin/lua-language-server /usr/local/bin/lua-language-server
```

Then, after configuring with Neovim (see [lua_ls.lua](lua/lsp/lua_ls.lua)), I started editing 
[init.lua](init.lua) and was met with the LSP insta-quitting since it could not make
directories in `/opt/lua-language-server`. So I had to edit the LSP config
to include the following CLI flags when calling the executable (ref #[2676][lua_ls-2676]):

```lua
cmd = {
  'lua-language-server',
  '--logpath',
  '/home/thomas/.cache/lua_ls',
},
```

Then it started up no problem.

Except for the diagnostics about `require` being an undefined global...

I found this issue #[1788][lua_ls-1788] which mentioned yet another CLI flag to pass to the
executable because:

> Maybe it generated meta files failed.

So I added the following to the config:

```lua
cmd = {
  'lua-language-server',
  '--logpath',
  '/home/thomas/.cache/lua_ls',
  '--metapath',
  '/home/thomas/.cache/lua_ls/meta/',
},
```

I also added the lua libraries relating to the lua used throughout Neovim to the
workspace.library:

```lua
workspace = {
  library = vim.tbl_extend('keep',
    { '/opt/lua-language-server/meta/3rd/luv/library' },
    vim.api.nvim_get_runtime_file("", true))
},
```

[lua_ls-1788]: https://github.com/LuaLS/lua-language-server/issues/1788
[lua_ls-2676]: https://github.com/LuaLS/lua-language-server/issues/2676
[lua_ls_repo]: https://github.com/LuaLS/lua-language-server
[lua_ls_web]: https://luals.github.io/
[rust-analyzer]: https://rust-analyzer.github.io/book/configuration.html 
[tree-sitter-bash]: https://github.com/tree-sitter/tree-sitter-bash
[tree-sitter-just]: https://github.com/casey/tree-sitter-just.git
[tree-sitter-rust]: https://github.com/tree-sitter/tree-sitter-rust
[runtime-queries-bash]: https://github.com/nvim-treesitter/nvim-treesitter/tree/4916d6592ede8c07973490d9322f187e07dfefac/runtime/queries/bash
[runtime-queries-rust]: https://github.com/nvim-treesitter/nvim-treesitter/tree/4916d6592ede8c07973490d9322f187e07dfefac/runtime/queries/rust
