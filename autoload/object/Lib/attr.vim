" Attribute Handling
" NOTE: Currently, special attrs not not lookuped through
" getattr().
let s:builtins = object#Lib#builtins#GetModuleDict()
" NOTE: Python3 says some names will be missing, which will be
" different from release to release.
" We only filter some common patterns like __mro__.
let s:dir_ignored = object#Lib#class#GetIgnoredAttros()

function! s:CheckName(name) abort "{{{1
  if object#Lib#value#IsString(a:name)
    return a:name
  endif
  call object#TypeError("attribute name must be string, not '%s'",
        \ object#Lib#value#TypeName(a:name))
endfunction

function! s:ThrowNoAttro(obj, name)
  call object#AttributeError("'%s' object has no attribute '%s'",
        \ object#Lib#value#TypeName(a:obj),  a:name)
endfunction

function! object#Lib#attr#Object__getattribute__(name) dict abort "{{{1
  " Implement object.__getattribute__()
  let name = s:CheckName(a:name)
  try
    let Val = a:obj[a:name]
  catch 'E716:'
    call s:ThrowNoAttro(self, a:name)
  endtry
  return Val
endfunction

function! object#Lib#attr#ReadOnlyAttro(name, val) dict abort "{{{1
  let name = s:CheckName(a:name)
  try
    call object#Lib#attr#GetAttro(a:obj, name)
  catch 'AttributeError'
    throw v:exception
  endtry
  call object#AttributeError("'%s' object attribute '%s' is read-only",
        \ a:obj.__class__.__name__, name)
endfunction

function! object#Lib#attr#ReadOnlyAttro2(name, val) dict abort "{{{1
  call object#AttributeError('readonly attribute')
endfunction

function! object#Lib#attr#GetAttro(obj, name, ...) abort "{{{1
  call object#Lib#value#TakeAtMostOptional('getattr', 1, a:0)
  let obj = object#Lib#value#CheckObj('getattr', 1, a:obj)
  let name = s:CheckName(a:name)
  try
    let Val = object#Lib#func#CallFuncref(obj.__getattribute__, name)
    return Val
  catch 'AttributeError'
    if has_key(obj, '__getattr__')
      try
        let Val = object#Lib#callable#CallFuncref(obj.__getattr__, name)
        return Val
      catch 'AttributeError'
        if a:0 == 1
          return a:1
        endif
        throw v:exception
      endtry
    endif
    if a:0 == 1
      return a:1
    endif
    throw v:exception
  endtry
endfunction
let s:builtins.getattr = function('object#Lib#attr#GetAttro')

function! object#Lib#attr#SetAttro(obj, name, val) abort "{{{1
  let obj = object#Lib#value#CheckObj('setattr', 1, a:obj)
  let name = s:CheckName(a:name)
  if has_key(obj, '__setattr__')
    return object#Lib#callable#CallFuncref(obj.__setattr__, name, a:val)
  endif
  try
    let obj[name] = a:val
  catch 'E741:' " lockvar
    call object#RuntimeError(object#Lib#except#FormatVimError(v:exception))
  endtry
endfunction
let s:builtins.setattr = function('object#Lib#attr#SetAttro')

function! object#Lib#attr#HasAttro(obj, name) abort "{{{1
  let obj = object#Lib#value#CheckObj('hasattr', 1, a:obj)
  let name = s:CheckName(a:name)
  try
    call object#Lib#attr#GetAttro(obj, name)
  catch 'AttributeError'
    return 0
  endtry
  return 1
endfunction
let s:builtins.hasattr = function('object#Lib#attr#HasAttro')

function! object#Lib#attr#DelAttro(obj, name) abort "{{{1
  let obj = object#Lib#value#CheckObj('delattr', 1, a:obj)
  let name = s:CheckName(a:name)
  if has_key(a:obj, '__delattr__')
    return object#Lib#func#CallFuncref(a:obj.__delattr__, a:name)
  endif
  try
    unlet a:obj[a:name]
  catch 'E713:\|E716:\|E717:'
    call s:ThrowNoAttro(a:obj, a:name)
  endtry
endfunction
let s:builtins.delattr = function('object#Lib#attr#DelAttro')

" TODO: differentiate module, class and object.
" TODO: When we have classmethod/staticmethod, do something here.
" TODO: dir() returns keys of current module (#7)
function! object#Lib#attr#Object__dir__() dict abort "{{{1
  " Implement object.__dir__()
  return sort(filter(keys(self), 'index(s:dir_ignored, v:val)<0'))
endfunction

function! s:builtins.dir(obj) "{{{1
  let obj = object#Lib#value#CheckObj('dir', 1, a:obj)
  return object#Lib#func#CallFuncref(obj.__dir__)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
