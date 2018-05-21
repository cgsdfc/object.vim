""
" @section Introduction, intro
" @stylized object
" @library
" @order intro version protocols class mapping iter file types dicts functions exceptions
" A vimscript library that provides object protocols for Vim similar to
" Python.
"

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

function! object#class(...) abort
  return call('object#class#class', a:000)
endfunction

function! object#type(...) abort
  return call('object#class#type', a:000)
endfunction

function! object#super(...) abort
  return call('object#class#super', a:000)
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
"   bool()

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

function! object#bool(...) abort
  return call('object#protocols#bool', a:000)
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

""
" From object#types
" Built in types
"   object()
"   object_()
"   type_()
"   NoneType()
"   None()

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

""
" From object#iter
"   iter()
"   next()
"   all()
"   any()
"   map()
"   filter()
"   sum()
"   list()
"   dict()
"   enumerate()

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

function! object#list(...) abort
  return call('object#iter#list', a:000)
endfunction

function! object#dict(...) abort
  return call('object#iter#dict', a:000)
endfunction

function! object#enumerate(...) abort
  return call('object#iter#enumerate', a:000)
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

