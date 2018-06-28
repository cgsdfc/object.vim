" FUNCTION: getitem() {{{1
function! object#str#getitem(str, index)
  if !object#builtin#IsNumber(a:index)
    call object#TypeError("string indices must be integers")
  endif
  " When index out of range, Vim returns an empty string.
  " That's why we have to figure it out here.
  let index = a:index
  if index < 0
    let index += strchars(a:str)
  endif
  if index < 0 || index >= strchars(a:str)
    " Note: use the original index.
    call object#IndexError("string index out of range: %d", a:index)
  endif
  " Make up for unicode.
  let index = index * 3
  return a:str[index: index+2]
endfunction

function! object#str#len(X)
  return strchars(a:X)
endfunction

function! object#str#contains(haystack, needle)
  if object#builtin#IsString(a:needle)
    return stridx(a:haystack, a:needle) >= 0
  endif
  call object#TypeError(
        \ "'in <string>' requires string as left operand, not %s",
        \ object#builtin#TypeName(a:needle))
endfunction

function! object#str#str(...)
  call object#builtin#TakeAtMostOptional('str', 1, a:0)
  if !a:0
    return ''
  endif
  if object#builtin#IsString(a:1)
    return a:1
  endif
  if object#builtin#IsList(a:1)
    return object#list#repr(a:1)
  endif
  if object#hasattr(a:1, '__str__')
    return object#builtin#CheckString(
          \ object#builtin#Call(a:1.__str__))
  endif
  if object#builtin#IsDict(a:1)
    return object#dict#repr(a:1)
  endif
  return string(a:1)
endfunction
" }}}1

" FUNCTION: ord(), chr() {{{1
function! object#str#ord_args(nargs, args)
  if a:nargs == 0
    call object#TypeError('ord() takes at least 1 argument (0 given)')
  endif
  call object#builtin#CheckString(a:args[1])
  if a:nargs == 2
    call object#builtin#CheckBool(a:args[2])
  endif
  return a:args
endfunction

function! object#str#chr_args(nargs, args)
  if a:nargs == 0
    call object#TypeError('chr() takes at least 1 argument (0 given)')
  endif
  call object#builtin#CheckNumber(a:args[1])
  if a:nargs == 2
    call object#builtin#CheckBool(a:args[2])
  endif
  return a:args
endfunction

function! object#str#chr(...)
  return call('nr2char', object#str#chr_args(a:0, a:000))
endfunction

function! object#str#ord(...)
  return call('char2nr', object#str#ord_args(a:0, a:000))
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
