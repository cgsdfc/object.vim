" CLASS: BaseException {{{1
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
  if !object#builtin#IsString(self.args[0])
    call object#TypeError("args[0] must be string")
  endif
  if N == 1
    return self.args[0]
  endif
  return object#builtin#Call_('printf', self.args)
endfunction

" Class: Standard Exceptions Hierarchy {{{1
call object#class#builtin_class('Exception', s:BaseException, s:)
call object#class#builtin_class('StopIteration', s:Exception, s:)
call object#class#builtin_class('OSError', s:Exception, s:)
call object#class#builtin_class('TypeError', s:Exception, s:)
call object#class#builtin_class('ValueError', s:Exception, s:)
call object#class#builtin_class('AttributeError', s:Exception, s:)
call object#class#builtin_class('LookupError', s:Exception, s:)
call object#class#builtin_class('IndexError', s:LookupError, s:)
call object#class#builtin_class('KeyError', s:LookupError, s:)
call object#class#builtin_class('NameError', s:Exception, s:)
call object#class#builtin_class('SyntaxError', s:Exception, s:)
call object#class#builtin_class('VimError', s:Exception, s:)
call object#class#builtin_class('RuntimeError', s:Exception, s:)

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
call object#class#builtin_class('NotImplementedError', s:RuntimeError, s:)
call object#class#builtin_class('RecursionError', s:RuntimeError, s:)
" }}}4

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

" FUNCTION: Exception() {{{1
function! object#except#builtin#Exception()
  return s:Exception
endfunction

" FUNCTION: BaseException() {{{1
function! object#except#builtin#BaseException()
  return s:BaseException
endfunction

" FUNCTION: import() {{{1
" Return the dict that holds all the standard exception types.
function! object#except#builtin#import()
  return s:
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
