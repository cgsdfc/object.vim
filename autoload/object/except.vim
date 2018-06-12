""
" @function BaseException(...)
" User can use `BaseException()` to define their own exception functions.
" >
"   BaseException(type) -> type:
"   BaseException(type, [msg]) -> type: msg
"   BaseException(type, [msg, *args] -> type: printf(msg, *args)
" <
" Examples:
" >
"   function! MyException(...)
"     return object#BaseException('MyException', a:000)
"   endfunction
" <
function! object#except#BaseException(type, ...)
  call object#util#ensure_argc(1, a:0)
  let type = object#util#ensure_identifier(a:type)
  let args = a:0 ? maktaba#ensure#IsList(a:1): []
  let len = len(args)
  if len == 0
    return printf('%s:', type)
  endif
  call maktaba#ensure#IsString(args[0])
  if len == 1
    return printf('%s: %s', type, args[0])
  endif
  return printf('%s: %s', type, call('printf', args))
endfunction

""
" @function Exception(...)
" Generic exception.
function! object#except#Exception(...)
  return object#BaseException('Exception', a:000)
endfunction

""
" @function ValueError(...)
" The value of function arguments went wrong.
function! object#except#ValueError(...)
  return object#BaseException('ValueError', a:000)
endfunction

""
" @function TypeError(...)
" Unsupported operation for a type or wrong number of arguments passed
" to a function.
function! object#except#TypeError(...)
  return object#BaseException('TypeError', a:000)
endfunction

""
" @function AttributeError(...)
" The object has no such attribute or the attribute is readonly.
function! object#except#AttributeError(...)
  return object#BaseException('AttributeError', a:000)
endfunction

""
" @function StopIteration(...)
" Iteration stops.
function! object#except#StopIteration()
  return object#BaseException('StopIteration')
endfunction

""
" @function IndexError(...)
" Index out of range for sequences.
function! object#except#IndexError(...)
  return object#BaseException('IndexError', a:000)
endfunction

""
" @function KeyError(...)
" Key out of range for sequences.
function! object#except#KeyError(...)
  return object#BaseException('KeyError', a:000)
endfunction

""
" @function IOError(...)
" File not writable or readable. Operation on a closed file. Thrown by
" file objects usually.
function! object#except#IOError(...)
  return object#BaseException('IOError', a:000)
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
