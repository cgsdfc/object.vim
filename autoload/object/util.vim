let s:identifier = '\v\C^[a-zA-Z_][a-zA-Z0-9_]*$'

function! object#util#ensure_argc(atmost, x)
  if a:x <= a:atmost
    return a:x
  endif
  throw object#TypeError('takes at most %d optional arguments (%d given)', a:atmost, a:x)
endfunction

function! object#util#ensure_identifier(x)
  if a:x =~# s:identifier
    return a:x
  endif
  throw object#ValueError('%s is not an identifier', string(a:x))
endfunction
