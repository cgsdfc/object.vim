let s:plain_function = '\C\V\^function('\.\*')\$'

" We currently handle 3 kinds of functions:
" - Plain function like printf(), len().
" - Dict function:
"   - 
function! object#callable#repr(X)
  return ''
endfunction
