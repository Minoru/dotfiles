" Vim syntax file
" Language:	HTML
" Maintainer:	Claudio Fleiner <claudio@fleiner.com>
" URL:		http://www.fleiner.com/vim/syntax/html.vim
" Last Change:  2006 Jun 19

if getline(1) =~? '<!DOCTYPE html>'
  let b:html5 = 1
else
  let b:html5 = 0
endif

if b:html5
  " new html 5 tags
  syn keyword htmlTagName contained article aside audio bdi canvas command
  syn keyword htmlTagName contained datalist details embed figcaption
  syn keyword htmlTagName contained figure footer header hgroup keygen mark
  syn keyword htmlTagName contained meter nav output progress rp rt ruby section
  syn keyword htmlTagName contained source summary time track video wbr
endif

" vim: ts=8
