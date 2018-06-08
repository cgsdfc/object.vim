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
"   :echo object#filter(['1', '2', ''], 'v:val')
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

function! s:enumerate.__init__(iter, start)
  let self.iter = a:iter
  let self.idx = a:start
endfunction

function! s:enumerate.__next__()
  let Item = [self.idx, object#next(self.iter)]
  let self.idx += 1
  return Item
endfunction

function! s:zip.__init__(iters)
  let self.iters = a:iters
endfunction

function! s:zip.__next__()
  return map(copy(self.iters), 'object#next(v:val)')
endfunction

""
" Return an iterator from {obj}. If {obj} is already an iterator, it is
" returned as it. Built-in |List| and |String| have iterators. An __iter__
" method of {obj} that returns an iterator will be used if possible.
"
" @throws WrongType if {obj} has an unusable __next__.
" @throws TypeError if the __iter__ of {obj} does not return an iterator.
function! object#iter#iter(obj)
  " If obj already an iter.
  if object#hasattr(a:obj, '__next__')
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
" Retrieve the next item from the iterator {obj}.
function! object#iter#next(obj)
  " Note: We check **nothing** here. Rationales:
  "   - next() is performance critical.
  "   - next() is usually used in couple with iter(),
  "     which does all necessary checkings already.
  return a:obj.__next__()
endfunction

""
" Return true iff any item from {iter} is true. Truthness is evaluated using
" object#bool(). {iter} can be anything iterable.
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
" Return true iff all item from {iter} is true. Truthness is evaluated using
" object#bool(). {iter} can be anything iterable.
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
" Return an iterator for index, value of {iter}
" Take an optional [start].
function! object#iter#enumerate(iter, ...)
  call object#util#ensure_argc(1, a:0)
  let iter = object#iter(a:iter)
  let start =  a:0 ? maktaba#ensure#IsNumber(a:1) : 0
  return object#new(s:enumerate, iter, start)
endfunction

""
" Return an iterator that returns [seq1[i], seq[i], ...]
" for the ith call of object#next(). The iterator stops when
" the first StopIteration is raised by one of the [iters].
function! object#iter#zip(iter, ...)
  let iter = object#iter(a:iter)
  if !a:0
    return iter
  endif
  let iters = insert(map(copy(a:000), 'object#iter(v:val)'), iter)
  return object#new(s:zip, iters)
endfunction

""
" Create a new list by applying {lambda} to each item of an {iter}.
" {lambda} should be a |String| that is acceptable by built-in |map()|.
function! object#iter#map(iter, lambda)
  return map(object#list(a:iter), maktaba#ensure#IsString(a:lambda))
endfunction

""
" Create a new list by removing the item from {iter} when {lambda}
" return false. Truthness is evaluated by object#bool().
" {lambda} should be a |String| that is acceptable by built-in |filter()|.
function! object#iter#filter(iter, lambda)
  let lambda = maktaba#ensure#IsString(a:lambda)
  return filter(object#list(a:iter), 'object#bool('.lambda.')')
endfunction

""
" Return the sum of items from {iter} plus the value of
" parameter [start], which defaults to 0. Items must be either |Number|s
" or |Float|s, i.e., numeric.
" If {iter} is empty, [start] is returned.
"
" @throws WrongType if any item is not numeric.
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

" Extract an iterator from {obj} and make sure it is a valid
" iter, i.e., has __next__ method.
function! object#iter#extract(obj)
  let X = object#protocols#call(a:obj.__iter__)
  if object#hasattr(X, '__next__') && maktaba#value#IsFuncref(X.__next__)
    return X
  endif
  throw object#TypeError('__iter__ returns non-iter')
endfunction
