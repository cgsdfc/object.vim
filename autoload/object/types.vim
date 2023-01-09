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

""
" @section Types, types
" Define a minimal set of fundamental types as the basic of the type
" hierarchy.
" They are:
"   * object(None): The base class of all the rest of classes. The base class of it is
"     None, the only instance of the NoneType.
"
"   * type(object): The class of all the types for both built-in and user
"     definded ones. In other words, every class is an instance of type.
"
"   * NoneType(type): The class of the None object, the place holder for
"   absence of sensible values, such as the base class of object.

" Note: We cannot use in global scope any of the functions from class.vim.

" 
" Get the typename of {obj}. If {obj} is a type,
" 'type' will be returned always.
function! object#types#name(obj)
  if object#hasattr(a:obj, '__class__')
    return string(a:obj.__class__.__name__)
  endif
  return string(maktaba#value#TypeName(a:obj))
endfunction

" Install special attrs.
function! object#types#install(obj, name, class, base, mro)
  let a:obj.__name__ = a:name
  let a:obj.__base__ = a:base
  let a:obj.__bases__ = [a:base]
  let a:obj.__class__ = a:class
  let a:obj.__mro__ = a:mro
endfunction

let s:object = {}
let s:type = {}
let s:NoneType = {}
let s:None = { '__class__' : s:NoneType }

call object#types#install(s:object, 'object', s:type, s:None, [s:object])
call object#types#install(s:type, 'type', s:type, s:object, [s:type, s:object])
call object#types#install(s:NoneType, 'NoneType', s:type, s:object, [s:NoneType, s:type, s:object])

"
" object and type
"
for s:obj in [s:object, s:type]
  function! s:obj.__repr__()
    return printf('<%s object>', self.__class__.__name__)
  endfunction
  function! s:obj.__str__()
    return printf('<%s object>', self.__class__.__name__)
  endfunction
  function! s:obj.__bool__()
    return 1
  endfunction
endfor

"
" NoneType
"
for s:obj in [s:NoneType, s:None]
  function! s:obj.__init__()
    "  Python3 never throws about this.
    throw object#TypeError('cannot create NoneType instance')
  endfunction
  function! s:obj.__repr__()
    return 'None'
  endfunction
  function! s:obj.__bool__()
    return 0
  endfunction
  function! s:obj.__str__()
    return 'None'
  endfunction
endfor

" Actually an NOP.
function! s:object.__init__()
endfunction

"
" type() creates new class when called with 3 arguments.
function! s:type.__init__(name, bases, dict)
  call object#class#type_init(self, a:name, a:bases, a:dict)
endfunction

""
" @function object()
" Create a plain object.
function! object#types#object()
  return object#new(s:object)
endfunction

""
" @function object_()
" Return the object class
function! object#types#object_()
  return s:object
endfunction

""
" @function type_()
" Return the type class
function! object#types#type_()
  return s:type
endfunction

""
" @function None()
" Return the None object
function! object#types#None()
  return s:None
endfunction
