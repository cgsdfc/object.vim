""
" This file serves as a shallow namespace for all the object
" facilities. Object.vim aims to be a bunch of convenient functions
" that enables object protocols in Vim. Functions in files other than
" this file is implementation details that users should never bother.


""
" From object#class
"   class()
"   type()
"   super()
"   new()
"   isinstance()
"   issubclass()

""
" class(name[,bases])
" Define a class that has a name and optional base class(es).
" >
"   let Widget = object#class('Widget')
"   let Widget = object#class('Widget', [...])
" <
" [bases] should be a |Dict| or a |List| of |Dict| that was defined by |class()|.
" {name} should be a |String| of valid identifier in Vim
" ([_a-zA-Z][_a-zA-Z0-9]*).
" The return value is special |Dict| to which methods can be added to and from
" which instance can be created by |object#new()|.
" Methods can be added by:
" >
"   function! Widget.say_yes()
"   let Widget.say_yes = function('widget#say_yes')
" <
"
" Inheritance is possible. The methods of base classes are added from left to
" right across the [bases] when |class()| is called. The methods defined for
" this class effectively override those from bases.
function! object#class(...) abort
  return call('object#class#class', a:000)
endfunction

""
" type(object)
" Return the class of {object}.
function! object#type(...) abort
  return call('object#class#type', a:000)
endfunction

""
" super(cls, object, method)
" Return a partial |Funcref| that binds the dict of {method}
" of the base class {cls} of {object} to {object}
" Examples:
" >
"   call object#super(Base, self, '__init__')(...)
" <
function! object#super(...) abort
  return call('object#class#super', a:000)
endfunction

""
" new(cls[, args])
" Create a new instance of {cls} by applying optional [args].
function! object#new(...) abort
  return call('object#class#new', a:000)
endfunction

""
" isinstance(object, cls)
" Return whether {object} is an instance of {cls}.
function! object#isinstance(...) abort
  return call('object#class#isinstance', a:000)
endfunction

""
" issubclass(cls, base)
" Return wheter {cls} is a subclass of {base}.
function! object#issubclass(...) abort
  return call('object#class#issubclass', a:000)
endfunction

""
" From object#protocols
"
" Protocols are a list of functions that operates on
" different aspects of an object and can be overrided
" by special methods of that class.
" The most basic protocols are:
"
"   dir()
"   getattr()
"   setattr()
"   hasattr()
"
"   len()
"   hash()
"   getitem()
"   setitem()

""
" dir(object)
" Return a |List| of names of all attributes from {object}. If
" {object} defines __dir__(), it is called instead.
function! object#dir(...)
  return call('object#protocols#dir', a:000)
endfunction

""
" getattr(object, name[, default])
" Return the {name} attribute of {object}. Call __getattr__()
" if {object} has one. Otherwise, if no {name} is found and [default]
" is provided, the [default] is returned. If no [default] is given and
" no {name} is found, @exception(AttributeError) is thrown.
" @throws AttributeError.
function! object#getattr(...) abort
  return call('object#protocols#getattr', a:000)
endfunction

""
" setattr(object, name, value)
" Set the {name} attribute of {object} to {value}.
function! object#setattr(...) abort
  return call('object#protocols#setattr', a:000)
endfunction

""
" hasattr(object, name)
" Return whether {object} has attribute {name}.
function! object#hasattr(...) abort
  return call('object#protocols#hasattr', a:000)
endfunction

""
" len(object)
" Return the length of {object}. If {object} is a |List|
" or a |Dict|, |len()| will be called. Otherwise, the __len__()
" of {object} will be called.
function! object#len(...) abort
  return call('object#protocols#len', a:000)
endfunction

""
" hash(object)
" Return the hash value of {object}. TODO
function! object#hash(...) abort
  return call('object#protocols#hash', a:000)
endfunction

""
" getitem(object, key)
" Return the value at {key} in {object} as if {object} is a mapping.
" If {object} is a |List| or |Dict|, operator[] of Vim will be used.
function! object#getitem(...) abort
  return call('object#protocols#getitem', a:000)
endfunction

""
" setitem(object, key, value)
" Set the value at {key} of {object} to {value}.
" If {object} is a |List| or |Dict|, let {object}[{key}] = {value}
" will be used. Otherwise, __setitem__() of {object} will be used.
function! object#setitem(...) abort
  return call('object#protocols#setitem', a:000)
endfunction

""
" From object#except
"   BaseException
"   Exception
"   ValueError
"   TypeError
"   AttributeError

function! object#BaseException(...) abort 
  return call('object#except#BaseException', a:000)
endfunction

function! object#Exception(...) abort
  return call('object#except#Exception', a:000)
endfunction

function! object#ValueError(...) abort
  return call('object#except#ValueError', a:000)
endfunction

function! object#TypeError(...) abort
  return call('object#except#TypeError', a:000)
endfunction

function! object#AttributeError(...) abort
  return call('object#except#AttributeError', a:000)
endfunction

""
" From object#types
" Built in types
"   object()
"   object_()
"   type_()

""
" object()
" Create a plain object.
function! object#object(...) abort
  return call('object#types#object', a:000)
endfunction

""
" object_()
" Return the object class
function! object#object_(...) abort
  return call('object#types#object_', a:000)
endfunction

""
" type_()
" Return the type class
function! object#type_(...) abort
  return call('object#types#type_', a:000)
endfunction
