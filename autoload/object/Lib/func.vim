function! object#builtin#FuncName(funcref) "{{{1

endfunction

function! object#Lib#func#CallFuncref(X, ...) "{{{1
  return object#Lib#func#CallFuncref_(a:X, a:000)
endfunction

function! object#Lib#func#CallFuncref_(X, args) "{{{1
  if !object#Lib#value#IsFuncref(a:X)
    call object#TypeError("'%s' object is not callable",
          \ object#Lib#value#TypeName(a:X))
  endif
  return object#Lib#func#Call_(a:X, a:args)
endfunction

function! object#Lib#func#Call(X, ...) "{{{1
  return object#Lib#func#Call_(a:X, a:000)
endfunction

function! object#Lib#func#Call_(X, args) "{{{1
  try
    let Val = call(a:X, a:args)
  catch 'E767:\|E766:\|E118:\|E119:'
    " E118: Too many or not enough args.
    " E119: Too many or not enough args.
    " E766: Insufficient args to printf()
    " E767: Too many args to printf()
    call object#TypeError(object#Lib#except#FormatVimError(v:exception))
  catch 'E117:\|E121:'
    " E117: Unknown function.
    " E121: Undefined variables.
    " NOTE: Unknown function can also be caused by
    " using something non-callable, which is actually
    " TypeError.
    " However, the word "Unknown" makes it very like
    " an undefined name.
    call object#NameError(object#Lib#except#FormatVimError(v:exception))
  catch 'E488:'
    " E488: Trailing characters
    call object#SyntaxError(object#Lib#except#FormatVimError(v:exception))
  catch 'E713:\|E716:\|E717'
    " E716: Key not present
    call object#KeyError(object#Lib#except#FormatVimError(v:exception))
  catch 'E684:'
    " index out of range.
    call object#IndexError(object#Lib#except#FormatVimError(v:exception))
  catch 'E741:'
    " lockvar
    call object#RuntimeError(object#Lib#except#FormatVimError(v:exception))
  catch 'E\d\+:'
    call object#VimError(object#Lib#except#FormatVimError(v:exception))
  endtry
  return Val
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
