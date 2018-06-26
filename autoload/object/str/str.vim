" VARIABLE: patterns used in str.isalnum() e.g. {{{1
let s:isalnum = '\v\C^\w+$'
let s:isalpha = '\v\C^\a+$'
let s:isdigit = '\v\C^\d+$'
let s:islower = '\v\C^\l+$'
let s:isspace = '\v\C^\s+$'
let s:isupper = '\v\C^\u+$'
" }}}1

function! object#str#_str(...)
  return object#new_(s:str, a:000)
endfunction

function! object#str#str_()
  return s:str
endfunction

let s:object = object#object_()

" CLASS: str {{{1
call object#class#builtin_class('str', s:object, s:)

" PROTOCOL: {{{2
function! s:str.__init__(...)
  let self._str = call('object#str', a:000)
endfunction

function! s:str.__len__()
  return object#len(self._str)
endfunction

function! s:str.__contains__(substr)
  return object#str#contains(self._str, a:substr)
endfunction

function! s:str.__iter__()
  return object#iter(self._str)
endfunction

function! s:str.__hash__()
  return object#hash(self._str)
endfunction

function! s:str.__str__()
  return object#str(self._str)
endfunction

function! s:str.__repr__()
  return object#repr(self._str)
endfunction

function! s:str.__getitem__(Index)
  return object#getitem(a:Index)
endfunction
" }}}2

" METHOD: {{{2
function! s:str.upper()
  return toupper(self._str)
endfunction

function! s:str.lower()
  return tolower(self._str)
endfunction

function! s:str.split(...)
  call object#builtin#TakeAtMostOptional('split', 2, a:0)
  if a:0 == 1
    call object#builtin#CheckString(a:1)
  endif
  if a:0 == 2
    call object#builtin#CheckBool(a:2)
  endif
  return call('split', [self._str] + a:000)
endfunction

function! s:str.join(iterable)
  return join(object#list(a:iterable), self._str)
endfunction

function! s:str.strip(...)
  call object#builtin#TakeAtMostOptional('strip', 1, a:0)
  return call('maktaba#string#Strip', [self._str] + a:000)
endfunction

function! s:str.lstrip(...)
  call object#builtin#TakeAtMostOptional('lstrip', 1, a:0)
  return call('maktaba#string#StripLeading', [self._str] + a:000)
endfunction

function! s:str.rstrip(...)
  call object#builtin#TakeAtMostOptional('rstrip', 1, a:0)
  return call('maktaba#string#StripTrailing', [self._str] + a:000)
endfunction

function! s:str.startswith(prefix)
  return maktaba#string#StartsWith(self._str, a:prefix)
endfunction

function! s:str.endswith(suffix)
  return maktaba#string#EndsWith(self._str, a:suffix)
endfunction

function! s:str.find(sub, ...)
  call object#builtin#TakeAtMostOptional('find', 2, a:0)
  let start = a:0 ? object#builtin#CheckNumber(a:1):0
  let end = a:0 > 1 ? object#builtin#CheckNumber(a:2):
        \ object#len(self)-1
  return stridx(self._str[start:end], object#builtin#CheckString(a:sub))
endfunction

function! s:str.isalnum()
  return self._str =~# s:isalnum
endfunction

function! s:str.isalpha()
  return self._str =~# s:isalpha
endfunction

function! s:str.isdigit()
  return self._str =~# s:isdigit
endfunction

function! s:str.islower()
  return self._str =~# s:islower
endfunction

function! s:str.isupper()
  return self._str =~# s:isupper
endfunction

function! object#str#justify(str, fill, left, right)
  return printf('%s%s%s', repeat(a:fill, a:left), a:str, repeat(a:fill, a:right))
endfunction

function! object#str#just_args(func, nargs, args)
  if a:nargs == 0
    call object#TypeError('%s() takes at least 1 argument', a:func)
  endif
  let width = object#builtin#CheckNumber(a:args[0])
  return [width, a:nargs == 2 ? object#builtin#CheckString(a:args[1]) : ' ']
endfunction

function! s:str.ljust(...)
  let [width, fill] = object#str#just_args('ljust', a:0, a:000)
  return object#str#justify(self._str, fill, 0, width - object#len(self))
endfunction

function! s:str.rjust(...)
  let [width, fill] = object#str#just_args('rjust', a:0, a:000)
  return object#str#justify(self._str, fill, width - object#len(self), 0)
endfunction

function! s:str.center(...)
  let [width, fill] = object#str#just_args('center', a:0, a:000)
  let padwidth = (width - object#len(self))
  let half = padwidth / 2
  return object#str#justify(self._str, fill, half,  and(padwidth, 1) ? half + 1 : half)
endfunction

function! s:str.capitalize()
  return substitute(self._str, '\C\v^(.*)(\w)(.*)$', '\1\U\2\3', '')
  " let [i, len] = [0, object#len(self)]
  " while i < len
  "   if self._str[i] =~# s:isalnum
  "     return printf('%s%s%s', self._str[0:i-1],
  "           \  toupper(self._str[i]), self._str[i+1, len-1])
  "   endif
  "   let i += 1
  " endwhile
  " return self._str
endfunction

function! s:str.count(sub)
  let sub = object#builtin#CheckString(a:sub)
  let [total, i] = [0, 0]
  let [len, slen] = [object#len(self), len(sub)]
  while i + slen < len
    if self._str[i:i + slen - 1] ==# sub
      let total += 1
      let i += slen
    else
      let i += 1
    endif
  endwhile
  return total
endfunction

function! s:str.index(...)
  let idx = call(self.find, a:000)
  if idx >= 0
    return idx
  endif
  call object#ValueError('substring not found')
endfunction
" }}}2

