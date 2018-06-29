" TODO: some type has customized __init__().
" see Objects/exceptiions.c
let builtins = object#Lib#builtin#GetModuleDict()

" CLASS: BaseException {{{1
call object#Lib#builtin#Type_New('BaseException')

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
  return object#Lib#func#Call_('printf', self.args)
endfunction

" Class: Standard Exceptions Hierarchy {{{1
call object#Lib#builtin#Type_New('Exception', s:builtins.BaseException)
call object#Lib#builtin#Type_New('StopIteration', s:builtins.Exception)
call object#Lib#builtin#Type_New('OSError', s:builtins.Exception)
call object#Lib#builtin#Type_New('TypeError', s:builtins.Exception)
call object#Lib#builtin#Type_New('ValueError', s:builtins.Exception)
call object#Lib#builtin#Type_New('AttributeError', s:builtins.Exception)
call object#Lib#builtin#Type_New('LookupError', s:builtins.Exception)
call object#Lib#builtin#Type_New('IndexError', s:builtins.LookupError)
call object#Lib#builtin#Type_New('KeyError', s:builtins.LookupError)
call object#Lib#builtin#Type_New('NameError', s:builtins.Exception)
call object#Lib#builtin#Type_New('SyntaxError', s:builtins.Exception)
call object#Lib#builtin#Type_New('VimError', s:builtins.Exception)
call object#Lib#builtin#Type_New('RuntimeError', s:builtins.Exception)

" Class: Derived from BaseException {{{2
call object#Lib#builtin#Type_New('KeyboardInterrupt', s:builtins.BaseException)
call object#Lib#builtin#Type_New('SystemExit', s:builtins.BaseException)
call object#Lib#builtin#Type_New('GeneratorExit', s:builtins.BaseException)

" Class: Derived from Exception {{{3
call object#Lib#builtin#Type_New('StopAsyncIteration', s:builtins.Exception)
call object#Lib#builtin#Type_New('ArithmeticError', s:builtins.Exception)

" Class: Derived from ArithmeticError {{{4
call object#Lib#builtin#Type_New('FloatingPointError', s:builtins.ArithmeticError)
call object#Lib#builtin#Type_New('OverflowError', s:builtins.ArithmeticError)
call object#Lib#builtin#Type_New('ZeroDivisionError', s:builtins.ArithmeticError)
" }}}

call object#Lib#builtin#Type_New('AssertionError', s:builtins.Exception)
call object#Lib#builtin#Type_New('BufferError', s:builtins.Exception)
call object#Lib#builtin#Type_New('EOFError', s:builtins.Exception)

" Class: Derived from ImportError {{{4
call object#Lib#builtin#Type_New('ImportError', s:builtins.Exception)
call object#Lib#builtin#Type_New('ModuleNotFoundError', s:builtins.ImportError)
" }}}

" Class: Derived from LookupError {{{4
" }}}

call object#Lib#builtin#Type_New('MemoryError', s:builtins.Exception)

" Class: Derived from NameError {{{4
call object#Lib#builtin#Type_New('UnboundLocalError', s:builtins.NameError)
" }}}

" Class: Derived from OSError {{{4
call object#Lib#builtin#Type_New('BlockingIOError', s:builtins.OSError)
call object#Lib#builtin#Type_New('ChildProcessError', s:builtins.OSError)
" Alias of OSError
let s:IOError = s:OSError
let s:EnvironmentError = s:OSError

" Class: Derived from ConnectionError {{{5
call object#Lib#builtin#Type_New('ConnectionError', s:builtins.OSError)
call object#Lib#builtin#Type_New('BrokenPipeError', s:builtins.ConnectionError)
call object#Lib#builtin#Type_New('ConnectionAbortedError', s:builtins.ConnectionError)
call object#Lib#builtin#Type_New('ConnectionRefusedError', s:builtins.ConnectionError)
call object#Lib#builtin#Type_New('ConnectionResetError', s:builtins.ConnectionError)
" }}}5

" Class: Other subLib#builtin#Type_Newes of OSError
call object#Lib#builtin#Type_New('FileExistsError', s:builtins.OSError)
call object#Lib#builtin#Type_New('FileNotFoundError', s:builtins.OSError)
call object#Lib#builtin#Type_New('InterruptedError', s:builtins.OSError)
call object#Lib#builtin#Type_New('IsADirectoryError', s:builtins.OSError)
call object#Lib#builtin#Type_New('NotADirectoryError', s:builtins.OSError)
call object#Lib#builtin#Type_New('PermissionError', s:builtins.OSError)
call object#Lib#builtin#Type_New('ProcessLookupError', s:builtins.OSError)
call object#Lib#builtin#Type_New('TimeoutError', s:builtins.OSError)
" }}}4

" Class: Derived from RuntimeError {{{4
call object#Lib#builtin#Type_New('NotImplementedError', s:builtins.RuntimeError)
call object#Lib#builtin#Type_New('RecursionError', s:builtins.RuntimeError)
" }}}4

call object#Lib#builtin#Type_New('SystemError', s:builtins.Exception)

" Class: Derived from ValueError {{{4
call object#Lib#builtin#Type_New('UnicodeError', s:builtins.ValueError)
call object#Lib#builtin#Type_New('UnicodeEncodeError', s:builtins.UnicodeError)
call object#Lib#builtin#Type_New('UnicodeDecodeError', s:builtins.UnicodeError)
call object#Lib#builtin#Type_New('UnicodeTranslateError', s:builtins.UnicodeError)
" }}}4

" Class: Derived from Warning {{{4
call object#Lib#builtin#Type_New('Warning', s:builtins.Exception)
call object#Lib#builtin#Type_New('DeprecationWarning', s:builtins.Warning)
call object#Lib#builtin#Type_New('PendingDeprecationWarning', s:builtins.Warning)
call object#Lib#builtin#Type_New('RuntimeWarning', s:builtins.Warning)
call object#Lib#builtin#Type_New('SyntaxWarning', s:builtins.Warning)
call object#Lib#builtin#Type_New('UserWarning', s:builtins.Warning)
call object#Lib#builtin#Type_New('FutureWarning', s:builtins.Warning)
call object#Lib#builtin#Type_New('ImportWarning', s:builtins.Warning)
call object#Lib#builtin#Type_New('UnicodeWarning', s:builtins.Warning)
call object#Lib#builtin#Type_New('ResourceWarning', s:builtins.Warning)
" }}}4

"}}}1

" vim: set sw=2 sts=2 et fdm=marker:
