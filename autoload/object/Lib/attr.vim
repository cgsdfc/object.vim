" Attribute Handling
" NOTE: Currently, special attrs not not lookuped through
" getattr().

" FUNCTION: CheckName() {{{1
function! object#Lib#attr#CheckName(name)
  if object#Lib#value#IsString(a:name)
    return a:name
  endif
  call object#TypeError("attribute name must be string, not '%s'",
        \ object#Lib#value#TypeName(a:name))
endfunction

function! object#Lib#attr#Object__getattribute__(name) dict abort "{{{1
  " Implement object.__getattribute__()
  let name = object#Lib#attr#CheckName(a:name)
  try
    let Val = a:obj[a:name]
  catch 'E716:'
    call object#Lib#attr#NoAttribute(self, a:name)
  endtry
  return Val
endfunction

function! object#Lib#attr#ReadOnlyAttro(name, val) dict abort "{{{1
  let name = object#Lib#attr#CheckName(a:name)
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

function! object#Lib#attr#ThrowNoAttro(obj, name)
  call object#AttributeError("'%s' object has no attribute '%s'",
        \ object#Lib#value#TypeName(a:obj),  a:name)
endfunction

function! object#Lib#attr#GetAttro(obj, name)
  try
    let Val = object#Lib#func#CallFuncref(obj.__getattribute__, name)
  catch 'AttributeError'
    if has_key(obj, '__getattr__')
      try
        let Val = object#Lib#callable#CallFuncref(obj.__getattr__, name)
      catch 'AttributeError'
        if a:0 == 1
          let Val = a:1
        else
          throw v:exception
        endif
      endtry
    elseif a:0 == 1
      let Val = a:1
    else
      throw v:exception
    endif
  endtry
  return Val
endfunction

function! object#Lib#attr#SetAttro(obj, name, val)
  if has_key(obj, '__setattr__')
    call object#Lib#callable#CallFuncref(obj.__setattr__, name, a:val)
  else
    let obj[name] = a:val
  endif
endfunction

function! object#Lib#attr#HasAttro(obj, name)
  try
    call object#Lib#attr#GetAttro(obj, name)
    " NOTE: Only AttributeError is concerned.
  catch 'AttributeError'
    return 0
  endtry
  return 1
endfunction

function! object#Lib#attr#DelAttro(obj, name)
  if has_key(a:obj, '__delattr__')
    return object#Lib#func#CallFuncref(a:obj.__delattr__, a:name)
  endif
  try
    unlet a:obj[a:name]
  catch 'E713:\|E716:\|E717:'
    call object#Lib#attr#ThrowNoAttro(a:obj, a:name)
  catch 'E741:'
    " lockvar
    call object#RuntimeError(object#Lib#except#FormatVimError(v:exception))
  endtry
endfunction

" VARIABLE: Some names ignored by dir(). {{{1
" NOTE: Python3 says some names will be missing, which will be
" different from release to release.
" We only filter some common patterns like __mro__.
let s:dir_ignored = ['__mro__', '__bases__', '__base__', '__name__',]
" TODO: differentiate module, class and object.
" TODO: When we have classmethod/staticmethod, do something here.
" TODO: dir() returns keys of current module (#7)

function! object#Lib#attr#Object__dir__() dict abort "{{{1
  " Implement object.__dir__()
  let dict = copy(self)
  if has_key(self, '__mro__')
    call extend(dict, self.__class__, 'keep')
  endif
  return sort(keys(filter(dict, 'index(s:dir_ignored, v:key)<0')))
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
