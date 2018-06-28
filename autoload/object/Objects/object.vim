let s:object = object#Lib#RawType_New('object')

function! s:object.__repr__()
  return s:Object_Repr(self)
endfunction

function! s:object.__str__()
  return s:Object_Repr(self)
endfunction

function! s:Object_Repr(obj)
  return printf('<%s object>', a:obj.__class__.__name__)
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
