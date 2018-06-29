function! object#builtin#FuncName(funcref) "{{{1

endfunction

function! object#Lib#func#CallClassMethod(obj, name, ...) abort "{{{1
  " When `obj` is a type and we want to invoke its classmethod, such that
  " `repr(A)`, where `A` is a type.
  " This is different than when `a` is not a type but we want to invoke
  " classmethod of its type `A`.
  " In the former case, the method of metaclass comes into play.
  let classmethod = obj.__class__[a:name]
  if !object#Lib#value#IsFuncref(a:classmethod)
    call object#TypeError("'%s' object is not callable",
          \ object#Lib#value#TypeName(a:classmethod))
  endif
  return object#Lib#func#CallWithDict(classmethod, a:000, a:obj)
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
  return object#Lib#func#CallWithDict(a:X, a:args, 0)
endfunction

function! object#Lib#func#CallWithDict(X, args, dict) "{{{1
  try
    let Val = a:dict is 0 ? call(a:X, a:args) : call(a:X, a:args, a:dict)
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
