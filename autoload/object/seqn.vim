" FUNCTION: Sequence protocols: len(), in() {{{1
" FUNCTION: len() {{{1
""
" @function len(...)
" Return the length of {obj}.
" >
"   len(String, List or Dict) -> len(obj)
"   len(obj) -> obj.__len__()
" <
function! object#seqn#len(obj)
  if object#builtin#IsSequence(a:obj)
    return object#str#len(a:obj)
  endif

  if object#builtin#IsDict(a:obj)
    if !has_key(a:obj, '__class__')
      " Plain dict
      return len(a:obj)
    endif
    if has_key(a:obj, '__len__')
      return object#seqn#CheckedCallLen(a:obj)
    endif
  endif
  call object#TypeError("object of type '%s' has no len()",
        \ object#builtin#TypeName(a:obj))
endfunction

" FUNCTION: CheckedCallLen() {{{1
" Call __len__() and check that it return >= 0 integer.
function! object#seqn#CheckedCallLen(obj)
  let number = object#builtin#CheckNumber2(object#builtin#Call(a:obj.__len__))
  if number >= 0
    return number
  endif
    call object#ValueError("__len__() should return >= 0")
endfunction

" FUNCTION: in() {{{2
""
" @function in(...)
" Test whether {needle} is in {haystack}.
" >
"   in(key, dict) -> has_key(dict, key).
"   in(sub, string) -> sub in string.
"   in(needle, iterable) -> needle in list(iterable).
"   in(needle, obj) -> bool(obj.__contains__(needle)).
" <
function! object#seqn#in(needle, haystack)
  if object#builtin#IsList(a:haystack)
    return object#list#contains(a:haystack, a:needle)
  endif

  if object#builtin#IsString(a:haystack)
    return object#str#contains(a:haystack, a:needle)
  endif

  if object#builtin#IsDict(a:haystack)
    if !has_key(a:haystack, '__class__')
      " NOTE: We don't ensure a:needle is a String.
      " Just let automatic conversion happen.
      return has_key(a:haystack, a:needle)
    endif
    if has_key(a:haystack, '__contains__')
      " NOTE: return value of __contains__() is a bool context.
      return object#bool(
            \ object#builtin#Call(a:haystack.__contains__, a:needle))
    endif
    if has_key(a:haystack, '__iter__')
      return object#iter#contains(a:haystack, a:needle)
    endif
  endif

  call object#TypeError("argument of type '%s' is not iterable",
        \ object#builtin#TypeName(a:haystack))
endfunction
" }}}2

function! object#seqn#sorted(iterable, ...)

endfunction
" }}}1

" vim: set sw=2 sts=2 et fdm=marker:
