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
" @section Iterator, iter
" Iterator protocol.
"
" Features:
"   * Vim-compatible map() and filter() that works with iterators.
"   * filter() evaluates lambda using |object#types#bool()|.
"   * Provide iterators for |String| and |List| that works transparently.
"   * Helpers like sum(), all(), any(), zip() and enumerate() all work as expected.
"
" Examples:
" >
"   :echo object#all(range(10))
"   0
"
"   :echo object#list(object#enumerate('abc'))
"   [[0, 'a'], [1, 'b'], [2,'c']]
"
"   :echo object#dict(object#zip('abc', range(3)))
"   {'a': 0, 'b': 1, 'c': 2}
"
"   :echo object#sum(range(1, 100))
"   5050
"
"   :echo object#filter(['1', '2', ''])
"   ['1', '2']
"
"   :echo object#list('abc')
"   ['a', 'b', 'c']
" <
"
" Limitations:
"   * No generator and yield() supported.

let s:list_iter = object#class('list_iter')
let s:str_iter = object#class('str_iter')
let s:enumerate = object#class('enumerate')
let s:zip = object#class('zip')

function! s:list_iter.__init__(list)
  let self.idx = 0
  let self.list = a:list
endfunction

" When the list index goes out of range, Vim throws E684.
function! s:list_iter.next()
  try
    let Item = self.list[self.idx]
  catch /E684/
    throw object#StopIteration()
  endtry
  let self.idx += 1
  return Item
endfunction

function! s:str_iter.__init__(str)
  let self.idx = 0
  let self.str = a:str
endfunction

" When the index to a string goes out of range, Vim
" returns an empty string, which is an indicator of StopIteration.
function! s:str_iter.next()
  let Item = self.str[self.idx]
  if Item isnot# ''
    let self.idx += 1
    return Item
  endif
  throw object#StopIteration()
endfunction

function! s:enumerate.__init__(iter, start)
  let self.iter = a:iter
  let self.idx = a:start
endfunction

function! s:enumerate.next()
  let Item = [self.idx, object#next(self.iter)]
  let self.idx += 1
  return Item
endfunction

function! s:zip.__init__(iters)
  let self.iters = a:iters
endfunction

function! s:zip.next()
  return map(copy(self.iters), 'object#next(v:val)')
endfunction

""
" @function iter(...)
" Return an iterator from {obj}.
" >
"   iter(List) -> list_iter
"   iter(String) -> str_iter
"   iter(iterator) -> returned as it
"   iter(obj) -> obj.__iter__()
" <
function! object#iter#iter(obj)
  " If obj already an iter.
  if object#hasattr(a:obj, 'next')
    return a:obj
  endif

  " Handle built-in iters.
  if maktaba#value#IsList(a:obj)
    return object#new(s:list_iter, a:obj)
  endif
  if maktaba#value#IsString(a:obj)
    return object#new(s:str_iter, a:obj)
  endif

  if object#hasattr(a:obj, '__iter__')
    return object#iter#extract(a:obj)
  endif

  call object#except#not_avail('iter', a:obj)
endfunction

""
" @function next(...)
" Retrieve the next item from an iterator.
" >
"   next(iter) -> next item from iter
" <
function! object#iter#next(obj)
  " Note: We check **nothing** here. Rationales:
  "   - next() is performance critical.
  "   - next() is usually used in couple with iter(),
  "     which does all necessary checkings already.
  return a:obj.next()
endfunction

""
" @function any(...)
" If any of the items is True.
" >
"   any(iterable) -> if any of the items is True
" <
function! object#iter#any(iter)
  let iter = object#iter(a:iter)
  try
    while 1
      let Item = object#iter#next(iter)
      if object#bool(Item)
        return 1
      endif
    endwhile
  catch /StopIteration/
    return 0
  endtry
endfunction

""
" @function all(...)
" If all of the items is True.
" >
"   all(iterable) -> if all of the items is True
" <
function! object#iter#all(iter)
  let iter = object#iter(a:iter)
  try
    while 1
      let Item = object#iter#next(iter)
      if !object#bool(Item)
        return 0
      endif
    endwhile
  catch /StopIteration/
    return 1
  endtry
endfunction

""
" @function enumerate(...)
" Return an iterator for index, value of {iter}.
" >
"   enumerate(iterable, start=0) -> [start, item_0], ..., [N, item_N]
" <
function! object#iter#enumerate(iter, ...)
  call object#util#ensure_argc(1, a:0)
  let iter = object#iter(a:iter)
  let start =  a:0 ? maktaba#ensure#IsNumber(a:1) : 0
  return object#new(s:enumerate, iter, start)
endfunction

""
" @function zip(...)
" Return an iterator that zips a list of sequences.
" >
"   zip(iter[,*iters]) -> [seq1[0], seq2[0], ...], ...
" <
" The iterator stops at the shortest sequence.
function! object#iter#zip(iter, ...)
  let iter = object#iter(a:iter)
  if !a:0
    return iter
  endif
  let iters = insert(map(copy(a:000), 'object#iter(v:val)'), iter)
  return object#new(s:zip, iters)
endfunction

""
" @function map(...)
" Tranform the iterable with lambda (String).
" >
"   map(iter, lambda) -> a new list mapped from iter
" <
function! object#iter#map(iter, lambda)
  return map(object#list(a:iter), maktaba#ensure#IsString(a:lambda))
endfunction

""
" @function filter(...)
" Create a new list filtering {iter} using a lambda (String).
" >
"   filter(iter) -> a new list without falsy items.
"   filter(iter, lambda) -> a new list filtered from iter.
" <
" Truthness is tested by `bool()`.
function! object#iter#filter(iter, ...)
  call object#util#ensure_argc(1, a:0)
  if !a:0
    return filter(object#list(a:iter), 'object#bool(v:val)')
  endif
  return filter(object#list(a:iter),
        \ printf('object#bool(%s)', maktaba#ensure#IsString(a:1)))
endfunction

""
" @function sum(...)
" Return the sum of items from {iter} plus [start], which defaults to 0.
" >
"   sum(iter, start=0) -> start + the sum of items.
" <
" Items must be numeric.
function! object#iter#sum(iter, ...)
  call object#util#ensure_argc(1, a:0)
  let start = a:0 ? maktaba#ensure#IsNumeric(a:1) : 0
  let iter = object#iter(a:iter)
  try
    while 1
      let start += maktaba#ensure#IsNumeric(object#next(iter))
    endwhile
  catch /StopIteration/
    return start
  endtry
endfunction

" 

" Extract an iterator from {obj} and make sure it is a valid
" iter, i.e., has next() method.
function! object#iter#extract(obj)
  let X = object#protocols#call(a:obj.__iter__)
  if object#hasattr(X, 'next') && maktaba#value#IsFuncref(X.next)
    return X
  endif
  throw object#TypeError('__iter__() returns non-iter')
endfunction
