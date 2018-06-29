" FUNCTION: CheckSubscriptable() {{{1
function! object#Functions#mapping#CheckSubscriptable(X)
  if object#proto#IsSubscriptable(a:X)
    return a:X
  endif
  call object#TypeError("'%s' object doesn't support indexing",
        \ object#builtin#TypeName(a:X))
endfunction

" FUNCTION: CheckSubscriptAssignable() {{{1
function! object#Functions#mapping#CheckSubscriptAssignable(X)
  if object#proto#IsSubscriptAssignable(a:X)
    return a:X
  endif
  call object#TypeError("'%s' object doesn't support item assignment",
        \ object#builtin#TypeName(a:X))
endfunction

" FUNCTION: CheckSubscriptDeletable() {{{1
function! object#Functions#mapping#CheckSubscriptDeletable(X)
  if object#proto#IsSubscriptDeletable(a:X)
    return a:X
  endif
  call object#TypeError("'%s' object doesn't support item deletion",
        \ object#builtin#TypeName(a:X))
endfunction

" FUNCTION: getitem() {{{1
function! object#Functions#mapping#getitem(obj, key)
  let obj = object#proto#mapping#CheckSubscriptable(a:obj)
  if object#builtin#IsString(obj)
    return object#str#getitem(obj, a:key)
  endif
  if object#builtin#IsList(obj)
    return object#list#getitem(obj, a:key)
  endif
  if object#Functions#HasMethod(obj, '__getitem__')
    return object#builtin#CallFuncref(obj.__getitem__, a:key)
  endif
  " TODO: IsDict should exclude Obj.
  return object#dict#getitem(obj, a:key)
endfunction

" FUNCTION: setitem() {{{1
function! object#proto#mapping#setitem(obj, key, val)
  let obj = object#Functions#mapping#CheckSubscriptAssignable(a:obj)
  if object#builtin#IsList(obj)
    return object#list#setitem(obj, a:key, a:val)
  endif
  if object#proto#HasMethod(obj, '__setitem__')
    return object#builtin#CallFuncref(obj.__setitem__, a:key, a:val)
  endif
  return object#dict#setitem(obj, a:key, a:val)
endfunction

" FUNCTION: delitem() {{{1
function! object#Functions#mapping#delitem(obj, key)
  let obj = object#proto#mapping#CheckSubscriptDeletable(a:obj)
  if object#builtin#IsList(obj)
    return object#list#delitem(obj, a:key)
  endif
  if object#proto#HasMethod(obj, '__delitem__')
    return object#builtin#CallFuncref(obj.__delitem__, a:key)
  endif
  return object#dict#delitem(obj, a:key)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
