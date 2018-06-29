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

function! object#Lib#item#CheckIndex(index) abort "{{{1
  if object#Lib#value#IsNumber(a:index)
    return a:index
  endif
  call object#TypeError("list indices must be integer, not %s",
        \ object#Lib#value#TypeName(a:index))
endfunction

function! object#Lib#item#Dict_GetItem(dict, key) abort "{{{1
  let key = object#Lib#item#CheckKey(a:key)
  try
    let Val = a:dict[key]
  catch 'E713:\|E716:\|E717:'
    call object#KeyError(object#Lib#except#FormatVimError(v:exception))
  endtry
  return Val
endfunction

function! object#Lib#item#Dict_SetItem(dict, key, val) abort "{{{1
  let key = object#Lib#item#CheckKey(a:key)
  try
    let a:dict[key] = a:val
  catch 'E741:'
    " lockvar
    call object#RuntimeError(object#Lib#except#FormatVimError(v:exception))
  endtry
endfunction

function! object#Lib#item#Dict_DelItem(dict, key) abort "{{{1
  let key = object#Lib#item#CheckKey(a:key)
  try
    unlet a:dict[key]
  catch 'E713:\|E716:\|E717:'
    " Key not present.
    call object#KeyError(object#Lib#except#FormatVimError(v:exception))
  endtry
endfunction

function! object#Lib#item#List_GetItem(list, index) abort "{{{1
  " Python just report 'list index out of range' without giving
  " the explicit index, while Vim makes it wrong for negative index
  " by giving the `index + len`.
  let index = object#Lib#item#CheckIndex(a:index)
  try
    let Val = a:list[index]
  catch 'E684:'
    " Vim gets wrong about negative index.
    call object#IndexError('list index out of range: %d', a:index)
  endtry
  return Val
endfunction

function! object#Lib#item#List_SetItem(list, index, val) abort "{{{1
  let index = object#Lib#item#CheckIndex(a:index)
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
function! object#Lib#item#List_DelItem(list, index) abort "{{{1
  let index = object#Lib#item#CheckIndex(a:index)
  try
    unlet a:list[index]
  catch 'E684:'
    call object#IndexError('list index out of range: %d', a:index)
  endtry
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
