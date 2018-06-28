" Attribute getting, setting, testing and listing.
let s:builtin = object#Lib#builtins#GetModuleDict()

function! s:builtin.getattr(obj, name, ...) "{{{1
  call object#Lib#value#TakeAtMostOptional('getattr', 1, a:0)
  let obj = object#Lib#value#CheckObj('getattr', 1, a:obj)
  let name = object#Lib#attr#CheckName(a:name)
  return object#Lib#attr#GetAttro(obj, name)
endfunction

function! s:builtin.setattr(obj, name, val) "{{{1
  " TODO: __setattr__ for class to validate val.
  " Use metaclass's __setattr__ for a class.
  let obj = object#Lib#value#CheckObj('setattr', 1, a:obj)
  let name = object#Lib#attr#CheckName(a:name)
  return object#Lib#attr#SetAttro(obj, name, a:val)
endfunction

function! s:builtin.hasattr(obj, name) "{{{1
  let obj = object#Lib#value#CheckObj('hasattr', 1, a:obj)
  let name = object#Lib#attr#CheckName(a:name)
  return object#Lib#attr#HasAttro(obj, name)
endfunction

function! s:builtin.dir(obj) "{{{1
  let obj = object#Lib#value#CheckObj('dir', 1, a:obj)
  return object#Lib#func#CallFuncref(obj.__dir__)
endfunction

function! s:builtin.delattr(obj, name) "{{{1
  let obj = object#Lib#value#CheckObj('delattr', 1, a:obj)
  let name = object#Lib#attr#CheckName(a:name)
  return object#Lib#attr#DelAttro(obj, name)
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
