set shell := ['bash', '-uc', '--']

cache_dir  := cache_dir()
config_dir := config_dir()
data_dir   := data_dir()
home_dir   := home_dir()
ts_parser_dir  := data_dir / 'nvim' / 'parser'
ts_queries_dir := data_dir / 'nvim' / 'queries'

_no_win := if os() == 'windows' { error('not supported') } else { '' }
_os-id  := `grep ^ID= /etc/os-release | cut -d= -f 2`
distro  := if _os-id =~ '(debian|ubuntu|linuxmint)' {
  'debian' 
} else if _os-id =~ 'freebsd' {
  'freebsd'
} else {
  error('{{_os_id}} is not supported')
}

sudo    := require('sudo')
cargo   := require('cargo')
make    := if os() == 'freebsd' { 'gmake' } else { 'make' }
so_ext  := if os() == 'macos' { 'dylib' } else { 'so' }
pkg_mgr := if os() == 'freebsd' {
  require('pkg')
} else if distro == 'debian' {
  require('apt-get')
} else if os() == 'macos' {
  require('brew')
} else {
  error('not supported')
}

neovim_prereqs := if os() == 'freebsd' {
  'cmake gmake wget gettext curl git'
} else if distro == 'debian' {
  'ninja-build gettext cmake curl build-essential git'
} else {
  ''
}

[doc('list available recipies')]
default:
  just --list

# create directory structure
[private]
@dirs:
  install -d "{{config_dir}}/nvim"
  install -d "{{cache_dir}}"
  install -d "{{ts_parser_dir}}"
  install -d "{{ts_queries_dir}}"

[no-exit-message]
[doc('show the installed queries/parsers')]
[arg("KIND", pattern="all|query|queries|parser|parsers")]
list-installed +KIND='all':
  #!/usr/bin/env bash
  set -euo pipefail
  [[ '{{KIND}}' =~ quer|all ]] && {
    echo '{{YELLOW}}{{BOLD}}Queries:{{NORMAL}}'
    ls -1 -R {{ts_queries_dir / '*'}} \
      | awk '/^.*:/{
        sub(/.*\//, "")
        print "\033[32m"$NF"\033[0m"
      }
      /^.*\.scm$/{
        print "  \033[34m"$0"\033[0m"
      }'; }

  [[ '{{KIND}}' =~ parser|all ]] && {
    echo '{{YELLOW}}{{BOLD}}Parsers:{{NORMAL}}'
    ls -l {{ts_parser_dir}} \
      | awk '{
        if (length($9) == 0) next
        print "  \033[36m"$9"\033[0m -> \033[34m"$NF"\033[0m"
      }'; }

      
[doc('install treesitter parser/queries for `lang`')]
[parallel]
[arg('lang', help='treesitter language(s) to install')]
ts-install +lang: dirs (install-parser lang) (install-queries lang)

install-parser +lang: 
  #!/usr/bin/env bash
  set -euo pipefail
  install() {
    [ -z "$lang" ] && return
    echo "{{GREEN}}installing $lang parser...{{NORMAL}}"
    [ -d "/tmp/tree-sitter-$lang" ] || git clone -q --depth 5 \
      "git@github.com:tree-sitter/tree-sitter-$lang.git" \
      "/tmp/tree-sitter-$lang"

    [ -d "/tmp/tree-sitter-$lang" ] || {
      echo '{{style("error")}}no parser found under the tree-sitter github repo{{NORMAL}}'
      exit 1; }

    echo '  {{BLUE}}building parser{{NORMAL}}'
    cd "/tmp/tree-sitter-$lang" && '{{sudo}}' '{{make}}' install &>/dev/null \
      || { echo "{{style('error')}}failed to build parser for $lang"; exit 1; }

    src="$(find /usr/local/lib -name "*libtree*$lang.{{so_ext}}")"
    dest="{{ts_parser_dir}}/$lang.{{so_ext}}"
    ln -s "$src" "$dest"
    echo '  {{BLUE}}created symlink:{{NORMAL}}'
    echo "    {{CYAN}}$src{{NORMAL}} -> $dest"
    cd /tmp && rm -rf "/tmp/tree-sitter-$lang"
  }
  for lang in {{lang}}; do install; done

install-queries +lang:
  #!/usr/bin/env bash
  set -euo pipefail
  install() {
    [ -z "$lang" ] && return
    echo "{{GREEN}}installing $lang queries...{{NORMAL}}"
    [ -d '/tmp/nvim-treesitter' ] || git clone -q --depth 5 \
      'https://github.com/nvim-treesitter/nvim-treesitter.git' \
      '/tmp/nvim-treesitter'

    src_queries="/tmp/nvim-treesitter/runtime/queries/$lang"
    [ -d "$src_queries" ] || {
      echo "{{style('error')}}No nvim-treesitter queries found for $lang{{NORMAL}}"
      exit 1; }

    printf "  {{BLUE}}installing{{NORMAL}} %-15s -> {{ts_queries_dir}}/$lang/\n" \
      `ls -1 "$src_queries"`
    cp -r "$src_queries" "{{ts_queries_dir}}/"
  }
  for lang in {{lang}}; do install; done
  rm -rf '/tmp/nvim-treesitter'

[doc('build/install neovim from source')]
[arg('build', help='neovim build type')]
[arg('prefix', help='prefix directory to install neovim under')]
install-nvim build='RelWithDebInfo' prefix='': nvim-build-deps
  #!/usr/bin/env bash
  set -euo pipefail
  [ '{{os()}}' = 'linux' ] && [ '{{distro}}' != 'debian' ] && {
    echo '{{style("error")}}install neovim via the package manager{{NORMAL}}'
    exit 1; }

  [ -d '/tmp/neovim' ] || git clone --depth 5 \
      https://github.com/neovim/neovim.git /tmp/neovim 2>/dev/null
  echo '{{BLUE}}building neovim...{{NORMAL}}'
  cd /tmp/neovim && {
    '{{make}}' CMAKE_BUILD_TYPE='{{build}}'
    '{{sudo}}' '{{make}}' CMAKE_INSTALL_PREFIX='{{prefix}}' install; } &>/dev/null

  printf '{{GREEN}}built neovim with {{build}}'
  if [ -n '{{prefix}}' ]; then
    printf ' and installed under {{prefix}}{{NORMAL}}\n'
  else
    printf '{{NORMAL}}\n'
  fi
  rm -rf /tmp/neovim

[private]
@nvim-build-deps:
  command -v tree-sitter &>/dev/null || { \
     echo '{{BLUE}}installing tree-sitter{{NORMAL}}'; \
    '{{cargo}}' install -q --locked tree-sitter-cli; }

  echo '{{BLUE}}installing neovim build pre-requisites{{NORMAL}}'
  '{{sudo}}' '{{pkg_mgr}}' install -q -y {{neovim_prereqs}}

ts-remove +lang:
  #!/usr/bin/env bash
  set -euo pipefail
  parser_names=()
  query_paths=()
  for lang in {{lang}}; do
    ((${#parser_names[@]})) && parser_names+=('-o')
    ((${#query_paths[@]})) && query_paths+=('-o')
    parser_names+=('-name' "*libtree*$lang*" '-o' '-name' "$lang.{{so_ext}}")
    query_paths+=('-path' "*$lang")
  done
  find /usr/local/lib {{ts_parser_dir}} \
    \( ${parser_names[*]} \) -exec sudo rm -f '{}' \; 2>/dev/null
  find {{ts_queries_dir}} -maxdepth 1 \
    \( ${query_paths[*]} \) -exec rm -rf '{}' \; 2>/dev/null

[no-exit-message]
[doc('clean all neovim install/runtime files')]
[arg('keep', short='k', value='k', help='keep local directories under ~/.local')]
clean-nvim keep='':
  #!/usr/bin/env bash
  set -euo pipefail
  prune_dirs=('-path' '{{config_dir}}' '-prune')
  [ -n '{{keep}}' ] && \
    prune_dirs+=('-o' '-path' '{{parent_dir(data_dir)}}' '-prune')

  find /usr '{{home_dir}}' \
    ${prune_dirs[*]} \
    -o -path '*nvim/*' -prune \
    -o \( -name 'nvim' -exec sudo rm -rf '{}' + \) 2>/dev/null
