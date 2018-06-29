let s:type = object#Lib#builtins#Get('type')

function! s:type.__new__(...)
  return call('object#Lib#type#Type_New', a:000)
endfunction

function! s:type.__repr__()
  return object#Lib#repr#Type_Repr(self)
endfunction
