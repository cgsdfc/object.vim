""
" @section Introduction, intro
" @stylized object
" @library
" @order intro version protocols class mapping iter file types lambda
" dicts functions exceptions
" >
"                              __      _           __
"                       ____  / /_    (_)__  _____/ /_
"                      / __ \/ __ \  / / _ \/ ___/ __/
"                     / /_/ / /_/ / / /  __/ /__/ /_
"                     \____/_.___/_/ /\___/\___/\__/
"                               /___/
"
" <
"
" @subsection quick-start
" object.vim is an object-oriented framework for plugin writers of Vim.
" It aims to augment and enrich the existing techniques for OOP in Vim.
" That means instead of doing this:
" >
"   let s:MyAwesomeClass = {}
" <
" you can do this:
" >
"   let s:MyAwesomeClass = object#class('MyAwesomeClass')
" <
" And yes, you type the class name twice, but here is the prizes:
" >
"   echo object#repr(s:MyAwesomeClass)
"   <type 'MyAwesomeClass'>
"
"   let awesome = object#new(s:MyAwesomeClass)
"   echo object#repr(awesome)
"   <'MyAwesomeClass' object>
" <
"
" What you get is a type that works out of the box instead of a plain |Dict|.
" There is a lot more you can do with object.vim, such as multiple
" inheritance. Although people nearly always frown on madly complicated class
" hierarchy, object.vim make it possible for you to make people mad :).
" Powered by C3-linearization, you get exactly the same MRO as examplified
" by |https://rhettinger.wordpress.com/2011/05/26/super-considered-super/|:
" >
"   let s:LoggingDict = object#class('LoggingDict', somedict)
"   let s:LoggingOD = object#class('LoggingOD', [s:LoggingDict, s:OrderedDict)
"
"   echo object#repr(s:LoggingOD.__mro__)
"   [<type 'LoggingOD'>,
"    <type 'LoggingDict'>,
"    <type 'OrderedDict'>,
"    <type, 'somedict'>,
"    <type, 'object'>]
" <
"
" And yes, you can use `super()` with a little more verbosity:
" >
"   let s:Shape = object#class('Shape')
"   function! s:Shape.__init__(shapename, ...)
"     let self.shapename = a:shapename
"     call call(object#super(s:Shape, self, '__init__'), a:000)
"   endfunction
"
"   let s:ColoredShape = object#class('ColoredShape', s:Shape)
"   function! s:ColoredShape.__init__(color, ...)
"     let self.color = a:color
"     call call(object#super(s:ColoredShape, self, '__init__'), a:000)
"   endfunction
" <
" Note that to avoid differing signature problems in the chained calls
" of `super()`, the above cooperative methods take arbitrary number of
" arguments, which produces the `call call(...)` verbosity, which may be
" addressed by using a |Dict| as argument:
" >
"   let s:Shape = object#class('Shape')
"   function! s:Shape.__init__(kwdict)
"     let self.shapename = get(a:kwdict, 'shapename')
"     call object#super(s:Shape, self, '__init__')(a:kwdict)
"   endfunction
"
"   let s:ColoredShape = object#class('ColoredShape', s:Shape)
"   function! s:ColoredShape.__init__(kwdict)
"     let self.color = get(a:kwdict, 'color')
"     call object#super(s:ColoredShape, self, '__init__')(a:kwdict)
"   endfunction
" <
"
" What surprises you is that the `super()` of object.vim does not return
" a proxy object but just a plain |Funcref|, which deviates the spirit of
" "everything is an object" and make signature strange. Well for now, what I can
" say is only "this is a trade-off of convenience and efficiency". For those
" unpleasant about this decision, please look at the
" |Why super() is like this| for more details.
"
"
" @subsection motivation
" object.vim is based on the semantics of Python2.7 but it is _not_ an effort
" to port a complete Python2.7 to Vim. Nor is it a Python implementation in
" Vim that sounds like Jython or IronPython. In fact, what it tries to do is
" borrow the benefits from Python and get the best of Vim.
" aims to be an augmentation to the built-in function as well as existing
" coding convensions, rather than correction or reinvention. To achieve this,
" it strives for the following:
"   * Always enhance and be compatible with built-in functions.
"   * Always works with built-in types.
"   * Minimal principle: only core functions are provided.
"
" Keeping this in mind, object.vim tries to built an object-oriented framework
" as well as a bunch of useful modules built on top of that. With object.vim
" you can create and loop over iterators, read and write files with objects,
" create lambda functions with intuitive syntax and hash arbitrary objects.
" Most fundamentally, you can define full-fledged classes that seamlessly
" integrate with all these protocols.
"
" object.vim also hides some of the dark sides of Vim so a robust and
" consistent interface is possible. For the ease of use and code modularity,
" object.vim put evarything available to the users in the `object#` namespace and
" implements them in the sub-namespace such as `object#file#`. The benefit
" is that user can use any functionality of object.vim without the need to
" remember its sub-namespace. This also implies that anything in the sub-namespace
" is implementation details, upon which users should not rely.
"
" In terms of implementation reference, object.vim is loosely based on
" Python2.7. But
"
" May the object be with you!
"

""
" This file serves as a shallow namespace for all the object
" facilities. object.vim aims to be a bunch of convenient functions
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

function! object#class(...) abort
  return call('object#class#class', a:000)
endfunction

function! object#type(...) abort
  return call('object#class#type', a:000)
endfunction

function! object#super(...) abort
  return call('object#class#super', a:000)
endfunction

function! object#new_(...) abort
  return call('object#class#new_', a:000)
endfunction

function! object#new(...) abort
  return call('object#class#new', a:000)
endfunction

function! object#isinstance(...) abort
  return call('object#class#isinstance', a:000)
endfunction

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
"   repr()
"   len()

function! object#dir(...) abort
  return call('object#protocols#dir', a:000)
endfunction

function! object#getattr(...) abort
  return call('object#protocols#getattr', a:000)
endfunction

function! object#setattr(...) abort
  return call('object#protocols#setattr', a:000)
endfunction

function! object#hasattr(...) abort
  return call('object#protocols#hasattr', a:000)
endfunction

function! object#repr(...) abort
  return call('object#protocols#repr', a:000)
endfunction

function! object#len(...) abort
  return call('object#protocols#len', a:000)
endfunction

""
" From object#mapping
" hash()
" getitem()
" setitem()

function! object#hash(...) abort
  return call('object#mapping#hash', a:000)
endfunction

function! object#getitem(...) abort
  return call('object#mapping#getitem', a:000)
endfunction

function! object#setitem(...) abort
  return call('object#mapping#setitem', a:000)
endfunction

""
" From object#except
"   BaseException
"   Exception
"   ValueError
"   TypeError
"   AttributeError
"   StopIteration
"   IOError
"   IndexError
"   KeyError

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

function! object#StopIteration(...) abort
  return call('object#except#StopIteration', a:000)
endfunction

function! object#AttributeError(...) abort
  return call('object#except#AttributeError', a:000)
endfunction

function! object#IOError(...) abort
  return call('object#except#IOError', a:000)
endfunction

function! object#IndexError(...) abort
  return call('object#except#IndexError', a:000)
endfunction

function! object#KeyError(...) abort
  return call('object#except#KeyError', a:000)
endfunction

""
" From object#types
" Built in types
"   object()
"   object_()
"   type_()
"   NoneType()
"   None()
"   bool()
"   list()
"   dict()

function! object#NoneType(...) abort
  return call('object#types#NoneType', a:000)
endfunction

function! object#object(...) abort
  return call('object#types#object', a:000)
endfunction

function! object#object_(...) abort
  return call('object#types#object_', a:000)
endfunction

function! object#type_(...) abort
  return call('object#types#type_', a:000)
endfunction

function! object#None(...) abort
  return call('object#types#None', a:000)
endfunction

function! object#bool(...) abort
  return call('object#types#bool', a:000)
endfunction

function! object#list(...) abort
  return call('object#types#list', a:000)
endfunction

function! object#dict(...) abort
  return call('object#types#dict', a:000)
endfunction

""
" From object#iter
"   iter()
"   next()
"   all()
"   any()
"   map()
"   filter()
"   sum()
"   enumerate()
"   zip()

function! object#iter(...) abort
  return call('object#iter#iter', a:000)
endfunction

function! object#next(...) abort
  return call('object#iter#next', a:000)
endfunction

function! object#all(...) abort
  return call('object#iter#all', a:000)
endfunction

function! object#any(...) abort
  return call('object#iter#any', a:000)
endfunction

function! object#enumerate(...) abort
  return call('object#iter#enumerate', a:000)
endfunction

function! object#zip(...) abort
  return call('object#iter#zip', a:000)
endfunction

function! object#sum(...) abort
  return call('object#iter#sum', a:000)
endfunction

function! object#map(...) abort
  return call('object#iter#map', a:000)
endfunction

function! object#filter(...) abort
  return call('object#iter#filter', a:000)
endfunction

"
" object#file
"   open()
"   file_()

function! object#open(...) abort
  return call('object#file#open', a:000)
endfunction

function! object#file_(...) abort
  return call('object#file#file_', a:000)
endfunction

"
" object#lambda
"   lambda()
"   for()
"

function! object#lambda(...) abort
  return call('object#lambda#lambda', a:000)
endfunction

function! object#lambda_(...) abort
  return call('object#lambda#lambda_', a:000)
endfunction

function! object#for(...) abort
  return call('object#lambda#for', a:000)
endfunction
