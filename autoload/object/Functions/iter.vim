" PERF: next() and iter() both do CheckIterator(),
" In all(), the check of next() is rebundant.
" FUNCTION: iter() {{{1
""
" @function iter(...)
" Return an iterator from {obj}.
" >
"   iter(List) -> list_iterator
"   iter(String) -> str_iterator
"   iter(obj) -> obj.__iter__()
"   iter(callable, sentinel) -> callable_iterator
" <
function! object#iter#iter(...)
  if a:0 == 0
    call object#TypeError("iter expected at least 1 arguments, got 0")
  endif
  if a:0 > 2
    call object#TypeError("iter expected at most 2 arguments, got 3")
  endif
  if a:0 == 2
    if !object#builtin#IsFuncref(a:1)
      call object#TypeError("iter(v, w): v must be callable")
    endif
    return object#new_(s:callable_iterator, a:000)
  endif

  let obj = object#iter#CheckIterable(a:1)
  if object#builtin#IsList(obj)
    return object#list#iter#iter(obj)
  endif
  if object#builtin#IsString(obj)
    return object#str#iter#iter(obj)
  endif

  let iter = object#builtin#CallFuncref(obj.__iter__)
  return object#iter#CheckIterator(iter,
        \ printf("iter() returned non-iterator of type '%s'",
        \ object#builtin#TypeName(iter)))
endfunction
" }}}1

" FUNCTION: Helper to test and check Iterable/Iterator {{{1
function! object#iter#CheckIterator(X, msg)
  if object#proto#IsIterator(a:X)
    return a:X
  endif
  call object#TypeError(a:msg)
endfunction

function! object#iter#CheckIterable(X)
  if object#proto#IsIterable(a:X)
    return a:X
  endif
  call object#TypeError("'%s' object is not iterable",
        \ object#builtin#TypeName(a:X))
endfunction

" }}}1

" FUNCTION: next() {{{1
""
" @function next(...)
" Retrieve the next item from an iterator.
" >
"   next(iter) -> next item from iter
" <
function! object#iter#next(obj, ...)
  call object#builtin#TakeAtMostOptional('next', 1, a:0)
  let obj = object#iter#CheckIterator(a:obj,
        \ printf("'%s' object is not an iterator",
        \ object#builtin#TypeName(a:obj)))
  try
    let Val = object#builtin#CallFuncref(obj.__next__)
  catch 'StopIteration'
    if a:0 == 1
      return a:1
    endif
    throw v:exception
  endtry
  return Val
endfunction
" }}}1

" FUNCTION: index() {{{1
" Return the index of the first occurence of value.
" Throw ValueError if not present.
function! object#iter#index(iterable, value)
  let iter = object#iter(a:iterable)
  let index = 0
  try
    while 1
      if maktaba#value#IsEqual(a:value, object#next(iter))
        return index
      endif
      let index += 1
    endwhile
  catch 'StopIteration'
    call object#ValueError("sequence.index(x): x not in sequence")
  endtry
endfunction
" }}}1

" FUNCTION: count() {{{1
" Return the times value appears in iterable.
function! object#iter#count(iterable, value)
  let iter = object#iter(a:iterable)
  let sum = 0
  try
    while 1
      if maktaba#value#IsEqual(a:value, object#next(iter))
        let sum += 1
      endif
    endwhile
  catch 'StopIteration'
    return sum
  endtry
endfunction
" }}}1

" FUNCTION: any() {{{1
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
      if object#bool(object#iter#next(iter))
        return 1
      endif
    endwhile
  catch 'StopIteration'
    return 0
  endtry
endfunction
" }}}1

" FUNCTION: all() {{{1
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
      if !object#bool(object#iter#next(iter))
        return 0
      endif
    endwhile
  catch 'StopIteration'
    return 1
  endtry
endfunction
" }}}1

" FUNCTION: sum() {{{1
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
  let start = a:0 ? object#builtin#CheckNumeric('sum', 2, a:1) : 0
  try
    while 1
      " TODO use add()
      let N = object#next(iter)
      if !object#builtin#IsNumeric(N)
        call object#TypeError("sum() can only sum numerics")
      endif
      let start += N
    endwhile
  catch 'StopIteration'
    return start
  endtry
endfunction
" }}}1


" vim: set sw=2 sts=2 et fdm=marker:
