let s:builtins = object#Lib#builtins#GetModuleDict()

function! s:Dict_Contains(dict, key) abort "{{{1
  return has_key(a:dict, object#Lib#item#CheckKey(a:key))
endfunction

function! s:Unicode_Contains(haystack, needle) abort "{{{1
  if object#Lib#value#IsString(a:needle)
    return stridx(a:haystack, a:needle) >= 0
  endif
  call object#TypeError(
        \ "'in <string>' requires string as left operand, not %s",
        \ object#Lib#value#TypeName(a:needle))
endfunction

function! s:List_Contains(haystack, needle) abort "{{{1
  " TODO: object#eq
  return index(a:haystack, a:needle) >= 0
endfunction

function! object#Lib#seqn#Call__len__(obj) abort "{{{1
  " Call obj.__len__() and check the result.
  let num = object#Lib#func#CallFuncref(a:obj.__len__)
  if object#Lib#value#CheckNumber2(num) >= 0
    return num
  endif
  call object#ValueError("__len__() should return >= 0")
endfunction

function! object#Lib#seqn#Len(obj) abort "{{{1
  " Implement len(obj).
  if object#Lib#value#IsString(a:obj)
    return strchars(a:obj)
  endif
  if object#Lib#value#IsContainer(a:obj)
    return len(a:obj)
  endif
  if object#Lib#proto#HasMethod(a:obj, '__len__')
    return object#proto#seqn#Call__len__(a:obj)
  endif
  call object#TypeError("object of type '%s' has no len()",
        \ object#Lib#value#TypeName(a:obj))
endfunction
let s:builtins.len = function('object#Lib#seqn#Len')

function! object#Lib#seqn#IsIn(needle, haystack) abort "{{{1
  " Implement `needle in haystack`.
  if object#Lib#value#IsList(a:haystack)
    return s:List_Contains(a:haystack, a:needle)
  endif
  if object#Lib#value#IsString(a:haystack)
    return s:Unicode_Contains(a:haystack, a:needle)
  endif
  if object#Lib#value#IsDict(a:haystack)
    return s:Dict_Contains(a:haystack, a:needle)
  endif
  if object#Lib#proto#HasMethod(a:haystack, '__contains__')
    return object#bool(
          \ object#Lib#func#CallFuncref(a:haystack.__contains__, a:needle))
  endif
  return object#Lib#iter#Contains(a:haystack, a:needle)
endfunction
let s:builtins.in = function('object#Lib#seqn#IsIn')

function! object#Lib#seqn#Any(seqn, predicate) abort "{{{1
  return !empty(filter(map(copy(a:seqn), a:predicate), '!v:val'))
endfunction

function! object#Lib#seqn#All(seqn, predicate) abort "{{{1
  return empty(filter(map(copy(a:seqn), a:predicate), 'v:val'))
endfunction

" TOOD: sorted()

" vim: set sw=2 sts=2 et fdm=marker:
