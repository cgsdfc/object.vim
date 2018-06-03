""
" @section Class, class
" This module provides functions for the creation and manipulation
" of classes and instances. Below, the term "class" is used interchangably
" with "type" to refer to the object representing a class
" since there is no "old-style" class in object.vim. Every class
" except `object` is derived from `object`. The term "class object" is avoided
" since it reminds people of the "old-style" class.
"
" @subsection conventions-matter
" The first important thing is to be substitutable to old conventions, which
" means the class is returned by a function just like:
" >
"   let s:MyClass = {}
" <
" Compared with the approaches that introduce new syntax,
" respecting old conventions makes new code easy to write and understand.
" Here is a command-based approach:
" >
"   Class A, somebases
"     " some methods
"   EndClass
" <
" Another novel approach uses functions-inside-a-function, which requires all the methods to be
" defined inside a "class-initializer" function:
" >
"   function! s:init_MyClass() dict
"     call ClassInit(self, 'MyClass')
"     function! self.some_method()
"       some code
"     endfunction
"     " more methods
"   endfunction
"   let s:MyClass = ClassNew('s:init_MyClass')
" <
" This approach can hardly find its place in practice.
" With the current syntax, you create a new class and add methods to it
" intuitively:
" >
"   let s:Logger = object#class('Logger')
"
"   function! s:Logger.info(...)
"     return self.log('info', a:000)
"   endfunction
" <
"
" @subsection multiple-inheritance
" Many people go against MI (Multiple Inheritance) because it complicates
" the program. Nonetheless, it it more expressive than single
" inheritance. That's why it is supported.
"
" The functions that deal with MI is `class()`, `type()` and `super()`.
" Both `class()` and `type()` takes an optional `bases`
" argument which can be:
"   * omitted: derived from `object`.
"   * a single class: derived from that.
"   * a |List| of classes: derived from all those classes.
"   * an empty list: the same as omitted.
"
" Note that the resulting class takes a copy of your base list so you are free
" to modify it after `class()` returns.
"
" With MI comes MRO (Method Resolution Order) and I use C3 to construct the
" `__mro__` attribute for each class.  Methods are resolved statically based
" on `__mro__`, which means the changes to `__bases__` will not cause a rerun
" of method resolution. All the attributes from parents are added to their
" child respecting its `__mro__`, which can be overridden naturally by adding
" methods with the same names. The discussion above means you can call
" parents' methods in several ways:
" >
"   let s:Animal = object#class('Animal')
"   function! s:Animal.make_sound()
"     echo 'Animal makes sound'
"   endfunction
"
"   let s:Dog = object#class('Dog', s:Animal)
"   function! s:Dog.bark()
"     call self.make_sound()
"     echo 'Dog barks'
"   endfunction
"
"   let dog = object#new(s:Dog)
"   call dog.make_sound()
"   Animal makes sound
"
"   echo has_key(dog, 'make_sound')
"   1
" <
" However, if the child is overriding a method of its parents, it can only
" call the parents' version with `super()`, as in:
" >
"   function! s:Dog.make_sound()
"     call object#super(s:Dog, self, 'make_sound')()
"     echo 'Dog makes sound'
"   endfunction
"
"   call dog.make_sound()
"   Animal makes sound
"   Dog makes sound
" <
" `super()` will look up methods in parents or siblings for you.
"
" @subsection special-attributes
" Like Python, object.vim uses double-underscored names for special
" attributes. The use of such attributes in the class modules aims to be minimal,
" as it takes space off every class and instance. Currently, these are:
"
" Class:
"   * __name__: the name of the class, a valid identifier.
"   * __base__: the first direct base.
"   * __bases__: the direct bases.
"   * __mro__: the method resolution list.
"   * __class__: always the `type` class currently.
"
" Instance:
"   * __class__: the type of this instance.
"
" The meanings of these class-specific special attributes are part of the
" public interface of object.vim that you can count on.
"
" @subsection attributes
" We have been talking about attributes, but what are they in the context of
" object.vim? Basically everything inside a |Dict| with its name as an
" identifier is an attribute. Particularly, if the attribute is a |Funcref|,
" it is treated as methods for instance only. This is important since when an
" instance is created, it will have all the |Funcref| attributes of its class
" as its methods. Anything other than |Funcref| stays in the class as it,
" which implies:
"   * A class does not have `classmethod`. You should not call methods on a
"   class.
"   * A class can have its own attributes, as long as they are not |Funcref|.
"
" The lack of `classmethod` sounds discouraging because classes are no longer
" first-class object and they will fail with some protocols. That is just one
" of the limitations.
"
" @subsection class-name-and-identity
" There is no notion of class-registry in object.vim and the `name` argument
" got passed to `class()` is not checked for uniqueness. This means it is
" possible for two different class to have the same name. However, as long as the
" variables holding the classes have distinct names, there won't be name crash.
" What's more, every class will have different identities testable by
" `is#` since `class()` always creates new class. As currently the name of a
" class is only used to provide `repr()`, not as the key to anything,
" you are free to crash your class names with other's without doubt :-).
"
" @subsection exposing-class
" As you write plugins you may wish to let others extend or instantiate your
" classes. Here are the ways to do so:
" >
"   " You can do this:
"   function! useful#Formatter_()
"     return s:Formatter
"   endfunction
"
"   " so that user can inherit your class
"   let s:useful_Formater = useful#Formatter_()
"   let s:MyFormatter = object#class('MyFormatter', s:useful_Formater)
"
"   " and instantiate it.
"   let formatter = object#new(s:useful_Formater)
"
"   " You can also do this:
"   function! useful#Formatter(...) abort
"     return object#new_(s:Formatter, a:000)
"   endfunction
"
"   " to feel more like a constructor:
"   let formatter = useful#Formatter()
" <

let s:object_class = object#object_()
let s:type_class = object#type_()
let s:None = object#None()

let s:special_attrs = ['__class__', '__base__', '__name__', '__bases__', '__mro__']

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
      let bases = copy(a:1)
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
  return object#class#new_(a:cls, a:000)
endfunction

""
" Create a new instance.
" Take a |List| as {args} rather than variadic arguments.
function! object#class#new_(cls, args)
  let cls = object#class#ensure_class(a:cls)
  let obj = {
        \ '__class__': a:cls,
        \ }
  call extend(obj, object#class#methods(a:cls))
  call call(obj.__init__, a:args)
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
"
" @throws TypeError if !isinstance({type}, {obj})
function! object#class#super(type, obj, name)
  let type = object#class#ensure_class(a:type)
  let obj = object#class#ensure_object(a:obj)
  let name = object#util#ensure_identifier(a:name)
  let idx = object#class#find_class(type, obj.__class__)
  if idx < 0
    throw object#TypeError('super() requires isinstance(type, obj)')
  endif
  let mro = obj.__class__.__mro__
  try
    let next = mro[idx + 1]
  catch /E684/ " IndexError
    throw object#TypeError('%s object has no superclass', object#types#name(obj))
  endtry
  if has_key(next, name)
    return function(maktaba#ensure#IsFuncref(next[name]), obj)
  endif
  throw object#except#throw_noattr(obj, name)
endfunction

""
" Return whether {obj} is an instance of {cls}.
function! object#class#isinstance(obj, cls)
  return object#class#find_class(object#class#ensure_class(a:cls),
        \ object#class#ensure_object(a:obj).__class__) >= 0
endfunction

""
" Return whether {cls} is a subclass of {base}.
" A class is considered a subclass of itself.
function! object#class#issubclass(cls, base)
  return object#class#find_class(object#class#ensure_class(a:cls),
        \ object#class#ensure_class(a:base)) >= 0
endfunction

"
" A valid class is a valid object that has __mro__
"
function! object#class#is_valid_class(x)
  return object#class#is_valid_object(a:x) && has_key(a:x, '__mro__')
endfunction

"
" Every valid object is a |Dict| with a __class__ attribute.
"
function! object#class#is_valid_object(x)
  return object#hasattr(a:x, '__class__')
endfunction

function! object#class#is_method(Key, Val)
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
  call extend(a:cls, object#class#methods(dict), 'force')
endfunction

"
" Implemente the inheritance system.
"
function! object#class#class_init(cls, name, bases)
  let a:cls.__name__ = object#util#ensure_identifier(a:name)
  let a:cls.__bases__ = object#class#ensure_bases(a:bases)
  let a:cls.__base__ = a:bases[0]
  let a:cls.__mro__ = object#class#mro(a:cls)

  for x in a:cls.__mro__
    call extend(a:cls, object#class#methods(x), 'keep')
  endfor
endfunction

" Compute Method Resolution Order for {cls}
" Require that each super class of it has a __mro__ list
function! object#class#mro(cls)
  let bases = copy(a:cls.__bases__)
  let bases_mro = map(copy(bases), 'copy(v:val.__mro__)')
  " Since cls by no means can appear in bases or bases_mro,
  " it is safe to prepend it to the merged list in the end.
  let mro = object#class#merge(add(bases_mro, copy(bases)))
  if mro isnot# v:none
    return insert(mro, a:cls)
  endif
  throw object#TypeError(
        \ 'cannot create a consistent method resolution for bases %s',
        \ join(map(bases, 'v:val.__name__'), ', '))
endfunction

function! object#class#in_tail(cls, list, len)
  let i = 1
  while i < a:len
    if a:cls is# a:list[i]
      return 1
    endif
    let i += 1
  endwhile
  return 0
endfunction

" Merge the list of lists given by arguments into one list
function! object#class#merge(list)
  let res = []
  let list = a:list
  while 1
    let list = filter(list, '!empty(v:val)')
    if empty(list)
      return res
    endif
    for x in list
      let cand = x[0]
      for y in list
        if object#class#in_tail(cand, y, len(y))
          let cand = v:none
          break
        endif
      endfor
      if cand isnot# v:none
        break
      endif
    endfor
    if cand is# v:none
      return cand
    endif
    call add(res, cand)
    for x in list
      if x[0] is# cand
        unlet x[0]
      endif
    endfor
  endwhile
endfunction

function! object#class#ensure_class(x)
  if object#class#is_valid_class(a:x)
    return a:x
  endif
  throw object#TypeError('not a valid class')
endfunction

function! object#class#ensure_object(x)
  if object#class#is_valid_object(a:x)
    return a:x
  endif
  throw object#TypeError('not a valid object')
endfunction

" Find a needle in the __mro__ of haystack.
" Return the index of needle.
" Return -1 if needle is not in haystack
function! object#class#find_class(needle, haystack)
  let mro = a:haystack.__mro__
  let i = 0
  let N = len(mro)
  while i < N
    if mro[i] is# a:needle
      return i
    endif
    let i += 1
  endwhile
  return -1
endfunction
