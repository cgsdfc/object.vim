""
" @section class, class
" functions for creating both classes and instances and testing their
" relationships.
" Inheritance is possible. The methods of base classes are added from left to
" right across the [bases] when class() is called. The methods defined for
" this class effectively override those from bases.
"
"
" Features:
"   * Multiple inheritance.
"   * Calling methods from supers.
"   * Type identification.
"
" Drawbacks:
"   * Use more space for the house keeping attributes.
"   * Takes more time for the class and instance creation.
"
" Limitations:
"   * Methods are resolved statically at class creation time, which makes the
"     class object even larger.


let s:object_class = object#object_()
let s:type_class = object#type_()
let s:None = object#None()

let s:special_attrs = ['__class__', '__base__', '__name__', '__bases__']

""
" Define a class that has a {name} and optional base class(es).
" {name} should be a |String| of valid identifier in Vim.
" [bases] should be a class object or a |List| of class objects.
" If no [bases] are given or [bases] is an empty |List|, the new class will subclass object.
" Return the newly created class with only inherited attributes.
function! object#class#class(name, ...)
  let name = maktaba#ensure#IsString(a:name)
  let argc = object#util#ensure_argc(1, a:0)

  " Figure out the bases list
  if !argc
    let bases = [s:object_class]
  elseif maktaba#value#IsList(a:1)
    if empty(a:1)
      let bases = [s:object_class]
    else
      let bases = a:1
    endif
  elseif maktaba#value#IsDict(a:1)
    let bases = [a:1]
  else
    throw object#TypeError("'bases' should be a class or a List of classes")
  endif

  call object#class#ensure_bases(bases)
  let cls = {
        \ '__class__' : s:type_class,
        \ }
  call object#class#class_init(cls, name, bases)
  return cls
endfunction

""
" Create a new instance.
" This is done by first creating a skeleton object from the attributes
" of the {cls} and then calling __init__ of the newly created object
" with [args].
function! object#class#new(cls, ...)
  let cls = object#class#ensure_class(a:cls)
  let obj = {
        \ '__class__': a:cls,
        \ }
  call extend(obj, object#class#methods(a:cls))
  call call(obj.__init__, a:000)
  return obj
endfunction

""
" type(obj) -> class of obj.
"
" type(name, bases, dict) -> a new type.
function! object#class#type(...)
  if a:0 == 1
    let obj = object#class#ensure_object(a:1)
    return object#getattr(obj, '__class__')
  endif
  if a:0 == 3
    return object#new(s:type_class, a:1, a:2, a:3)
  endif
  throw object#TypeError('type() takes 1 or 3 arguments (%d given)', a:0)
endfunction

""
" Return a method from the direct base {cls} of {obj}.
" This is done by binding the methods of {cls} to {obj}.
"
" @throws TypeError if {cls} is not a direct base of {obj}.
function! object#class#super(cls, obj, method)
  let cls = object#class#ensure_class(a:cls)
  let obj = object#class#ensure_object(a:obj)
  let method = object#util#ensure_identifier(
        \ maktaba#ensure#IsString(a:method))

  let cls = object#class#find_base(obj, cls)
  if cls isnot# v:none
    let method = object#getattr(cls, method)
    return function(method, obj)
  endif

  throw object#TypeError('%s object has no base class %s',
        \ object#types#name(obj), string(cls.__name__))
endfunction

""
" Return whether {obj} is an instance of {cls}.
function! object#class#isinstance(obj, cls)
  let cls = object#class#ensure_class(a:cls)
  let obj = object#class#ensure_object(a:obj)
  let Pred = function('object#isinstance_pred', [a:obj])
  return object#class#any_parent(a:cls, Pred)
endfunction

""
" Return wheter {cls} is a subclass of {base}.
function! object#class#issubclass(cls, base)
  let cls = object#class#ensure_class(a:cls)
  let base = object#class#ensure_class(a:base)
  let Pred = function('object#class#issubclass_pred', [a:base])
  return object#class#any_parent(a:cls, Pred)
endfunction

"
" A valid class is a valid object that is an instance of type.
"
function! object#class#is_valid_class(x)
  return object#class#is_valid_object(a:x) && a:x.__class__ is# s:type_class
endfunction

"
" Every valid object is a |Dict| with a __class__ attribute.
"
function! object#class#is_valid_object(x)
  return object#hasattr(a:x, '__class__')
endfunction

function! object#class#is_method(Key, Val)
  " Any method should be valid identifier.
  let Key = object#util#ensure_identifier(a:Key)
  return index(s:special_attrs, Key) < 0 && maktaba#value#IsFuncref(a:Val)
endfunction

"
" Extract methods from {cls}.
"
function! object#class#methods(cls)
  return filter(copy(a:cls), 'object#class#is_method(v:key, v:val)')
endfunction

"
" Ensure that {x} is one valid class or a list of
" non-duplicate classes.
"
function! object#class#ensure_bases(x)
  let base = map(a:x, 'object#class#ensure_class(v:val)')
  let N = len(base)
  if N == 1
    return base
  endif
  let i = 0
  while i < N-1
    let j = i + 1
    while j < N
      if base[i] isnot# base[j]
        let j += 1
        continue
      endif
      throw object#TypeError('duplicate base class %s', string(base[i].__name__))
    endwhile
    let i += 1
  endwhile
  return base
endfunction

"
" Implementation of type.__init__. Initialize {cls} with class name,
" base classes and attributes.
" {bases} must be a List of classes.
"
function! object#class#type_init(cls, name, bases, dict)
  let name = maktaba#ensure#IsString(a:name)
  let bases = maktaba#ensure#IsList(a:bases)
  let dict = maktaba#ensure#IsDict(a:dict)
  call object#class#class_init(a:cls, name, bases)
  let dict = map(a:dict, 'object#util#ensure_identifier(v:key)')
  call extend(a:cls, dict, 'force')
endfunction

"
" Implemente the inheritance system.
"
function! object#class#class_init(cls, name, bases)
  let a:cls.__name__ = object#util#ensure_identifier(a:name)
  let a:cls.__bases__ = object#class#ensure_bases(a:bases)
  let a:cls.__base__ = a:bases[0]

  for x in a:bases
    call extend(a:cls, object#class#methods(x), 'keep')
  endfor
endfunction

"
" Find the base class of {obj} that matches {cls}. Return v:none
" if not found.
"
function! object#class#find_base(obj, cls)
  let bases = a:obj.__class__.__bases__
  for x in bases
    if x is# a:cls
      return x
    endif
  endfor
  return v:none
endfunction

function! object#class#ensure_class(x)
  if object#class#is_valid_class(a:x)
    return a:x
  endif
  throw object#TypeError("not a valid class")
endfunction

function! object#class#ensure_object(x)
  if object#class#is_valid_object(a:x)
    return a:x
  endif
  throw object#TypeError("not a valid object")
endfunction

"
" Visit the parents of {cls} and itself in a depth-first
" manner until any of them satisfies the {Predicate}.
function! object#class#any_parent(cls, Predicate)
  if a:Predicate(a:cls)
    return 1
  endif
  if a:cls is# s:None
    return 0
  endif
  for p in a:cls.__bases__
    if object#class#any_parent(p, a:Predicate)
      return 1
    endif
  endfor
  return 0
endfunction

function! object#class#issubclass_pred(base, cls)
  return a:cls is# a:base
endfunction

function! object#class#isinstance_pred(obj, cls)
  return a:obj.__class__ is# a:cls
endfunction
