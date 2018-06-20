" DOCUMENT: {{{1
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

" }}}1
" TODO: add range()
" CLASS: enumerate {{{1
let s:enumerate = object#class('enumerate')

function! s:enumerate.__init__(iter, start)
  let self.iter = a:iter
  let self.idx = a:start
endfunction

function! s:enumerate.__next__()
  let next = [self.idx, object#next(self.iter)]
  let self.idx += 1
  return next
endfunction
" }}}1

" CLASS: zip {{{1
let s:zip = object#class('zip')
function! s:zip.__init__(seqs)
  let self.seqs = a:seqs
endfunction

function! s:zip.__iter__()
  return self
endfunction

function! s:zip.__next__()
  if empty(self.seqs)
    call object#StopIteration()
  endif
  return map(copy(self.seqs), 'object#next(v:val)')
endfunction

" }}}1

" FUNCTION: iter(), next() contains() {{{1
""
" @function iter(...)
" Return an iterator from {obj}.
" >
"   iter(List) -> list_iterator
"   iter(String) -> str_iterator
"   iter(iterator) -> returned as it
"   iter(obj) -> obj.__iter__()
" <
function! object#iter#iter(obj)
  if object#builtin#IsList(a:obj)
    return object#list#iter(a:obj)
  endif

  if object#builtin#IsString(a:obj)
    return object#str#iter(a:obj)
  endif

  if object#iter#IsIterable(a:obj)
    let iter = object#builtin#Call(a:obj.__iter__)
    if object#iter#IsIterator(iter)
      return iter
    endif
    call object#TypeError("iter() returned non-iterator of type '%s'",
          \ object#builtin#TypeName(a:obj))
  endif
  call object#iter#ThrowNotIterable(a:obj)
endfunction

" TODO: generalize to detect X has a specific protocol
function! object#iter#IsIterable(X)
  return object#builtin#IsObj(a:X) && has_key(a:X, '__iter__')
        \ && object#builtin#IsFuncref(a:X.__iter__)
endfunction

function! object#iter#IsIterator(X)
  return object#builtin#IsObj(a:X) && has_key(a:X, '__next__')
        \ && object#builtin#IsFuncref(a:X.__next__)
endfunction

function! object#iter#ThrowNotIterable(obj)
  call object#TypeError("'%s' object is not iterable",
        \ object#builtin#TypeName(a:obj))
endfunction

""
" @function next(...)
" Retrieve the next item from an iterator.
" >
"   next(iter) -> next item from iter
" <
function! object#iter#next(obj, ...)
  call object#builtin#TakeAtMostOptional('next', 1, a:0)
  if !object#iter#IsIterator(a:obj)
    call object#TypeError("'%s' object is not an iterator",
        \ object#builtin#TypeName(a:obj))
  endif
  try
    let Val = object#builtin#Call(a:obj.__next__)
  catch 'StopIteration'
    if a:0 == 1
      return a:1
    endif
    throw v:exception
  endtry
  return Val
endfunction

function! object#iter#contains(haystack, needle)
  let iter = object#iter(a:haystack)
  try
    while 1
      " TODO: use object#eq()
      if maktaba#value#IsEqual(a:needle, object#next(iter))
        return 1
      endif
    endwhile
  catch 'StopIteration'
    return 0
  endtry
endfunction
" }}}1

" FUNCTION: any(), all(), sum() {{{1
" TODO: bool()!
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
" @function sum(...)
" Return the sum of items from {iter} plus [start], which defaults to 0.
" >
"   sum(iter, start=0) -> start + the sum of items.
" <
" Items must be numeric.
function! object#iter#sum(iter, ...)
  call object#builtin#TakeAtMostOptional('sum', 1, a:0)
  let iter = object#iter(a:iter)
  let start = a:0 ? object#builtin#CheckNumeric(a:1) : 0
  try
    while 1
      let start += object#builtin#CheckNumeric(object#next(iter))
    endwhile
  catch /StopIteration/
    return start
  endtry
endfunction
" }}}1

" FUNCTION: zip(), enumerate() {{{1
""
" @function zip(...)
" Return an iterator that zips a list of sequences.
" >
"   zip(iter[,*iters]) -> [seq1[0], seq2[0], ...], ...
" <
" The iterator stops at the shortest sequence.
function! object#iter#zip(...)
  let seqs = map(copy(a:000), 'object#iter(v:val)')
  return object#new(s:zip, seqs)
endfunction

""
" @function enumerate(...)
" Return an iterator for index, value of {iter}.
" >
"   enumerate(iterable, start=0) -> [start, item_0], ..., [N, item_N]
" <
function! object#iter#enumerate(iter, ...)
  call object#builtin#TakeAtMostOptional('enumerate', 1, a:0)
  let iter = object#iter(a:iter)
  let start =  a:0 ? object#builtin#CheckNumber(a:1) : 0
  return object#new(s:enumerate, iter, start)
endfunction
" }}}1

" FUNCTION: map(), filter() {{{1
" TODO: allow Funcref here (callable module).
""
" @function map(...)
" Tranform the iterable with lambda (String).
" >
"   map(iter, lambda) -> a new list mapped from iter
" <
function! object#iter#map(iter, lambda)
  return map(object#list(a:iter), object#builtin#CheckString(a:lambda))
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
  call object#builtin#TakeAtMostOptional('filter', 1, a:0)
  let core = a:0 ? printf('%s(v:val)', object#builtin#CheckString(a:1)):
        \ 'v:val'
  return filter(object#list(a:iter), 'object#bool('.core.')')
endfunction

" }}}1

" vim: set sw=2 sts=2 et fdm=marker:
