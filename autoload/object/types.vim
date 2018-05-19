""
" top classes definition without the object#class()
" facilities.
"   object
"   type
"   NoneType

function! object#types#name(obj)
  if object#hasattr(a:obj, '__class__')
    return string(a:obj.__class__.__name__)
  endif
  return string(maktaba#value#TypeName(a:obj))
endfunction

function! object#types#rawtype(name)
  return {
        \ '__name__': a:name,
        \ }
endfunction

function! object#types#install_base(cls, base)
  let a:cls.__base__ = a:base
  let a:cls.__bases__ = [a:base]
  let a:cls.__class__ = s:type_class
endfunction

let s:object_class = object#types#rawtype('object')
let s:type_class = object#types#rawtype('type')
let s:none_class = object#types#rawtype('NoneType')

call object#types#install_base(s:object_class, s:none_class)
call object#types#install_base(s:none_class, s:type_class)
call object#types#install_base(s:type_class, s:type_class)

function! s:object_class.__repr__()
  return printf('<%s object>', object#types#name(self))
endfunction

function! s:none_class.__repr__()
  return ''
endfunction

function! s:type_class.__repr__()
  return printf('<type %s>', object#types#name(self))
endfunction

function! s:object_class.__init__()
endfunction

function! s:none_class.__init__()
  throw object#TypeError('cannot create %s instance', object#types#name(self))
endfunction

function! s:type_class.__init__(name, bases, dict)
  call object#class#type_init(self, a:name, a:bases, a:dict)
endfunction

""
" object()
" Create a plain object.
function! object#types#object()
  return object#new(s:object_class)
endfunction

""
" object_()
" Return the object class
function! object#types#object_()
  return s:object_class
endfunction

""
" type_()
" Return the type class
function! object#types#type_()
  return s:type_class
endfunction

function! object#types#NoneType()
  return s:none_class
endfunction
