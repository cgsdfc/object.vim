""
" @section Protocol, protocol
" A set of basic hookable functions that inspect and operate on different
" properties of an object. A protocol in this context means an global function
" that has well defined behaviours for built-in types and can be overriden by
" the corresponding methods with double underscores names.

" FUNCTION: repr() {{{1
""
" @function repr(...)
" Generate string representation for {obj}. Fail back on |string()|.
" >
"   repr(obj) -> String
" <
function! object#protocol#repr(obj)
  if object#builtin#IsList(a:obj)
    return object#list#repr(a:obj)
  endif

  if object#builtin#IsFuncref(a:obj)
    return object#callable#repr(a:obj)
  endif

  if object#builtin#IsDict(a:obj)
    if has_key(a:obj, '__mro__')
      " TODO: In terms of metaclass, we should use:
      " obj.__class__.__repr__
      return printf("<class '%s'>", a:obj.__name__)
    endif

    if has_key(a:obj, '__repr__')
      let string = object#builtin#Call(a:obj.__repr__)
      if object#builtin#IsString(string)
        return string
      endif
      call object#TypeError('__repr__ returned non-string (type %s)',
            \ object#builtin#TypeName(string))
    else
      return object#dict#repr(a:obj)
    endif
  endif
  " Number, Float, String, Job and Channel, and Special.
  return string(a:obj)
endfunction
" }}}1

" Deprecated
" Call a __protocol__ function {X} (ensure {X} is a Funcref)
function! object#protocol#call(X, ...)
  return call(maktaba#ensure#IsFuncref(a:X), a:000)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
