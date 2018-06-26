let s:builtin = object#except#builtin#import()

""
" @function Exception(...)
" Generic exception.
function! object#except#throw#Exception(...)
  call object#except#throw_(s:builtin.Exception, a:000)
endfunction

""
" @function SyntaxError(...)
" The value of function arguments went wrong.
function! object#except#throw#SyntaxError(...)
  call object#except#throw_(s:builtin.SyntaxError, a:000)
endfunction

""
" @function ValueError(...)
" The value of function arguments went wrong.
function! object#except#throw#ValueError(...)
  call object#except#throw_(s:builtin.ValueError, a:000)
endfunction

""
" @function TypeError(...)
" Unsupported operation for a type or wrong number of arguments passed
" to a function.
function! object#except#throw#TypeError(...)
  call object#except#throw_(s:builtin.TypeError, a:000)
endfunction

""
" @function AttributeError(...)
" The object has no such attribute or the attribute is readonly.
function! object#except#throw#AttributeError(...)
  call object#except#throw_(s:builtin.AttributeError, a:000)
endfunction

""
" @function StopIteration(...)
" Iteration stops.
function! object#except#throw#StopIteration()
  call object#except#throw(s:builtin.StopIteration)
endfunction

""
" @function IndexError(...)
" Index out of range for sequences.
function! object#except#throw#IndexError(...)
  call object#except#throw_(s:builtin.IndexError, a:000)
endfunction

""
" @function KeyError(...)
" Key out of range for sequences.
function! object#except#throw#KeyError(...)
  call object#except#throw_(s:builtin.KeyError, a:000)
endfunction

""
" @function OSError(...)
function! object#except#throw#OSError(...)
  call object#except#throw_(s:builtin.OSError, a:000)
endfunction

""
" @function NameError(...)
function! object#except#throw#NameError(...)
  call object#except#throw_(s:builtin.NameError, a:000)
endfunction

""
" @function VimError(...)
function! object#except#throw#VimError(...)
  call object#except#throw_(s:builtin.VimError, a:000)
endfunction

""
" @function RuntimeError(...)
function! object#except#throw#RuntimeError(...)
  call object#except#throw_(s:builtin.RuntimeError, a:000)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
