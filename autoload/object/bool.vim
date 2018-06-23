" [All about TRUTH]( https://docs.python.org/3/library/stdtypes.html#truth )
" let s:bool = object#class('bool', object#int_())

" function! s:bool.__new__(cls, ...)
"   let val = call('object#bool', a:000)
"   if !exists('s:True')
"     let s:True = object#super(s:bool, a:cls).__new__(val)
"     let s:False = object#super(s:bool, a:cls).__new__(!val)
"   endif
"   return val? s:True : s:False
" endfunction

" function! object#bool#_bool(...)
"   return object#new_(s:bool, a:000)
" endfunction

""
" FUNCTION: bool() {{{1
" Note: Although Python bans 1 or 0 as bool in __bool__, we find it hard
" to do the same in Vim since every builtin boolean function of Vim return
" 1 or 0.
function! object#bool#bool(...)
  if a:0 > 1
    call object#TypeError("bool() takes at most 1 argument (%d given)", a:0)
  endif
  if !a:0
    " bool() <==> false
    return 0
  endif
  if object#builtin#IsContainer(a:1)
    return !empty(a:1)
  endif
  if object#builtin#IsNone(a:1)
    return 0
  endif
  if object#builtin#IsBool(a:1)
    return !!a:1
  endif
  if object#builtin#IsNumeric(a:1)
    return a:1 != 0
  endif
  if object#protocol#HasProtocol(a:1, '__bool__')
    return object#bool#CheckBool(object#builtin#Call(a:1.__bool__))
  endif
  if object#protocol#HasProtocol(a:1, '__len__')
    return !!object#seqn#CheckedCallLen(a:1)
  endif
  return 1
endfunction

function! object#bool#CheckBool(X)
  " TODO: True/False considered.
  if object#builtin#IsBool(a:X)
    return a:X
  endif
  call object#TypeError("__bool__ should return bool, returned %s",
        \ object#builtin#TypeName(a:X))
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
