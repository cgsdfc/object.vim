let s:object = object#Lib#builtins#Get('object')


function! s:object.__new__(type, ...)
  if !object#Lib#type#IsType(a:type)
    call object#TypeError("object.__new__(X): X is not a type object (%s)",
          \ object#Lib#value#TypeName(a:type))
  endif
  return object#Lib#class#Object__new__(a:type)
endfunction

let s:object.mro = function('object#Lib#type#Object_mro')
let s:object.__repr__ = function('object#Lib#repr#Object__repr__')
let s:object.__str__ = function('object#Lib#repr#Object__repr__')
let s:object.__setattr__ = function('object#Lib#attr#ReadOnlyAttro2')
let s:object.__getattribute__ = function('object#Lib#attr#Object__getattribute__')
let s:object.__dir__ = function('object#Lib#attr#Object__dir__')

function! s:object.__init__()

endfunction

function! s:object.__eq__(v)
  return self is# a:v
endfunction

function! s:object.__ne__(v)
  return self isnot# a:v
endfunction

function! s:object.__hash__()
  return 0
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
