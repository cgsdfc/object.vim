
function! object#except#format(type, msg, args)
  return printf('%s: %s', a:type, empty(a:args) ?
        \ a:msg : call('printf', [a:msg] + a:args))
endfunction

function! object#except#BaseException(type, msg, args)
  let type = object#util#ensure_identifier(maktaba#ensure#IsString(a:type))
  let msg = maktaba#ensure#IsString(a:msg)
  let args = maktaba#ensure#IsList(a:args)
  return object#except#format(a:type, a:msg, a:args)
endfunction

""
" @exception
function! object#except#Exception(msg, ...)
  return object#except#BaseException('Exception', a:msg, a:000)
endfunction

""
" @exception
function! object#except#ValueError(msg, ...)
  return object#except#BaseException('ValueError', a:msg, a:000)
endfunction

""
" @exception
function! object#except#TypeError(msg, ...)
  return object#except#BaseException('TypeError', a:msg, a:000)
endfunction

""
" @exception
function! object#except#AttributeError(msg, ...)
  return object#except#BaseException('AttributeError', a:msg, a:000)
endfunction

""
" @exception
function! object#except#StopIteration()
  return 'StopIteration:'
endfunction

""
" @exception
function! object#except#IOError(msg, ...)
  return object#except#BaseException('IOError', a:msg, a:000)
endfunction

" Helper to throw 'no attribute'
"
function! object#except#throw_noattr(obj, name)
  throw object#AttributeError('%s object has no attribute %s',
        \ object#types#name(a:obj), string(a:name))
endfunction

function! object#except#throw_readonly_attr(obj, name)
  throw object#AttributeError('%s object attribute %s is readonly',
        \ object#types#name(a:obj), string(a:name))
endfunction
