let s:BaseException = object#except#builtin#BaseException()

" FUNCTION: raise() {{{1
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
    call object#RuntimeError('No active exception to reraise')
  endif
  if object#issubclass(a:1, s:BaseException)
    call call('object#except#throw', a:000)
  else
    call object#TypeError('exceptions must derive from BaseException')
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

" vim: set sw=2 sts=2 et fdm=marker:
