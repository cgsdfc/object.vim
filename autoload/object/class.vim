" MIT License
" 
" Copyright (c) 2018 cgsdfc
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.

""
" @section Class, class
" This module provides functions for the creation and manipulation
" of classes and instances. Below, the term "class" is used interchangably
" with "type" to refer to the object representing a class,
" since there is no "old-style" class in object.vim. Every class
" is derived from `object` (except `object`). The term "class object" is avoided
" since it reminds people of the "old-style" class.
"
" @subsection compared-with-related-approaches
" There are different approaches to create classes in Vimscript. To
" get the best of them, we compare them and show design rationales of
" object.vim at the same time.
"
" The most common approach is via a simple assignment:
" >
"   let s:MyClass = {}
"   function! s:MyClass.some_method()
"     " some code
"   endfunction
"
"   let var = deepcopy(s:MyClass)
" <
" This approach has the virtue of being brief, but obviously a plain `{}`
" can't have too much features.
"
" Here is a command-based approach:
" >
"   Class MyClass, some_bases
"     " some methods
"   EndClass
" <
" This approach introduces new commands that begins and ends the class
" definition. It looks very like a DSL, which goes against the aim of
" object.vim, which says no new syntax is required.
"
" Another approach defines all the methods inside a function that creates the class:
" >
"   function! s:GetMyClass()
"     let s:MyClass = {}
"     function! s:MyClass.some_method()
"       " some code
"     endfunction
"     " more methods
"     return deepcopy(s:MyClass)
"   endfunction
" <
" This approach looks nice as it bundles all the methods together. However,
" it mixes together the definition of a class and the instantiation of it,
" making both aspects less flexible.
"
" With these limitations in mind, object.vim is designed to be intuitively
" usable yet very flexible:
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
" Note that the resulting class takes a copy of the base list so you are free
" to modify it after `class()` returns.
"
" With MI comes MRO (Method Resolution Order) and C3 algorithm is used to construct the
" `__mro__` attribute for each class.  Methods are resolved statically based
" on `__mro__`, which means the changes to `__bases__` will not cause a rerun
" of method resolution. All the attributes from parents are added to their
" child respecting its `__mro__`, which can be overridden naturally by adding
" methods with the same names. This means you can call parents' methods in several ways:
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
" call the parents' version with `super()`. See @section(super) for more
" information.
"
"
" @subsection special-attributes
" Like Python, object.vim uses double-underscored names for special
" attributes. The use of such attributes in the class modules aims to be minimal,
" as it takes space off every class and instance. Currently, these are:
"
" Class:
"   * __name__: the name of the class, a valid identifier.
"   * __base__: the first direct base.
"   * __bases__: the list of direct bases.
"   * __mro__: the list of method resolution order.
"   * __class__: currently always the `type` class.
"
" Instance:
"   * __class__: the type of this instance.
"
"
" @subsection attributes
" We have been talking about attributes, but what are they in the context of
" object.vim? Basically everything inside a |Dict| with its name as an
" identifier is an attribute. Particularly, if the attribute is a |Funcref|,
" it is treated as instance methods. This is important since when an
" instance is created, it will have all the |Funcref| attributes of its class
" as its methods. Anything other than |Funcref| stays in the class as it,
" which implies:
"   * A class cannot have `classmethod`. You should not call methods on a class.
"   * A class can have its own attributes, as long as they are not |Funcref|.
"
" The lack of `classmethod` sounds discouraging because classes are no longer
" first-class object and they will fail with some protocols.
" That may be improved in the future.
"
" @subsection class-name-and-identity
" There is no notion of class-registry in object.vim and the `name` argument
" got passed to `class()` is not checked for uniqueness. This means it is
" possible for two different class to have the same name. However, as long as the
" variables holding the classes have distinct names, there won't be name crashes.
" What's more, every class will have different identities testable by
" `is#` since `class()` always creates new class. As currently the name of a
" class is only used to provide its `repr()` (not as the key to anything),
" you are free to crash your class names with other's without a doubt :-).
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

" 
" let s:MyClass.__classmethods__ = [...]
" Then when new() is called, we can filter out those names in
" __classmethods__. Alternatively, we can provide helper to mark
" a method is classmethod, like:
" function! object#classmethod(cls, name)
"   call add(a:cls.__classmethods__, a:name)
"   return a:cls
" endfunction
" Use like:
" call object#classmethod(s:MyClass, 'some')
" function! s:MyClass.some()
"   ...
" endfunction
" But it is somehow too repeated?
" Note: the point here is to mark some methods using book-keeping
" inside the class object.
let s:object_class = object#object_()
let s:type_class = object#type_()
let s:None = object#None()

let s:special_attrs = ['__class__', '__base__', '__name__', '__bases__', '__mro__']

""
" @function class(...)
" Define a class that has a {name} and [bases] and optionally
" insert it into [scope].
" >
"   class(name) -> inherited from object
"   class(name, bases) -> inherited from bases
"   class(name, bases, scope) -> scope[name] = cls
" <
" {name} should be a |String| of valid identifier.
" [bases] should be a class or a |List| of classes.
" If no [bases] are given or [bases] is an empty |List|,
" the new class will subclass `object`.
function! object#class#class(name, ...)
  let argc = object#util#ensure_argc(2, a:0)
  if a:0 == 2
    let scope = maktaba#ensure#IsDict(a:2)
  endif

  " Figure out the bases list
  if !argc
    let bases = []
  elseif maktaba#value#IsDict(a:1)
    let bases = [a:1]
  else
    let bases = a:1
  endif

  let cls = {
        \ '__class__' : s:type_class,
        \}
  call object#class#class_init(cls, a:name, bases)
  if a:0 == 2
    let scope[a:name] = cls
  endif
  return cls
endfunction

""
" @function new(...)
" Create a new instance of {cls}.
" >
"   new(cls[, args]) -> a new instance of cls
" <
function! object#class#new(cls, ...)
  return object#class#new_(a:cls, a:000)
endfunction

""
" @function new_(...)
" Create a new instance of {cls}.
" >
"   new_(cls, args) -> a new instance of cls
" <
function! object#class#new_(cls, args)
  let args = maktaba#ensure#IsList(a:args)
  let cls = object#class#ensure_class(a:cls)
  let obj = {
        \ '__class__': cls,
        \ }
  call extend(obj, object#class#methods(cls))
  call call(obj.__init__, args)
  return obj
endfunction

""
" @function type(...)
" Return the type of an object or create a new type.
" >
"   type(obj) -> the type of obj
"   type(name, bases, dict) -> a new type.
" <
function! object#class#type(...)
  if a:0 == 1
    return object#class#ensure_object(a:1).__class__
  endif
  if a:0 == 3
    return object#new_(s:type_class, a:000)
  endif
  call object#TypeError('type() takes 1 or 3 arguments (%d given)', a:0)
endfunction

""
" @function isinstance(...)
" Return whether {obj} is an instance of {cls}.
" >
"   isinstance(obj, cls) -> if obj is an instance of cls
" <
function! object#class#isinstance(obj, cls)
  return object#class#is_valid_object(a:obj) &&
        \ object#class#is_valid_class(a:cls) &&
        \ object#class#find_class(a:cls, a:obj.__class__) >= 0
endfunction

""
" @function issubclass(...)
" Return whether {cls} is a subclass of {base}.
" >
"   issubclass(cls, base) -> if cls is a subclass of base
" <
function! object#class#issubclass(cls, base)
  return object#class#is_valid_class(a:cls) &&
        \ object#class#is_valid_class(a:base) &&
        \ object#class#find_class(a:base, a:cls) >= 0
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
  return maktaba#value#IsDict(a:x) && has_key(a:x, '__class__')
endfunction

"
" A method is a |Funcref| attribute.
"
function! object#class#is_method(Key, Val)
  let Key = object#util#ensure_identifier(a:Key)
  return index(s:special_attrs, Key) < 0 && maktaba#value#IsFuncref(a:Val)
endfunction

"
" Extract methods from {cls}.
" {cls} will be copied first.
"
function! object#class#methods(cls)
  return filter(copy(a:cls), 'object#class#is_method(v:key, v:val)')
endfunction

" Ensure that {x} is one valid class or a list of
" non-duplicate classes.
function! object#class#ensure_bases(x)
  let bases = maktaba#ensure#IsList(a:x)
  let N = len(bases)
  let i = 0
  while i < N-1
    let j = i + 1
    while j < N
      call object#class#ensure_class(bases[i])
      if bases[i] isnot# bases[j]
        let j += 1
        continue
      endif
      call object#TypeError('duplicate base class %s', string(bases[i].__name__))
    endwhile
    let i += 1
  endwhile
  return bases
endfunction

"
" Initialize a class with {name}, {bases} and a {dict} of attributes.
"
function! object#class#type_init(cls, name, bases, dict)
  let dict = maktaba#ensure#IsDict(a:dict)
  call object#class#class_init(a:cls, a:name, a:bases)
  call extend(a:cls, object#class#methods(dict), 'force')
endfunction

"
" Initialize various special attributes of a class.
"
function! object#class#class_init(cls, name, bases)
  let a:cls.__name__ = object#util#ensure_identifier(a:name)
  if empty(a:bases)
    let a:cls.__bases__ = [s:object_class]
  elseif len(a:bases) == 1
    let a:cls.__bases__ = [object#class#ensure_class(a:bases[0])]
  else
    let a:cls.__bases__ = copy(object#class#ensure_bases(a:bases))
  endif
  let a:cls.__base__ = a:cls.__bases__[0]
  if len(a:bases) == 1
    let a:cls.__mro__ = [a:cls] + a:bases[0].__mro__
  else
    let a:cls.__mro__ = object#class#mro(a:cls)
  endif
  for x in a:cls.__mro__
    call extend(a:cls, object#class#methods(x), 'keep')
  endfor
endfunction

" Compute Method Resolution Order for {cls}.
function! object#class#mro(cls)
  let bases = copy(a:cls.__bases__)
  let bases_mro = map(copy(bases), 'copy(v:val.__mro__)')
  let mro = object#class#merge(add(bases_mro, copy(bases)))
  if mro isnot# 0
    " Since cls by no means can appear in bases or bases_mro,
    " it is safe to prepend it to the merged list.
    return insert(mro, a:cls)
  endif
  call object#TypeError(
        \ 'cannot create a consistent method resolution for bases %s',
        \ join(map(bases, 'v:val.__name__'), ', '))
endfunction

"
" Whether {cls} appears at the tail of {list}.
" The tail of a list is all the elements except the first one.
"
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

"
" Merge the {list} of candidates in a C3 manner.
"
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
          let cand = 0
          break
        endif
      endfor
      if cand isnot# 0
        break
      endif
    endfor
    if cand is# 0
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
  call object#TypeError('not a valid class')
endfunction

function! object#class#ensure_object(x)
  if object#class#is_valid_object(a:x)
    return a:x
  endif
  call object#TypeError('not a valid object')
endfunction

"
" Find a needle in the __mro__ of haystack.
" Return the index of needle.
" Return -1 if needle is not in haystack
"
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

" An unchecked version of class() supposed to work faster
" with the large Exception hierarchy.
function! object#class#builtin_class(name, base, scope)
  let bases = [a:base]
  let cls = {
        \ '__name__': a:name,
        \ '__class__': s:type_class,
        \ '__base__': a:base,
        \ '__bases__': bases,
        \}
  let cls.__mro__ = [cls] + a:base.__mro__
  for x in a:base.__mro__
    " 
    call extend(cls, filter(copy(x), 'maktaba#value#IsFuncref(v:val)'), 'keep')
  endfor
  let a:scope[a:name] = cls
endfunction
