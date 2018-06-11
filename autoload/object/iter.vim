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
let s:imap = object#class('imap')
let s:ifilter = object#class('ifilter')

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

function! s:imap.__init__(iter, mapper)
  let self.iter = object#iter(a:iter)
  let self.mapper = maktaba#ensure#IsFuncref(a:mapper)
endfunction

function! s:imap.__next__()
  return self.mapper(object#next(self.iter))
endfunction

function! s:ifilter.__init__(iter, filter)
  let self.iter = object#iter(a:iter)
  let self.filter = a:filter
endfunction

function! s:ifilter.__next__()
  while 1
    let Next = object#next(self.iter)
    if object#bool(self.filter(Next))
      return Next
    endif
  endwhile
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
  return a:obj.__next__()
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
"   zip(iter[,*iters]) -> [[seq1[0], seq2[0], ...], ...]
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
" Map a callable to an iterable.
" >
"   map(iter, lambda) -> a new list mapped from iter
" <
" {lambda} can be a String or Funcref.
function! object#iter#map(iter, lambda)
  if maktaba#value#IsString(a:lambda)
    return map(object#list(a:iter), a:lambda)
  endif
  if maktaba#value#IsFuncref(a:lambda)
    return object#list(object#imap(a:iter, a:lambda))
  endif
  throw object#TypeError('invalid type %s for map()', object#types#name(a:lambda))
endfunction

""
" @function imap(...)
" Return an `imap` iterator.
" >
"   imap(iterable, Funcref) -> imap object
" <
function! object#iter#imap(iter, mapper)
  return object#new(s:imap, a:iter, a:mapper)
endfunction

""
" @function ifilter(...)
" Return an `ifilter` iterator.
" >
"   ifilter(iterable, Funcref) -> ifilter object
"   ifilter(iterable) -> as if Funcref is identity
" <
function! object#iter#ifilter(iter, ...)
  call object#util#ensure_argc(1, a:0)
  let filter = a:0 ? maktaba#ensure#IsFuncref(a:1):function('object#util#identity')
  return object#new(s:ifilter, a:iter, filter)
endfunction

""
" @function filter(...)
" Create a new list by removing the item from {iter} when {lambda}
" return false.
" >
"   filter(iter) -> a new list without falsy items.
"   filter(iter, lambda) -> a new list filtered from iter.
" <
" Truthness is tested by `bool()`.
function! object#iter#filter(iter, lambda)
  if maktaba#value#IsString(a:lambda)
    return filter(object#list(a:iter), 'object#bool('.lambda.')')
  endif
  if maktaba#value#IsFuncref(a:lambda)
    return object#list(object#ifilter(a:iter, a:lambda))
  endif
  throw object#TypeError('invalid type %s for filter()', object#types#name(a:lambda))
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

" TODO: add reduce()

" Extract an iterator from {obj} and make sure it is a valid
" iter, i.e., has __next__ method.
function! object#iter#extract(obj)
  let X = object#protocols#call(a:obj.__iter__)
  if object#hasattr(X, '__next__') && maktaba#value#IsFuncref(X.__next__)
    return X
  endif
  throw object#TypeError('__iter__() returns non-iter')
endfunction
