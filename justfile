set shell := ['bash', '-uc', '--']

cache_dir  := cache_dir()
config_dir := config_dir()
data_dir   := data_dir()
home_dir   := home_dir()
ts_parser_dir  := data_dir / 'nvim' / 'parser'
ts_queries_dir := data_dir / 'nvim' / 'queries'
distro := `grep ^NAME /etc/os-release | awk -F\" '{print $2}'` 

sudo  := require('sudo')
cargo := require('cargo')
make  := if os() == 'freebsd' {
  'gmake'
} else {
  'make'
}
so_ext  := if os() == 'macos' {
  'dylib'
} else {
  'so'
}
pkg_mgr := if os() == 'freebsd' {
  require('pkg')
} else if os() == 'linux' {
    if distro == 'Ubuntu' { require('apt') } else { error('not supported') }
} else if os() == 'macos' {
  require('brew')
} else if os() == 'windows' {
  error('get lost')
} else {
  error('not supported')
}
neovim_prereqs := if os() == 'freebsd' {
  'cmake gmake wget gettext curl git'
} else if os() == 'linux' {
  if distro == 'Ubuntu' {
    'ninja-build gettext cmake curl build-essential git'
  } else { '' }
} else {
  ''
}

default:
  @echo "{{distro}}"

_dirs:
  install -d "{{config_dir}}/nvim"
  install -d "{{cache_dir}}"
  install -d "{{ts_parser_dir}}"
  install -d "{{ts_queries_dir}}"

ts-install lang: (install-parser lang) (install-queries lang)

@install-parser lang: 
  echo '{{GREEN}}installing {{lang}} parser...{{NORMAL}}'
  [ -d '/tmp/tree-sitter-{{lang}}' ] || git clone \
    'https://github.com/tree-sitter/tree-sitter-{{lang}}.git' \
    '/tmp/tree-sitter-{{lang}}' 2>/dev/null
  [ -d '/tmp/tree-sitter-{{lang}}' ] || { \
    echo '{{style("error")}}No parser found under the tree-sitter github repo{{NORMAL}}'; \
    exit 1; }
  echo '  {{BLUE}}building parser{{NORMAL}}'
  cd '/tmp/tree-sitter-{{lang}}' && '{{sudo}}' '{{make}}' install 2>1 >/dev/null
  ln -s "$(find /usr/local/lib -name '*{{lang}}.{{so_ext}}')" '{{ts_parser_dir / lang}}.{{so_ext}}'
  printf '  {{BLUE}}creating symlink:{{NORMAL}}\n    %s -> %s\n' \
    "$(find /usr/local/lib -name '*{{lang}}.{{so_ext}}')" \
    '{{ts_parser_dir / lang}}.{{so_ext}}'
  rm -rf '/tmp/tree-sitter-{{lang}}'

@install-queries lang:
  echo '{{GREEN}}installing {{lang}} queries...{{NORMAL}}'
  [ -d '/tmp/nvim-treesitter' ] || git clone \
    https://github.com/nvim-treesitter/nvim-treesitter.git \
    /tmp/nvim-treesitter 2>/dev/null
  [ -d "/tmp/nvim-treesitter/runtime/queries/{{lang}}" ] || { \
    echo '{{style("error")}}No nvim-treesitter queries found for {{lang}}{{NORMAL}}'; \
    exit 1; }
  printf '  {{BLUE}}installing{{NORMAL}} %-15s -> {{ts_queries_dir / lang}}\n' \
    `ls -1 '/tmp/nvim-treesitter/runtime/queries/{{lang}}'`
  cp -r "/tmp/nvim-treesitter/runtime/queries/{{lang}}" "{{ts_queries_dir}}/"

[linux, freebsd]
[doc('build/install neovim from source')]
[arg('build', help='neovim build type')]
[arg('prefix', help='prefix directory to install neovim under')]
install-neovim build='RelWithDebInfo' prefix='': install-deps
  #!/usr/bin/env bash
  [ '{{os()}}' = 'linux' ] && [ '{{distro}}' != 'Ubuntu' ] && { \
    echo '{{style("error")}}install neovim via the package manager{{NORMAL}}'; \
    exit 1; }

  [ -d /tmp/neovim ] || \
    git clone https://github.com/neovim/neovim.git /tmp/neovim 2>/dev/null
  echo '{{BLUE}}building neovim...{{NORMAL}}'
  cd /tmp/neovim && { \
  '{{make}}' CMAKE_BUILD_TYPE='{{build}}'; \
  '{{sudo}}' '{{make}}' CMAKE_INSTALL_PREFIX='{{prefix}}' install; }

  echo '{{GREEN}}built neovim with {{build}} and installed under {{prefix}}{{NORMAL}}'
  rm -rf /tmp/neovim

[freebsd, private]
@install-deps:
  command -v tree-sitter >/dev/null || { \
    echo '{{BLUE}}installing tree-sitter{{NORMAL}}'; \
    '{{cargo}}' install --locked tree-sitter-cli; }

  echo '{{BLUE}}installing neovim build pre-requisites{{NORMAL}}'
  '{{sudo}}' '{{pkg_mgr}}' install \
    cmake gmake wget gettext curl git

[linux, private]
@install-deps:
  command -v tree-sitter >/dev/null || { \
xz   echo '{{BLUE}}installing tree-sitter{{NORMAL}}'; \
    '{{cargo}}' install --locked tree-sitter-cli; }

  echo '{{BLUE}}installing neovim build pre-requisites{{NORMAL}}'
  '{{sudo}}' '{{pkg_mgr}}' install \
    ninja-build gettext cmake curl build-essential git

[linux, freebsd]
[doc('clean all neovim install/runtime files')]
[arg('keep', short='k', value='k', help='keep local directories under ~/.local')]
clean-neovim keep='':
  #!/usr/bin/env bash
  prune_dirs=('-path' '{{config_dir}}' '-prune')
  [ -n '{{keep}}' ] && \
    prune_dirs+=('-o' '-path' '{{parent_dir(data_dir)}}' '-prune')

  find /usr '{{home_dir}}' \
    ${prune_dirs[*]} \
    -o -path '*nvim/*' -prune \
    -o \( -name 'nvim' -exec sudo rm -rf '{}' + \)
