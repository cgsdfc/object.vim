let s:object = object#Lib#builtins#Get('object')

function! s:object.__new__(type)
  if !object#Lib#value#IsType(a:type)
    call object#TypeError("object.__new__(X): X is not a type object (%s)",
          \ object#Lib#value#TypeName(a:type))
  endif
  return object#Lib#class#Object_New(a:type)
endfunction

function! s:object.__repr__()
  return s:Object_Repr(self)
endfunction

function! s:object.__str__()
  return s:Object_Repr(self)
endfunction

function! s:object.__init__()

endfunction

function! s:object.__setattr__(name, val)
  return object#Lib#attr#ReadOnlyAttro2(self, a:name, a:val)
endfunction

function! s:object.__getattribute__(name)
  let name = object#Lib#attr#CheckName(a:name)
  try
    let Val = a:obj[a:name]
  catch 'E716:'
    call object#Lib#attr#NoAttribute(self, a:name)
  endtry
  return Val
endfunction

function! s:object.__dir__()
  return object#Lib#attr#Dir(self)
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
