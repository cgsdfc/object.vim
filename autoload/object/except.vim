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


" Class: Standard Exceptions Hierarchy {{{1
call object#class#builtin_class('BaseException', object#object_(), s:)

function! s:BaseException.__init__(...)
  " Note: a:000 cannot be modified so it is effectively a tuple.
  " args is supposed to be RO so no copy() here.
  let self.args = a:000
endfunction

function! s:BaseException.__repr__()
  return printf('%s(%s)', self.__class__.__name__, object#repr(self.args))
endfunction

function! s:BaseException.__str__()
  let N = len(self.args)
  if !N
    return ''
  endif
  call maktaba#ensure#IsString(self.args[0])
  if N == 1
    return self.args[0]
  endif
  return call('printf', self.args)
endfunction

" Eagerly Bootstrap
call object#class#builtin_class('Exception', s:BaseException, s:)
call object#class#builtin_class('StopIteration', s:Exception, s:)
call object#class#builtin_class('OSError', s:Exception, s:)
call object#class#builtin_class('TypeError', s:Exception, s:)
call object#class#builtin_class('ValueError', s:Exception, s:)
call object#class#builtin_class('AttributeError', s:Exception, s:)
call object#class#builtin_class('LookupError', s:Exception, s:)
call object#class#builtin_class('IndexError', s:LookupError, s:)
call object#class#builtin_class('KeyError', s:LookupError, s:)

" On-demand Bootstrap
function! object#except#lazy_bootstrap()
  " Class: Derived from BaseException {{{2
  call object#class#builtin_class('KeyboardInterrupt', s:BaseException, s:)
  call object#class#builtin_class('SystemExit', s:BaseException, s:)
  call object#class#builtin_class('GeneratorExit', s:BaseException, s:)

  " Class: Derived from Exception {{{3
  call object#class#builtin_class('StopAsyncIteration', s:Exception, s:)
  call object#class#builtin_class('ArithmeticError', s:Exception, s:)

  " Class: Derived from ArithmeticError {{{4
  call object#class#builtin_class('FloatingPointError', s:ArithmeticError, s:)
  call object#class#builtin_class('OverflowError', s:ArithmeticError, s:)
  call object#class#builtin_class('ZeroDivisionError', s:ArithmeticError, s:)
  " }}}

  call object#class#builtin_class('AssertionError', s:Exception, s:)
  call object#class#builtin_class('BufferError', s:Exception, s:)
  call object#class#builtin_class('EOFError', s:Exception, s:)

  " Class: Derived from ImportError {{{4
  call object#class#builtin_class('ImportError', s:Exception, s:)
  call object#class#builtin_class('ModuleNotFoundError', s:ImportError, s:)
  " }}}

  " Class: Derived from LookupError {{{4
  " }}}

  call object#class#builtin_class('MemoryError', s:Exception, s:)

  " Class: Derived from NameError {{{4
  call object#class#builtin_class('NameError', s:Exception, s:)
  call object#class#builtin_class('UnboundLocalError', s:NameError, s:)
  " }}}

  " Class: Derived from OSError {{{4
  call object#class#builtin_class('BlockingIOError', s:OSError, s:)
  call object#class#builtin_class('ChildProcessError', s:OSError, s:)
  " Alias of OSError
  let s:IOError = s:OSError
  let s:EnvironmentError = s:OSError

  " Class: Derived from ConnectionError {{{5
  call object#class#builtin_class('ConnectionError', s:OSError, s:)
  call object#class#builtin_class('BrokenPipeError', s:ConnectionError, s:)
  call object#class#builtin_class('ConnectionAbortedError', s:ConnectionError, s:)
  call object#class#builtin_class('ConnectionRefusedError', s:ConnectionError, s:)
  call object#class#builtin_class('ConnectionResetError', s:ConnectionError, s:)
  " }}}5

  " Class: Other subclass#builtin_classes of OSError
  call object#class#builtin_class('FileExistsError', s:OSError, s:)
  call object#class#builtin_class('FileNotFoundError', s:OSError, s:)
  call object#class#builtin_class('InterruptedError', s:OSError, s:)
  call object#class#builtin_class('IsADirectoryError', s:OSError, s:)
  call object#class#builtin_class('NotADirectoryError', s:OSError, s:)
  call object#class#builtin_class('PermissionError', s:OSError, s:)
  call object#class#builtin_class('ProcessLookupError', s:OSError, s:)
  call object#class#builtin_class('TimeoutError', s:OSError, s:)
  " }}}4

  " Class: Derived from RuntimeError {{{4
  call object#class#builtin_class('RuntimeError', s:Exception, s:)
  call object#class#builtin_class('NotImplementedError', s:RuntimeError, s:)
  call object#class#builtin_class('RecursionError', s:RuntimeError, s:)
  " }}}4

  call object#class#builtin_class('SyntaxError', s:Exception, s:)
  call object#class#builtin_class('SystemError', s:Exception, s:)

  " Class: Derived from ValueError {{{4
  call object#class#builtin_class('UnicodeError', s:ValueError, s:)
  call object#class#builtin_class('UnicodeEncodeError', s:UnicodeError, s:)
  call object#class#builtin_class('UnicodeDecodeError', s:UnicodeError, s:)
  call object#class#builtin_class('UnicodeTranslateError', s:UnicodeError, s:)
  " }}}4

  " Class: Derived from Warning {{{4
  call object#class#builtin_class('Warning', s:Exception, s:)
  call object#class#builtin_class('DeprecationWarning', s:Warning, s:)
  call object#class#builtin_class('PendingDeprecationWarning', s:Warning, s:)
  call object#class#builtin_class('RuntimeWarning', s:Warning, s:)
  call object#class#builtin_class('SyntaxWarning', s:Warning, s:)
  call object#class#builtin_class('UserWarning', s:Warning, s:)
  call object#class#builtin_class('FutureWarning', s:Warning, s:)
  call object#class#builtin_class('ImportWarning', s:Warning, s:)
  call object#class#builtin_class('UnicodeWarning', s:Warning, s:)
  call object#class#builtin_class('ResourceWarning', s:Warning, s:)
  " }}}4

  "}}}1
endfunction

function! object#except#builtins()
  if !exists('s:KeyboardInterrupt')
    call object#except#lazy_bootstrap()
  endif
  return s:
endfunction

""
" @function raise(...)
" Raise an exception.
" >
"   raise() -> Re-throw v:exception.
"   raise(type, ...) -> throw str(type(...)).
" <
function! object#except#raise(...)
  if !a:0
    if v:exception isnot ''
      throw v:exception
    endif
    call object#except#throw(s:RuntimeError, 'No active exception to reraise')
  endif
  if object#issubclass(a:1, s:BaseException)
    call call('object#except#throw', a:000)
  else
    call object#except#throw(s:TypeError, 'exceptions must derive from BaseException')
  endif
endfunction

" Instantiate except with argument and throw the str of it.
" Without validate except.
function! object#except#throw_(except, args)
  let e = object#new_(a:except, a:args)
  throw printf('%s: %s', a:except.__name__, e.__str__())
endfunction

function! object#except#throw(except, ...)
  return object#except#throw_(a:except, a:000)
endfunction

function! object#except#BaseException_()
  return s:BaseException
endfunction

function! object#except#Exception_()
  return s:Exception
endfunction

""
" @function Exception(...)
" Generic exception.
function! object#except#Exception(...)
  call object#except#throw_(s:Exception, a:000)
endfunction

""
" @function ValueError(...)
" The value of function arguments went wrong.
function! object#except#ValueError(...)
  call object#except#throw_(s:ValueError, a:000)
endfunction

""
" @function TypeError(...)
" Unsupported operation for a type or wrong number of arguments passed
" to a function.
function! object#except#TypeError(...)
  call object#except#throw_(s:TypeError, a:000)
endfunction

""
" @function AttributeError(...)
" The object has no such attribute or the attribute is readonly.
function! object#except#AttributeError(...)
  call object#except#throw_(s:AttributeError, a:000)
endfunction

""
" @function StopIteration(...)
" Iteration stops.
function! object#except#StopIteration()
  call object#except#throw(s:StopIteration)
endfunction

""
" @function IndexError(...)
" Index out of range for sequences.
function! object#except#IndexError(...)
  call object#except#throw_(s:IndexError, a:000)
endfunction

""
" @function KeyError(...)
" Key out of range for sequences.
function! object#except#KeyError(...)
  call object#except#throw_(s:KeyError, a:000)
endfunction

""
" @function OSError(...)
function! object#except#OSError(...)
  call object#except#throw_(s:OSError, a:000)
endfunction

" Helper to throw 'no such attribute'
"
function! object#except#throw_noattr(obj, name)
  call object#AttributeError('%s object has no attribute %s',
        \ object#types#name(a:obj), string(a:name))
endfunction

"
" Indicate the the {func} is not available for {obj} because of
" lack of hooks or invcompatible type. {func} is the name of the
" function without parentheses.
"
function! object#except#not_avail(func, obj)
  call object#TypeError('%s() not available for %s object',
        \  a:func, object#types#name(a:obj))
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
