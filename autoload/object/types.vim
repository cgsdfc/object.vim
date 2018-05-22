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

"
" Get the typename of {obj}. If {obj} is a type,
" 'type' will be returned always.
"
function! object#types#name(obj)
  if object#hasattr(a:obj, '__class__')
    return string(a:obj.__class__.__name__)
  endif
  return string(maktaba#value#TypeName(a:obj))
endfunction

"
" Install the __base__, __name__ and __class__ attributes
" for {obj}.
"
function! object#types#install(obj, name, class, base)
  let a:obj.__name__ = a:name
  let a:obj.__base__ = a:base
  let a:obj.__bases__ = [a:base]
  let a:obj.__class__ = a:class
endfunction

let s:object_class = {}
let s:type_class = {}
let s:none_class = {}
let s:None = { '__class__' : s:none_class }

call object#types#install(s:object_class, 'object', s:type_class, s:None)
call object#types#install(s:none_class, 'NoneType', s:type_class, s:object_class)
call object#types#install(s:type_class, 'type', s:type_class, s:object_class)

"
" Define basic methods for the top classes.
"

"
" Representation string.
"
function! object#types#repr() dict
  return printf('<%s object>', string(self.__class__.__name__))
endfunction

function! s:None.__repr__()
  return ''
endfunction

let s:object_class.__repr__ = function('object#types#repr')
let s:type_class.__repr__ = function('object#types#repr')
let s:none_class.__repr__ = function('object#types#repr')

function! s:object_class.__init__()
endfunction

function! s:none_class.__init__()
  throw object#TypeError('cannot create NoneType instance')
endfunction

"
" The type() creates new class when called with 3 arguments.
"
function! s:type_class.__init__(name, bases, dict)
  call object#class#type_init(self, a:name, a:bases, a:dict)
endfunction

""
" Create a plain object.
function! object#types#object()
  return object#new(s:object_class)
endfunction

""
" Return the object class
function! object#types#object_()
  return s:object_class
endfunction

""
" Return the type class
function! object#types#type_()
  return s:type_class
endfunction

""
" Return the NoneType class
function! object#types#NoneType()
  return s:none_class
endfunction

""
" Return the None object
function! object#types#None()
  return s:None
endfunction

""
" Test whether {obj} is true. For collections like
" |List| and |Dict|, non empty is true. For special
" variables, v:none, v:false, v:null is false and v:true
" is true. For numbers, 0 is false and non-zero is true.
" For floats, 0.0 is false and everything else if true.
" For |Funcref|,
"
" Hook into __bool__.
" TODO: Move bool(), int(), float() into types
if has('float')
  function! object#types#bool(obj)
    if maktaba#value#IsFloat(a:obj)
      return a:obj !=# 0
    endif
    if maktaba#value#IsFuncref(a:obj)
      return 1
    endif
    if maktaba#value#IsString(a:obj) || maktaba#value#IsList(a:obj)
      return !empty(a:obj)
    endif
    return object#types#bool_nofloat(a:obj)
  endfunction
else
  function! object#types#bool(obj)
    return object#types#bool_nofloat(a:obj)
  endfunction
endif

function! object#types#bool_nofloat(obj)
  try
    " If we directly return !!a:obj, the exception cannot
    " be caught.
    let x = !!a:obj
    return x
  catch/E728/ " Using a Dictionary as a Number
    if object#hasattr(a:obj, '__bool__')
      " Thing returned from bool() should be canonical, so as __bool__.
      " Prevent user from mistakenly return something like 1.0
      return maktaba#ensure#IsBool(object#protocols#call(a:obj.__bool__))
    endif
    return !empty(a:obj)
  catch
    call object#except#not_avail('bool', a:obj)
  endtry
endfunction
