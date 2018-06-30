function! object#Lib#item#CheckKey(key) abort "{{{1
  " Only string and number can be used.
  " By explicitly disallowing other types, we don't need to catch
  " mysterious Vim errors and save the day.
  if object#Lib#value#IsString(a:key) || object#Lib#value#IsNumber(a:key)
    return a:key
  endif
  call object#TypeError("dict key must be string or integer, not %s",
        \ object#Lib#value#TypeName(a:key))
endfunction

function! s:CheckIndex(index) abort "{{{1
  if object#Lib#value#IsNumber(a:index)
    return a:index
  endif
  call object#TypeError("list indices must be integer, not %s",
        \ object#Lib#value#TypeName(a:index))
endfunction

" Since Unicode only suppoerts GetItem, the check is inlined.
function! s:Unicode_GetItem(str, index) abort "{{{
  if !object#Lib#value#IsNumber(a:index)
    call object#TypeError("string indices must be integers")
  endif
  " When index out of range, Vim returns an empty string.
  " That's why we have to figure it out here.
  let index = a:index
  if index < 0
    let index += strchars(a:str)
  endif
  if index < 0 || index >= strchars(a:str)
    " Note: use the original index.
    call object#IndexError("string index out of range: %d", a:index)
  endif
  " Make up for unicode.
  let index = index * 3
  return a:str[index: index+2]
endfunction

function! s:Dict_GetItem(dict, key) abort "{{{1
  let key = object#Lib#item#CheckKey(a:key)
  try
    let Val = a:dict[key]
  catch 'E713:\|E716:\|E717:'
    call object#KeyError(object#Lib#except#FormatVimError(v:exception))
  endtry
  return Val
endfunction

function! s:Dict_SetItem(dict, key, val) abort "{{{1
  let key = object#Lib#item#CheckKey(a:key)
  try
    let a:dict[key] = a:val
  catch 'E741:'
    " lockvar
    call object#RuntimeError(object#Lib#except#FormatVimError(v:exception))
  endtry
endfunction

function! s:Dict_DelItem(dict, key) abort "{{{1
  let key = object#Lib#item#CheckKey(a:key)
  try
    unlet a:dict[key]
  catch 'E713:\|E716:\|E717:'
    " Key not present.
    call object#KeyError(object#Lib#except#FormatVimError(v:exception))
  endtry
endfunction

function! s:List_GetItem(list, index) abort "{{{1
  " Python just report 'list index out of range' without giving
  " the explicit index, while Vim makes it wrong for negative index
  " by giving the `index + len`.
  let index = s:CheckIndex(a:index)
  try
    let Val = a:list[index]
  catch 'E684:'
    " Vim gets wrong about negative index.
    call object#IndexError('list index out of range: %d', a:index)
  endtry
  return Val
endfunction

function! s:List_SetItem(list, index, val) abort "{{{1
  let index = s:CheckIndex(a:index)
  try
    let a:list[index] = a:val
  catch 'E684:'
    call object#IndexError('list index out of range: %d', a:index)
  catch 'E741:'
    " lockvar
    call object#RuntimeError(object#Lib#except#FormatVimError(v:exception))
  endtry
endfunction

" TODO: do the range check in CheckIndex() and save the day!
function! s:List_DelItem(list, index) abort "{{{1
  let index = s:CheckIndex(a:index)
  try
    unlet a:list[index]
  catch 'E684:'
    call object#IndexError('list index out of range: %d', a:index)
  endtry
endfunction

function! object#Lib#item#GetItem(obj, key) abort "{{{1
  if !object#Lib#proto#IsSubscriptable(a:X)
    call object#TypeError("'%s' object doesn't support indexing",
          \ object#builtin#TypeName(a:X))
  endif
  if object#Lib#value#IsString(a:obj)
    return s:Unicode_GetItem(a:obj, a:key)
  endif
  if object#Lib#value#IsList(a:obj)
    return s:List_GetItem(a:obj, a:key)
  endif
  if object#Functions#HasMethod(a:obj, '__getitem__')
    return object#Lib#func#CallFuncref(a:obj.__getitem__, a:key)
  endif
  return s:Dict_GetItem(a:obj, a:key)
endfunction
let s:builtins.getitem = function('object#Lib#item#GetItem')

function! object#Lib#item#SetItem(obj, key, val) abort "{{{1
  if !object#Lib#proto#IsSubscriptAssignable(a:X)
    call object#TypeError("'%s' object doesn't support item assignment",
          \ object#builtin#TypeName(a:X))
  endif
  if object#Lib#value#IsList(a:obj)
    return s:List_SetItem(a:obj, a:key, a:val)
  endif
  if object#Lib#proto#HasMethod(a:obj, '__setitem__')
    return object#Lib#func#CallFuncref(a:obj.__setitem__, a:key, a:val)
  endif
  return s:Dict_SetItem(a:obj, a:key, a:val)
endfunction
let s:builtins.setitem = function('object#Lib#item#SetItem')

function! object#Lib#item#DelItem(obj, key) abort "{{{1
  if !object#Lib#proto#IsSubscriptDeletable(a:X)
    call object#TypeError("'%s' object doesn't support item deletion",
          \ object#builtin#TypeName(a:X))
  endif
  if object#Lib#value#IsList(a:obj)
    return s:List_DelItem(a:obj, a:key)
  endif
  if object#Lib#proto#HasMethod(a:obj, '__delitem__')
    return object#Lib#func#CallFuncref(a:obj.__delitem__, a:key)
  endif
  return s:Dict_DelItem(a:obj, a:key)
endfunction
let s:builtins.delitem = function('object#Lib#item#DelItem')

" vim: set sw=2 sts=2 et fdm=marker:
