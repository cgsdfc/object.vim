function! object#Lib#seqn#Any(seqn, predicate) abort "{{{1
  return !empty(filter(map(copy(a:seqn), a:predicate), '!v:val'))
endfunction

function! object#Lib#seqn#All(seqn, predicate) abort "{{{1
  return empty(filter(map(copy(a:seqn), a:predicate), 'v:val'))
endfunction

function! object#Lib#seqn#Dict_Contains(dict, key) abort "{{{1
  return has_key(a:dict, object#Lib#item#CheckKey(a:key))
endfunction

function! object#Lib#seqn#Iterable_Contains(iterable, target) abort "{{{1
  " Return whether `target` is in `iterable`.
  let iter = object#iter(a:iterable)
  try
    while 1
      " TODO: use object#eq()
      if maktaba#value#IsEqual(a:target, object#next(iter))
        return 1
      endif
    endwhile
  catch 'StopIteration'
    return 0
  endtry
endfunction

function! object#Lib#seqn#Unicode_Contains(haystack, needle) abort "{{{1
  if object#Lib#value#IsString(a:needle)
    return stridx(a:haystack, a:needle) >= 0
  endif
  call object#TypeError(
        \ "'in <string>' requires string as left operand, not %s",
        \ object#Lib#value#TypeName(a:needle))
endfunction

function! object#Lib#seqn#List_Contains(haystack, needle) abort "{{{1
  " TODO: object#eq
  return index(a:haystack, a:needle) >= 0
endfunction

function! object#Lib#seqn#Call__len__(obj) abort "{{{1
  let num = object#Lib#value#CheckNumber2(object#Lib#func#CallFuncref(a:obj.__len__))
  if num >= 0
    return num
  endif
  call object#ValueError("__len__() should return >= 0")
endfunction

function! object#Lib#seqn#Unicode_Len(X) abort "{{{1
  return strchars(a:X)
endfunction

function! object#Lib#seqn#Len(obj) abort "{{{1
  if object#Lib#value#IsString(a:obj)
    return object#Lib#seqn#Unicode_Len(a:obj)
  endif
  if object#Lib#value#IsContainer(a:obj)
    return len(a:obj)
  endif
  if object#Lib#proto#HasProtocol(a:obj, '__len__')
    return object#proto#seqn#Call__len__(a:obj)
  endif
  call object#TypeError("object of type '%s' has no len()",
        \ object#Lib#value#TypeName(a:obj))
endfunction

function! object#Lib#seqn#in(needle, haystack) abort "{{{1
  if object#Lib#value#IsList(a:haystack)
    return object#Lib#seqn#List_Contains(a:haystack, a:needle)
  endif
  if object#Lib#value#IsString(a:haystack)
    return object#Lib#seqn#Unicode_Contains(a:haystack, a:needle)
  endif
  if object#Lib#value#IsDict(a:haystack)
    return object#Lib#seqn#Dict_Contains(a:haystack, a:needle)
  endif
  if object#Lib#proto#HasProtocol(a:haystack, '__contains__')
    " NOTE: return value of __contains__() is a bool context.
    return object#bool(
          \ object#Lib#func#CallFuncref(a:haystack.__contains__, a:needle))
  endif
  return object#Lib#seqn#Iterable_Contains(a:haystack, a:needle)
endfunction

" TOOD: sorted()

" vim: set sw=2 sts=2 et fdm=marker:
