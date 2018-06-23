" FUNCTION: CheckSubscriptable() {{{1
function! object#mapping#CheckSubscriptable(X)
  if object#builtin#IsSubscriptable(a:X)
    return a:X
  endif
  call object#TypeError("'%s' object doesn't support indexing",
        \ object#builtin#TypeName(a:X))
endfunction

" FUNCTION: CheckSubscriptAssignable() {{{1
function! object#mapping#CheckSubscriptAssignable(X)
  if object#builtin#IsSubscriptAssignable(a:X)
    return a:X
  endif
  call object#TypeError("'%s' object doesn't support item assignment",
        \ object#builtin#TypeName(a:X))
endfunction

" FUNCTION: CheckSubscriptDeletable() {{{1
function! object#mapping#CheckSubscriptDeletable(X)
  if object#builtin#IsSubscriptDeletable(a:X)
    return a:X
  endif
  call object#TypeError("'%s' object doesn't support item deletion",
        \ object#builtin#TypeName(a:X))
endfunction

" FUNCTION: getitem() {{{1
function! object#mapping#getitem(obj, key)
  let obj = object#mapping#CheckSubscriptable(a:obj)
  if object#builtin#IsString(obj)
    return object#str#getitem(obj, a:key)
  endif
  if object#builtin#IsList(obj)
    return object#list#getitem(obj, a:key)
  endif
  if object#protocol#HasProtocol(obj, '__getitem__')
    return object#builtin#Call(obj.__getitem__, a:key)
  endif
  " TODO: IsDict should exclude Obj.
  return object#dict#getitem(obj, a:key)
endfunction

" FUNCTION: setitem() {{{1
function! object#mapping#setitem(obj, key, val)
  let obj = object#mapping#CheckSubscriptAssignable(a:obj)
  if object#builtin#IsList(obj)
    return object#list#setitem(obj, a:key, a:val)
  endif
  if object#protocol#HasProtocol(obj, '__setitem__')
    return object#builtin#Call(obj.__setitem__, a:key, a:val)
  endif
  return object#dict#setitem(obj, a:key, a:val)
endfunction

" FUNCTION: delitem() {{{1
function! object#mapping#delitem(obj, key)
  let obj = object#mapping#CheckSubscriptDeletable(a:obj)
  if object#builtin#IsList(obj)
    return object#list#delitem(obj, a:key)
  endif
  if object#protocol#HasProtocol(obj, '__delitem__')
    return object#builtin#Call(obj.__delitem__, a:key)
  endif
  return object#dict#delitem(obj, a:key)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
