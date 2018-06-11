" Format an exception string.
function! object#except#format(type, msg, args)
  return printf('%s: %s', a:type, empty(a:args) ?
        \ a:msg : call('printf', [a:msg] + a:args))
endfunction

""
" @function BaseException(...)
" Generate exception for a specific {type}. User can call BaseException
" to define their own exception functions.
" Examples:
" >
"   function! MyException(msg, ...)
"     return object#BaseException('MyException', a:msg, a:000)
"   endfunction
" <
function! object#except#BaseException(type, msg, args)
  let type = object#util#ensure_identifier(a:type)
  let msg = maktaba#ensure#IsString(a:msg)
  let args = maktaba#ensure#IsList(a:args)
  return object#except#format(a:type, a:msg, a:args)
endfunction

""
" @function Exception(...)
" Generic exception.
function! object#except#Exception(msg, ...)
  return object#except#BaseException('Exception', a:msg, a:000)
endfunction

""
" @function ValueError(...)
" The value of function arguments went wrong.
function! object#except#ValueError(msg, ...)
  return object#except#BaseException('ValueError', a:msg, a:000)
endfunction

""
" @function TypeError(...)
" Unsupported operation for a type or wrong number of arguments passed
" to a function.
function! object#except#TypeError(msg, ...)
  return object#except#BaseException('TypeError', a:msg, a:000)
endfunction

""
" @function AttributeError(...)
" The object has no such attribute or the attribute is readonly.
function! object#except#AttributeError(msg, ...)
  return object#except#BaseException('AttributeError', a:msg, a:000)
endfunction

""
" @function StopIteration(...)
" The end of iteration. Thrown by __iter__ usually.
function! object#except#StopIteration()
  return 'StopIteration:'
endfunction

""
" @function IndexError(...)
" Index out of range for sequences.
function! object#except#IndexError(msg, ...)
  return object#except#BaseException('IndexError', a:msg, a:000)
endfunction

""
" @function KeyError(...)
" Key out of range for sequences.
function! object#except#KeyError(msg, ...)
  return object#except#BaseException('KeyError', a:msg, a:000)
endfunction

""
" @function IOError(...)
" File not writable or readable. Operation on a closed file. Thrown by
" file objects usually.
function! object#except#IOError(msg, ...)
  return object#except#BaseException('IOError', a:msg, a:000)
endfunction

" Helper to throw 'no such attribute'
"
function! object#except#throw_noattr(obj, name)
  throw object#AttributeError('%s object has no attribute %s',
        \ object#types#name(a:obj), string(a:name))
endfunction

"
" Indicate the the {func} is not available for {obj} because of
" lack of hooks or invcompatible type. {func} is the name of the
" function without parentheses.
"
function! object#except#not_avail(func, obj)
  throw object#TypeError('%s() not available for %s object',
        \  a:func, object#types#name(a:obj))
endfunction
