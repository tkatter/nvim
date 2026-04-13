set shell := ['bash', '-uc', '--']

cache_dir  := cache_dir()
config_dir := config_dir()
data_dir   := data_dir()
home_dir   := home_dir()
ts_parser_dir  := data_dir / 'nvim' / 'parser'
ts_queries_dir := data_dir / 'nvim' / 'queries'

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
  require('apt')
} else if os() == 'macos' {
  require('brew')
} else if os() == 'windows' {
  error('get lost')
} else {
  error('not supported')
}

default:
  @echo "{{sudo}} {{cargo}} {{pkg_mgr}}"

_dirs:
  install -d "{{config_dir}}/nvim"
  install -d "{{cache_dir}}"
  install -d "{{ts_parser_dir}}"
  install -d "{{ts_queries_dir}}"

ts-install lang: (install-parser lang) (install-queries lang)

@install-parser lang: 
  [ -d '/tmp/tree-sitter-{{lang}}' ] || git clone \
    'https://github.com/tree-sitter/tree-sitter-{{lang}}.git' \
    '/tmp/tree-sitter-{{lang}}' 2>/dev/null
  [ -d '/tmp/tree-sitter-{{lang}}' ] || { \
    echo '{{style("error")}}No parser found under the tree-sitter github repo{{NORMAL}}'; \
    exit 1; }
  cd '/tmp/tree-sitter-{{lang}}' && '{{sudo}}' '{{make}}' install 2>1 >/dev/null
  ln -s "$(find /usr/local/lib -name '*{{lang}}.{{so_ext}}')" '{{ts_parser_dir / lang}}.{{so_ext}}'
  rm -rf '/tmp/tree-sitter-{{lang}}'

@install-queries lang:
  [ -d '/tmp/nvim-treesitter' ] || git clone \
    https://github.com/nvim-treesitter/nvim-treesitter.git \
    /tmp/nvim-treesitter 2>/dev/null
  [ -d "/tmp/nvim-treesitter/runtime/queries/{{lang}}" ] || { \
    echo '{{style("error")}}No nvim-treesitter queries found for {{lang}}{{NORMAL}}'; \
    exit 1; }
  cp -r "/tmp/nvim-treesitter/runtime/queries/{{lang}}" "{{ts_queries_dir}}/"

install:
  #!/usr/bin/env bash
  set -ueo pipefail
  list=("bash" "rust" "just" "quit")
  selected=()
  select choice in ${list[@]}; do
    [ "$choice" = "quit" ] && { echo "${selected[*]}"; break; }
    [ -n "$choice" ] && { list[0]="x bash"; selected+=("$choice"); }
  done

[freebsd]
install-deps:
  '{{sudo}}' '{{pkg_mgr}}' install cmake gmake wget gettext curl git
  

[linux]
install-deps:
  command -v tree-sitter >/dev/null || "{{cargo}}" install --locked tree-sitter-cli
  command -v "{{make}}" >/dev/null || "{{sudo}} {{pkg_mgr}} install {{make}}"

