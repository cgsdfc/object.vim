function! object#Lib#item#contains(dict, key)
  return has_key(a:dict, object#Lib#item#CheckKey(a:key))
endfunction

" FUNCTION: contains() {{{1
function! object#Lib#item#contains(haystack, needle)
  " TODO: object#eq
  return index(a:haystack, a:needle) >= 0
endfunction
function! object#Lib#item#CheckedCallLen(obj) "{{{1
  let num = object#Lib#value#CheckNumber2(object#builtin#CallFuncref(a:obj.__len__))
  if num >= 0
    return num
  endif
  call object#ValueError("__len__() should return >= 0")
endfunction

function! object#Lib#item#Len(obj)
  if object#Lib#value#IsString(a:obj)
    return object#str#len(a:obj)
  endif
  if object#Lib#value#IsList(a:obj)
    return len(a:obj)
  endif

  if object#Lib#value#IsDict(a:obj)
    if !has_key(a:obj, '__class__')
      " Plain dict
      return len(a:obj)
    endif
    if has_key(a:obj, '__len__')
      return object#proto#item#CheckedCallLen(a:obj)
    endif
  endif
  call object#TypeError("object of type '%s' has no len()",
        \ object#Lib#value#TypeName(a:obj))

endfunction

function! object#Lib#item#in(needle, haystack)
  if object#Lib#value#IsList(a:haystack)
    return object#list#contains(a:haystack, a:needle)
  endif

  if object#Lib#value#IsString(a:haystack)
    return object#str#contains(a:haystack, a:needle)
  endif

  if object#Lib#value#IsDict(a:haystack)
    if !has_key(a:haystack, '__class__')
      " NOTE: We don't ensure a:needle is a String.
      " Just let automatic conversion happen.
      return object#dict#contains(a:haystack, a:needle)
    endif
    if has_key(a:haystack, '__contains__')
      " NOTE: return value of __contains__() is a bool context.
      return object#bool(
            \ object#Lib#value#CallFuncref(a:haystack.__contains__, a:needle))
    endif
    if has_key(a:haystack, '__iter__')
      return object#iter#contains(a:haystack, a:needle)
    endif
  endif

  call object#TypeError("argument of type '%s' is not iterable",
        \ object#Lib#value#TypeName(a:haystack))
endfunction


endfunction

" TOOD: sorted()

