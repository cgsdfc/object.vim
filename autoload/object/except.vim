let s:type_pattern = '\v^[a-zA-Z_][a-zA-Z0-9_]*$'

function! object#except#format(type, msg, args)
  return printf('%s: %s', a:type, empty(a:args) ?
        \ a:msg : call('printf', [a:msg] + a:args))
endfunction

function! object#except#BaseException(type, msg, args)
  let type = maktaba#ensure#IsString(a:type)
  let msg = maktaba#ensure#IsString(a:msg)
  let args = maktaba#ensure#IsList(a:args)

  if a:type !~ s:type_pattern
    throw object#ValueError('%s is not a pattern of identifier', string(a:type))
  endif

  return object#except#format(a:type, a:msg, a:args)
endfunction

function! object#except#Exception(msg, ...)
  return object#except#BaseException('Exception', a:msg, a:000)
endfunction

function! object#except#ValueError(msg, ...)
  return object#except#BaseException('ValueError', a:msg, a:000)
endfunction

function! object#except#TypeError(msg, ...)
  return object#except#BaseException('TypeError', a:msg, a:000)
endfunction

function! object#except#AttributeError(msg, ...)
  return object#except#BaseException('AttributeError', a:msg, a:000)
endfunction
