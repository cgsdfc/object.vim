""
" @section Types, types
" Define a minimal set of fundamental types as the basic of the type
" hierarchy.
" They are:
"   * object(None): The base class of all the rest of classes. The base class of it is
"     None, the only instance of the NoneType.
"
"   * type(object): The class of all the types for both built-in and user
"     definded ones. In other words, every class is an instance of type.
"
"   * NoneType(type): The class of the None object, the place holder for
"   absence of sensible values, such as the base class of object.

" Note: We cannot use in global scope any of the functions from class.vim.

" TODO: __new__() hook

" TODO mv to object#util#typename()
" Get the typename of {obj}. If {obj} is a type,
" 'type' will be returned always.
function! object#types#name(obj)
  if object#hasattr(a:obj, '__class__')
    return string(a:obj.__class__.__name__)
  endif
  return string(maktaba#value#TypeName(a:obj))
endfunction

" Install special attrs.
function! object#types#install(obj, name, class, base, mro)
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

call object#types#install(s:object, 'object', s:type, s:None, [s:object])
call object#types#install(s:type, 'type', s:type, s:object, [s:type, s:object])
call object#types#install(s:NoneType, 'NoneType', s:type, s:object, [s:NoneType, s:type, s:object])

"
" object and type
"
for s:obj in [s:object, s:type]
  function! s:obj.__repr__()
    return printf('<%s object>', string(self.__class__.__name__))
  endfunction
  function! s:obj.__bool__()
    return 1
  endfunction
endfor

"
" NoneType
"
for s:obj in [s:NoneType, s:None]
  function! s:obj.__init__()
    throw object#TypeError('cannot create NoneType instance')
  endfunction
  function! s:obj.__repr__()
    return ''
  endfunction
  function! s:obj.__bool__()
    return 0
  endfunction
endfor

" Actually an NOP.
function! s:object.__init__()
endfunction

"
" type() creates new class when called with 3 arguments.
function! s:type.__init__(name, bases, dict)
  call object#class#type_init(self, a:name, a:bases, a:dict)
endfunction

""
" @function object()
" Create a plain object.
function! object#types#object()
  return object#new(s:object)
endfunction

""
" @function object_()
" Return the object class
function! object#types#object_()
  return s:object
endfunction

""
" @function type_()
" Return the type class
function! object#types#type_()
  return s:type
endfunction

""
" @function NoneType()
" Return the NoneType class
function! object#types#NoneType()
  return s:NoneType
endfunction

""
" @function None()
" Return the None object
function! object#types#None()
  return s:None
endfunction

""
" @function bool(...)
" Convert [args] to a Bool, i.e., 0 or 1.
" >
"   bool() -> False
"   bool(Funcref) -> True
"   bool(List, String or plain Dict) -> not empty
"   bool(Number) -> non-zero
"   bool(Float) -> non-zero
"   bool(v:false, v:null, v:none) -> False
"   bool(v:true) -> True
"   bool(obj) -> obj.__bool__()
" <
function! object#types#bool(...)
  call object#util#ensure_argc(1, a:0)
  if !a:0
    " bool() <==> false
    return 0
  endif
  let Obj = a:1
  if has('float') && maktaba#value#IsFloat(Obj)
    return Obj !=# 0.0
  endif
  if maktaba#value#IsFuncref(Obj)
    return 1
  endif
  if maktaba#value#IsString(Obj) || maktaba#value#IsList(Obj)
    return !empty(Obj)
  endif
  try
    " If we directly return !!Obj, the exception cannot
    " be caught.
    let x = !!Obj
    return x
  catch/E728/ " Using a Dictionary as a Number
    if object#hasattr(Obj, '__bool__')
      " Thing returned from bool() should be canonical, so as __bool__.
      " Prevent user from mistakenly return something like 1.0
      return maktaba#ensure#IsBool(object#protocols#call(Obj.__bool__))
    endif
    return !empty(Obj)
  catch
    call object#except#not_avail('bool', Obj)
  endtry
endfunction
