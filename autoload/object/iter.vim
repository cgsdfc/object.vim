""
" @section Iterator, iter
" Iterator protocol.
" Provide functions that produce and manipulate iterators and iterators for
" built-in types like |List| and |String|.
"
" Features:

let s:list_iter = object#class('list_iter')
let s:str_iter = object#class('str_iter')
let s:enum_iter = object#class('enumerate')
let s:zip_iter = object#class('zip_iter')

function! s:list_iter.__init__(list)
  let self.idx = 0
  let self.list = a:list
endfunction

" When the list index goes out of range, Vim throws E684.
function! s:list_iter.__next__()
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
function! s:str_iter.__next__()
  let Item = self.str[self.idx]
  if Item isnot# ''
    let self.idx += 1
    return Item
  endif
  throw object#StopIteration()
endfunction

function! s:enum_iter.__init__(iter, start)
  let self.iter = a:iter
  let self.idx = a:start
endfunction

function! s:enum_iter.__next__()
  let Item = [self.idx, object#next(self.iter)]
  let self.idx += 1
  return Item
endfunction

function! s:zip_iter.__init__(iters)
  let self.iters = a:iters
endfunction

function! s:zip_iter.__next__()
  return map(copy(self.iters), 'object#next(v:val)')
endfunction

function! s:ensure_iter(x)
  if object#hasattr(a:x, '__iter__') && maktaba#value#IsFuncref(a:x.__iter__)
    return a:x
  endif
  throw object#TypeError('object is not an iterator')
endfunction

""
" Return an iterator from {obj}. If {obj} is already an iterator, it is
" returned as it. Built-in |List| and |String| have iterators. An __iter__
" method of {obj} that returns an iterator will be used if possible.
"
" @throws WrongType if {obj} has an unusable __next__.
" @throws TypeError if the __iter__ of {obj} does not return an iterator.
function! object#iter#iter(obj)
  if object#hasattr(a:obj, '__next__')
    call maktaba#ensure#IsFuncref(a:obj.__next__)
    return a:obj
  endif
  if maktaba#value#IsList(a:obj)
    return object#new(s:list_iter, a:obj)
  endif
  if maktaba#value#IsString(a:obj)
    return object#new(s:str_iter, a:obj)
  endif
  if object#hasattr(a:obj, '__iter__')
    return s:ensure_iter(object#protocols#call(a:obj.__iter__))
  endif
  call object#except#not_avail('iter', a:obj)
endfunction

""
" Retrieve the next item from the iterator {obj}.
function! object#iter#next(obj)
  if object#hasattr(a:obj, '__next__')
    return object#protocols#call(a:obj.__next__)
  endif
  call object#except#not_avail('next', a:obj)
endfunction

""
" Return true iff any item from {iter} is true. Truthness is evaluated using
" object#bool(). {iter} can be anything iterable.
function! object#iter#any(iter)
  let iter = object#iter#iter(a:iter)
  try
    while 1
      let Item = object#iter#next(iter)
      if object#bool(Item) | return 1 | endif
    endwhile
  catch /StopIteration/
    return 0
  endtry
endfunction

""
" Return true iff all item from {iter} is true. Truthness is evaluated using
" object#bool(). {iter} can be anything iterable.
function! object#iter#all(iter)
  let iter = object#iter#iter(a:iter)
  try
    while 1
      let Item = object#iter#next(iter)
      if !object#bool(Item) | return 0 | endif
    endwhile
  catch /StopIteration/
    return 1
  endtry
endfunction

""
" Turn an iterator that returns 2-list into a |Dict|.
" If no [iter] is given, an empty |Dict| is returned.
" If a |Dict| is given, it is effectively |copy()|'ed.
function! object#iter#dict(...)
  let argc = object#util#ensure_argc(1, a:0)
  if !argc | return {} | endif
  if maktaba#value#IsDict(a:1)
    return copy(a:1)
  endif
  let iter = object#iter(a:1)
  let dict = {}
  try
    while 1
      let Item = object#next(iter)
      let key = object#getitem(Item, 0)
      let val = object#getitem(Item, 1)
      let dict[key] = val
    endwhile
  catch /StopIteration/
    return dict
  endtry
endfunction

""
" Turn an iterator into a |List|.
" If no [iter] is given, an empty |List| is returned.
" If a |List| is given, it is effectively |copy()|'ed.
function! object#iter#list(...)
  let argc = object#util#ensure_argc(1, a:0)
  if !argc | return [] | endif
  if maktaba#value#IsList(a:1)
    return copy(a:1)
  endif
  let iter = object#iter(a:1)
  let list = []
  try
    while 1
      call add(list, object#next(iter))
    endwhile
  catch /StopIteration/
    return list
  endtry
endfunction

""
" Return an iterator for index, value of {iter}
" Take an optional [start].
function! object#iter#enumerate(iter, ...)
  let argc = object#util#ensure_argc(1, a:0)
  let iter = object#iter(a:iter)
  let start =  argc ? maktaba#ensure#IsNumber(a:1) : 0
  return object#new(s:enum_iter, iter, start)
endfunction

""
" Return an iterator that returns [seq1[i], seq[i], ...]
" for the ith call of object#next(). The iterator stops when
" the first StopIteration is raised by one of the [iters].
function! object#iter#zip(iter, ...)
  let iter = object#iter(a:iter)
  if !a:0 | return iter | endif
  let iters = insert(map(copy(a:000), 'object#iter(v:val)'), iter)
  return object#new(s:zip_iter, iters)
endfunction

""
" Create a new list by applying {lambda} to each item of an {iter}.
" {lambda} should be a |String| that is acceptable by built-in |map()|.
function! object#iter#map(iter, lambda)
  let iter = object#iter(a:iter)
  let lambda = maktaba#ensure#IsString(a:lambda)
  return map(object#list(iter), lambda)
endfunction

""
" Create a new list by removing the item from {iter} when {lambda}
" return false. Truthness is evaluated by object#bool().
" {lambda} should be a |String| that is acceptable by built-in |filter()|.
function! object#iter#filter(iter, lambda)
  let iter = object#iter(a:iter)
  let lambda = maktaba#ensure#IsString(a:lambda)
  return filter(object#list(iter), 'object#bool('.lambda.')')
endfunction

""
" Return the sum of items from {iter}. The item must supports built-in |+=|.
" If {iter} is empty, |Number| 0 is returned.
function! object#iter#sum(iter)
  let iter = object#iter(a:iter)
  let x = 0
  try
    while 1
      let x += maktaba#ensure#IsNumeric(object#next(iter))
    endwhile
  catch /StopIteration/
    return x
  endtry
endfunction
