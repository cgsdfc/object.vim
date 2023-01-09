" MIT License
" 
" Copyright (c) 2018 cgsdfc
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.

let s:str = object#class('str')

let s:isalnum = '\v\C^\w+$'
let s:isalpha = '\v\C^\a+$'
let s:isdigit = '\v\C^\d+$'
let s:islower = '\v\C^\l+$'
let s:isspace = '\v\C^\s+$'
let s:isupper = '\v\C^\u+$'

function! object#str#str(...)
  call object#util#ensure_argc(1, a:0)
  if !a:0
    return ''
  endif
  if maktaba#value#IsString(a:1)
    return a:1
  endif
  if maktaba#value#IsList(a:1)
    return object#list#repr(a:1)
  endif
  if object#hasattr(a:1, '__str__')
    return maktaba#ensure#IsString(
          \ object#protocols#call(a:1.__str__))
  endif
  if maktaba#value#IsDict(a:1)
    return object#dict#repr(a:1)
  endif
  return string(a:1)
endfunction

function! object#str#ord_args(nargs, args)
  if a:nargs == 0
    throw object#TypeError('ord() takes at least 1 argument (0 given)')
  endif
  call maktaba#ensure#IsString(a:args[1])
  if a:nargs == 2
    call maktaba#ensure#IsBool(a:args[2])
  endif
  return a:args
endfunction

function! object#str#chr_args(nargs, args)
  if a:nargs == 0
    throw object#TypeError('chr() takes at least 1 argument (0 given)')
  endif
  call maktaba#ensure#IsNumber(a:args[1])
  if a:nargs == 2
    call maktaba#ensure#IsBool(a:args[2])
  endif
  return a:args
endfunction

function! object#str#chr(...)
  return call('nr2char', object#str#chr_args(a:0, a:000))
endfunction

function! object#str#ord(...)
  return call('char2nr', object#str#ord_args(a:0, a:000))
endfunction

function! object#str#_str(...)
  return object#new_(s:str, a:000)
endfunction

function! object#str#str_()
  return s:str
endfunction

function! s:str.__init__(...)
  let self._str = call('object#str', a:000)
endfunction

function! s:str.__len__()
  return object#len(self._str)
endfunction

function! s:str.__contains__(S)
  return object#contains(a:S, self._str)
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

function! s:str.upper()
  return toupper(self._str)
endfunction

function! s:str.lower()
  return tolower(self._str)
endfunction

function! s:str.split(...)
  call object#util#ensure_argc(2, a:0)
  if a:0 == 1
    call maktaba#ensure#IsString(a:1)
  endif
  if a:0 == 2
    call maktaba#ensure#IsBool(a:2)
  endif
  return call('split', [self._str] + a:000)
endfunction

function! s:str.join(iterable)
  return join(object#list(a:iterable), self._str)
endfunction

function! s:str.strip(...)
  call object#util#ensure_argc(1, a:0)
  return call('maktaba#string#Strip', [self._str] + a:000)
endfunction

function! s:str.lstrip(...)
  call object#util#ensure_argc(1, a:0)
  return call('maktaba#string#StripLeading', [self._str] + a:000)
endfunction

function! s:str.rstrip(...)
  call object#util#ensure_argc(1, a:0)
  return call('maktaba#string#StripTrailing', [self._str] + a:000)
endfunction

function! s:str.startswith(prefix)
  return maktaba#string#StartsWith(self._str, a:prefix)
endfunction

function! s:str.endswith(suffix)
  return maktaba#string#EndsWith(self._str, a:suffix)
endfunction

function! s:str.find(sub, ...)
  call object#util#ensure_argc(2, a:0)
  let start = a:0 ? maktaba#ensure#IsNumber(a:1):0
  let end = a:0 > 1 ? maktaba#ensure#IsNumber(a:2):
        \ object#len(self)-1
  return stridx(self._str[start:end], maktaba#ensure#IsString(a:sub))
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
    throw object#TypeError('%s() takes at least 1 argument', a:func)
  endif
  let width = maktaba#ensure#IsNumber(a:args[0])
  return [width, a:nargs == 2 ? maktaba#ensure#IsString(a:args[1]) : ' ']
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
  let sub = maktaba#ensure#IsString(a:sub)
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
  throw object#ValueError('substring not found')
endfunction
