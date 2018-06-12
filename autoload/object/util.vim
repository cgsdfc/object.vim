let s:identifier = '\v\C^[a-zA-Z_][a-zA-Z0-9_]*$'

function! object#util#ensure_argc(atmost, x)
  if a:x <= a:atmost
    return a:x
  endif
  throw object#TypeError('takes at most %d optional arguments (%d given)', a:atmost, a:x)
endfunction

function! object#util#ensure_identifier(x)
  let x = maktaba#ensure#IsString(a:x)
  if x =~# s:identifier
    return x
  endif
  throw object#ValueError('%s is not an identifier', string(x))
endfunction

function! object#util#has_special_variables()
  return exists('v:none') && exists('v:false') &&
        \ exists('v:true') && exists('v:null')
endfunction

function! object#util#has_bin_specifier()
  return has('patch-7.4.2221')
endfunction

function object#util#identity(X)
  return a:X
endfunction
