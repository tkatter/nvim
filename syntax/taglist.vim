" Taglist syntax file
" Maintainer: Thomas Katter
" Latest Revision: 25 May 2026

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" syntax match zigArrowCharacter display "\V->"
syntax match tagFileName display "^[A-Za-z0-9_\./-]\+:"

highlight default link tagFileName PmenuMatch
highlight default link tagMatch ErrorMsg

let b:current_syntax = "taglist"

let &cpo = s:cpo_save
unlet! s:cpo_save
