""
" @section Introduction, intro
" @stylized object
" @library
" @order intro protocols class mapping iter file types lambda dicts functions exceptions
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
" arguments, which produces the `call call(...)` verbosity. It can be
" made brief by using a |Dict| as argument:
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
" "everything is an object" and make the signature strange. Well for now, what I can
" say is only "this is a trade-off of convenience and efficiency". For those
" unpleasant about this decision, please look at the
" |Why-super()-is-like-this| for more details.
"
" Dear readers, there is a lot more interesting stuffs to explore about
" object.vim, such as lambda and iterator so please read on.
"
"
" @subsection motivation
" Well the first question that I asked myself at the beginning of this project
" is: What? you want to create a DSL in Vim that looks like Python and you
" expect those who use pure Python or pure Vimscript for their plugins to like
" your hybridization that sounds like Vimthon?
"
" Well first of all, I don't expect people to like my plugin and I just
" find it fun to write an OOP framework for Vim. That's my motivation.
"
" Second, I personally don't
" think it is a DSL because it is just a bunch of functions that work
" together. There is no new syntax to learn (which means extra rules to
" obey).
" You just pick up a piece of tool you want to use and it (should) works out of the
" box.
"
" Third, I am not doing hybridization like Emacs in Vim or vice versa, which
" explains why we have such a limited number of functions compared with the
" versatile libraries of Python. Those who expect a complete Python layer
" over Vimscript will be disappointed by the fact that not even the standard library `sys`
" is found. What's more, some counterparts of Python have different signatures
" or even different behaviors, which will be explained in details. Most of
" the time, we strive for Python compatibility since that won't surprise people
" gravely.
"
" In short, what we provide is an OOP framework that feels familiar to Python
" and hopefully, useful for Vim plugin writers.
"
"
" @subsection features
" object.vim provides several handy modules:
"   * class module: inheritance and instantiation.
"   * iter module: iterator for |List| and |String| and helper functions.
"   * file module: plain old file object for line-oriented I/O.
"   * lambda module: create one-liner easily and `for` loop construct.
"   * mapping module: hash arbitrary object and generic `getitem()`,
"   `setitem()`.
"   * types module: top level class like `object`, `type` and conversion
"   protocols like `bool()`.
"
" Note that although these features are implemented in separate files, they
" are kind-of imported into a shallow namespace for the ease of use so please
" use `object#class()` instead of `object#class#class()`. Please consider
" everything in namespaces deeper than `object` as implementation details and
" avoid using them as much as you can. However, each individual function is still
" documented with its full name, as found in @section(functions).
"
" @subsection testing
" I use `vader.vim` (|https://github.com/junegunn/vader.vim|) for unit tests. A comprehensive test suite for each module
" is found at `object.vim/test`. To run all the test, use:
" >
"   object.vim/test/run-tests.sh
" <
"
" @subsection dependency
" The only dependency is `vim-maktaba` (|https://github.com/google/vim-maktaba|).
" I use it to deal the built-in types of Vimscript.
" You need a Vim with version >= 7.4 to work.
"
" @subsection author
"   * author: cgsdfc
"   * email: cgsdfc@126.com or 2far2long@gmail.com
"   (Use the first one as long as you can since I only periodically check the second one)
"
"
" That's it, folks. May the object be with you!
"

"
" class.vim
"

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

"
" protocols.vim
"

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

"
" mapping.vim
"

function! object#hash(...) abort
  return call('object#mapping#hash', a:000)
endfunction

function! object#getitem(...) abort
  return call('object#mapping#getitem', a:000)
endfunction

function! object#setitem(...) abort
  return call('object#mapping#setitem', a:000)
endfunction

"
" except.vim
"

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

"
" types.vim
"

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

"
" iter.vim
"

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
" file.vim
"

function! object#open(...) abort
  return call('object#file#open', a:000)
endfunction

function! object#file_(...) abort
  return call('object#file#file_', a:000)
endfunction

"
" lambda.vim
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
