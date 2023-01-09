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

let s:identifier = '\v\C^[a-zA-Z_][a-zA-Z0-9_]*$'

function! object#util#ensure_argc(atmost, x)
  if a:x <= a:atmost
    return a:x
  endif
  throw object#TypeError('takes at most %d optional arguments (%d given)', a:atmost, a:x)
endfunction

function! object#util#ensure_identifier(x)
  let x = maktaba#ensure#IsString(a:x)
  if x =~# s:identifier
    return x
  endif
  throw object#ValueError('%s is not an identifier', string(x))
endfunction

function! object#util#has_special_variables()
  return exists('v:none') && exists('v:false') &&
        \ exists('v:true') && exists('v:null')
endfunction

function! object#util#has_bin_specifier()
  return has('patch-7.4.2221')
endfunction

function object#util#identity(X)
  return a:X
endfunction
