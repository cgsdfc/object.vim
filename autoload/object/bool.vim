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

let s:bool = object#class('bool', object#int_())

function! s:bool.__new__(cls, ...)
  let val = call('object#bool', a:000)
  if !exists('s:True')
    let s:True = object#super(s:bool, a:cls).__new__(val) 
    let s:False = object#super(s:bool, a:cls).__new__(!val) 
  endif
  return val? s:True : s:False
endfunction

function! object#bool#_bool(...)
  return object#new_(s:bool, a:000)
endfunction

""
" @function bool(...)
" Convert [args] to a Bool, i.e., 0 or 1.
" >
"   bool() -> False
"   bool(Funcref) -> True
"   bool(List, String or plain Dict) -> not empty
"   bool(Number) -> non-zero
"   bool(Float) -> non-zero
"   bool(v:false, v:null, v:none) -> False
"   bool(v:true) -> True
"   bool(obj) -> obj.__bool__()
" <
function! object#bool#bool(...)
  call object#util#ensure_argc(1, a:0)
  if !a:0
    " bool() <==> false
    return 0
  endif
  let Obj = a:1
  if has('float') && maktaba#value#IsFloat(Obj)
    return Obj !=# 0.0
  endif
  if maktaba#value#IsFuncref(Obj)
    return 1
  endif
  if maktaba#value#IsString(Obj) || maktaba#value#IsList(Obj)
    return !empty(Obj)
  endif
  try
    " If we directly return !!Obj, the exception cannot
    " be caught.
    let x = !!Obj
    return x
  catch/E728/ " Using a Dictionary as a Number
    if object#hasattr(Obj, '__bool__')
      " Thing returned from bool() should be canonical, so as __bool__.
      " Prevent user from mistakenly return something like 1.0
      return maktaba#ensure#IsBool(object#protocols#call(Obj.__bool__))
    endif
    return !empty(Obj)
  catch
    call object#except#not_avail('bool', Obj)
  endtry
endfunction

