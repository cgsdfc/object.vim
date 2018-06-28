" Install special attrs.
function! object#class#types#install(obj, name, class, base, mro)
  let a:obj.__name__ = a:name
  let a:obj.__base__ = a:base
  let a:obj.__bases__ = [a:base]
  let a:obj.__class__ = a:class
  let a:obj.__mro__ = a:mro
endfunction

let s:object = {}
let s:type = {}
let s:NoneType = {}
let s:None = { '__class__' : s:NoneType }

call object#class#types#install(s:object, 'object', s:type, s:None, [s:object])
call object#class#types#install(s:type, 'type', s:type, s:object, [s:type, s:object])
call object#class#types#install(s:NoneType, 'NoneType', s:type, s:object, [s:NoneType, s:type, s:object])

"
" object and type
"
for s:obj in [s:object, s:type]
  function! s:obj.__repr__()
    return printf('<%s object>', self.__class__.__name__)
  endfunction
  function! s:obj.__str__()
    return printf('<%s object>', self.__class__.__name__)
  endfunction
endfor

"
" NoneType
"
for s:obj in [s:NoneType, s:None]
  function! s:obj.__init__()
    "  TODO: Add __new__ and type(None)() should return None itself.
    "  Python3 never throws about this.
    call object#TypeError('cannot create NoneType instance')
  endfunction
  function! s:obj.__repr__()
    return 'None'
  endfunction
  function! s:obj.__bool__()
    return 0
  endfunction
  function! s:obj.__str__()
    return 'None'
  endfunction
endfor

" Actually an NOP.
function! s:object.__init__()
endfunction

function! s:object.__getattribute__(name)
  try
    let Val = a:obj[a:name]
  catch 'E716:'
    if has_key(a:obj, '__mro__')
      call object#AttributeError("type object %s has no attribute '%s'",
            \ a:obj.__name__,  a:name)
    else
      call object#AttributeError("'%s' object has no attribute '%s'",
            \ object#builtin#TypeName(a:obj),  a:name)
    endif
  endtry
  return Val
endfunction

"
" type() creates new class when called with 3 arguments.
function! s:type.__init__(name, bases, dict)
  call object#class#type_init(self, a:name, a:bases, a:dict)
endfunction

""
" @function object()
" Create a plain object.
function! object#class#types#object()
  return object#new(s:object)
endfunction

""
" @function object_()
" Return the object class
function! object#class#types#object_()
  return s:object
endfunction

""
" @function type_()
" Return the type class
function! object#class#types#type_()
  return s:type
endfunction

""
" @function None()
" Return the None object
function! object#class#types#None()
  return s:None
endfunction
