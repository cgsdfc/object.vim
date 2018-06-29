let s:type = object#Lib#builtins#Get('type')

function! s:type.__new__(...)
  return call('object#Lib#type#Type_New', a:000)
endfunction

let s:type.__repr__ = function('object#Lib#repr#Type__repr__')
let s:type.__str__ = function('object#Lib#repr#Type__repr__')

function! s:type.__hash__()
  return object#Lib#hash#HashString(self.__name__)
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
