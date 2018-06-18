" TODO: Currently the load time of this script is very slow: 0.1s.
" Speed it up. Use a specific class() that checks less and handles
" single inheritance only?

" Class: Standard Exceptions Hierarchy {{{1
let s:BaseException = object#class('BaseException')

function! s:BaseException.__init__(...)
  let self.args = a:000
endfunction

function! s:BaseException.__repr__()
  return object#repr(self.args)
endfunction

function! s:BaseException.__str__()
  return object#str(self.args)
endfunction

"" Class: Derived from BaseException {{{2
call object#class('KeyboardInterrupt', s:BaseException, s:)
call object#class('SystemExit', s:BaseException, s:)
call object#class('GeneratorExit', s:BaseException, s:)
call object#class('Exception', s:BaseException, s:)

"" Class: Derived from Exception {{{3
call object#class('StopIteration', s:Exception, s:)
call object#class('StopAsyncIteration', s:Exception, s:)
call object#class('ArithmeticError', s:Exception, s:)

" Class: Derived from ArithmeticError {{{4
call object#class('FloatingPointError', s:ArithmeticError, s:)
call object#class('OverflowError', s:ArithmeticError, s:)
call object#class('ZeroDivisionError', s:ArithmeticError, s:)
" }}}

call object#class('AssertionError', s:Exception, s:)
call object#class('AttributeError', s:Exception, s:)
call object#class('BufferError', s:Exception, s:)
call object#class('EOFError', s:Exception, s:)

" Class: Derived from ImportError {{{4
call object#class('ImportError', s:Exception, s:)
call object#class('ModuleNotFoundError', s:ImportError, s:)
" }}}

" Class: Derived from LookupError {{{4
call object#class('LookupError', s:Exception, s:)
call object#class('IndexError', s:LookupError, s:)
call object#class('KeyError', s:LookupError, s:)
" }}}

call object#class('MemoryError', s:Exception, s:)

" Class: Derived from NameError {{{4
call object#class('NameError', s:Exception, s:)
call object#class('UnboundLocalError', s:NameError, s:)
" }}}

" Class: Derived from OSError {{{4
call object#class('OSError', s:Exception, s:)
call object#class('BlockingIOError', s:OSError, s:)
call object#class('ChildProcessError', s:OSError, s:)

" Class: Derived from ConnectionError {{{5
call object#class('ConnectionError', s:OSError, s:)
call object#class('BrokenPipeError', s:ConnectionError, s:)
call object#class('ConnectionAbortedError', s:ConnectionError, s:)
call object#class('ConnectionRefusedError', s:ConnectionError, s:)
call object#class('ConnectionResetError', s:ConnectionError, s:)
" }}}5

" Class: Other subclasses of OSError
call object#class('FileExistsError', s:OSError, s:)
call object#class('FileNotFoundError', s:OSError, s:)
call object#class('InterruptedError', s:OSError, s:)
call object#class('IsADirectoryError', s:OSError, s:)
call object#class('NotADirectoryError', s:OSError, s:)
call object#class('PermissionError', s:OSError, s:)
call object#class('ProcessLookupError', s:OSError, s:)
call object#class('TimeoutError', s:OSError, s:)
" }}}4

" Class: Derived from RuntimeError {{{4
call object#class('RuntimeError', s:Exception, s:)
call object#class('NotImplementedError', s:RuntimeError, s:)
call object#class('RecursionError', s:RuntimeError, s:)
" }}}4

call object#class('SyntaxError', s:Exception, s:)
call object#class('SystemError', s:Exception, s:)
call object#class('TypeError', s:Exception, s:)

"" Class: Derived from ValueError {{{4
call object#class('ValueError', s:Exception, s:)
call object#class('UnicodeError', s:ValueError, s:)
call object#class('UnicodeEncodeError', s:UnicodeError, s:)
call object#class('UnicodeDecodeError', s:UnicodeError, s:)
call object#class('UnicodeTranslateError', s:UnicodeError, s:)
" }}}4
" There is no Warning now :)
"}}}1

""
" @function raise(...)
" Raise an exception.
" >
"   raise() -> Re-throw v:exception.
"   raise(type, ...) -> throw type(...).
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
  call object#except#throw_(s:StopIteration)
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
" @function IOError(...)
" File not writable or readable. Operation on a closed file. Thrown by
" file objects usually.
function! object#except#IOError(...)
  call object#except#throw_(s:IOError, a:000)
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
