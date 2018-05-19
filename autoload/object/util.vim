function! object#util#ensure_argc(atmost, x)
  if a:x <= a:atmost
    return a:x
  endif
  throw object#TypeError('takes at most %d arguments (%d given)', a:atmost, a:x)
endfunction
