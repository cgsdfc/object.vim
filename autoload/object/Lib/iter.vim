let s:builtins = object#Lib#builtins#GetModuleDict()

function! object#Lib#iter#iter(...) abort "{{{1
  " Return an iterator from {obj}.
  " >
  "   iter(List) -> list_iterator
  "   iter(String) -> str_iterator
  "   iter(obj) -> obj.__iter__()
  "   iter(callable, sentinel) -> callable_iterator
  " <
  if a:0 == 0
    call object#TypeError("iter expected at least 1 arguments, got 0")
  endif
  if a:0 > 2
    call object#TypeError("iter expected at most 2 arguments, got 3")
  endif
  if a:0 == 2
    if !object#Lib#value#IsFuncref(a:1)
      call object#TypeError("iter(v, w): v must be callable")
    endif
    return object#Lib#builtins#Object_New_('callable_iterator', a:000)
  endif
  if object#Lib#proto#IsIterable(a:1)
    let obj = a:1
  else
    call object#TypeError("'%s' object is not iterable",
          \ object#Lib#value#TypeName(a:X))
  endif
  if object#Lib#value#IsList(obj)
    return object#Lib#builtins#Object_New('list_iterator', obj)
  endif
  if object#Lib#value#IsString(obj)
    return object#Lib#builtins#Object_New('str_iterator', obj)
  endif
  let iter = object#Lib#func#CallFuncref(obj.__iter__)
  if !object#Lib#proto#IsIterator(iter)
    call object#TypeError("iter() returned non-iterator of type '%s'",
          \ object#Lib#value#TypeName(iter))
  endif
  return iter
endfunction
let s:builtins.iter = function('object#Lib#iter#iter')

function! s:CheckIterator(X, msg) abort "{{{1
  if object#Lib#proto#IsIterator(a:X)
    return a:X
  endif
  call object#TypeError(a:msg)
endfunction

function! object#Lib#iter#next(obj, ...) abort "{{{1
  " Retrieve the next item from an iterator.
  " >
  "   next(iter) -> next item from iter
  " <
  call object#Lib#value#TakeAtMostOptional('next', 1, a:0)
  if !object#Lib#proto#IsIterator(a:obj)
    call object#TypeError("'%s' object is not an iterator",
          \ object#Lib#value#TypeName(a:obj))
  endif
  try
    let Val = object#Lib#func#CallFuncref(a:obj.__next__)
    return Val
  catch 'StopIteration'
    if a:0 == 1
      return a:1
    endif
    throw v:exception
  endtry
endfunction
let s:builtins.next = function('object#Lib#iter#next')

function! object#Lib#iter#any(iter) abort "{{{1
  " any(iterable) -> if any of the items is True
  let iter = object#iter(a:iter)
  try
    while 1
      if object#bool(object#next(iter))
        return 1
      endif
    endwhile
  catch 'StopIteration'
    return 0
  endtry
endfunction
let s:builtins.any = function('object#Lib#iter#any')

function! object#Lib#iter#all(iter) abort "{{{1
  " all(iterable) -> if all of the items is True
  let iter = object#iter(a:iter)
  try
    while 1
      if !object#bool(object#Lib#iter#next(iter))
        return 0
      endif
    endwhile
  catch 'StopIteration'
    return 1
  endtry
endfunction
let s:builtins.all = function('object#Lib#iter#all')

function! object#Lib#iter#sum(iter, ...) abort "{{{1
  " Return the sum of items from {iter} plus [start], which defaults to 0.
  " >
  "   sum(iter, start=0) -> start + the sum of items.
  " <
  " Items must be numeric.
  call object#Lib#value#TakeAtMostOptional('sum', 1, a:0)
  let iter = object#iter(a:iter)
  let start = a:0 ? object#Lib#value#CheckNumeric('sum', 2, a:1) : 0
  try
    while 1
      " TODO use add()
      let N = object#next(iter)
      if !object#Lib#value#IsNumeric(N)
        call object#TypeError("sum() only accepts numerics")
      endif
      let start += N
    endwhile
  catch 'StopIteration'
    return start
  endtry
endfunction
let s:builtins.sum = function('object#Lib#iter#sum')

function! object#Lib#iter#Index(iterable, value) abort "{{{1
  " Return the index of the first occurence of value.
  " Throw ValueError if not present.
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

function! object#Lib#iter#Count(iterable, value) abort "{{{1
  " Return the times value appears in iterable.
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

function! object#Lib#iter#Contains(iterable, target) abort "{{{1
  " Return whether `target` is in `iterable`.
  let iter = object#iter(a:iterable)
  try
    while 1
      " TODO: use object#eq()
      if maktaba#value#IsEqual(a:target, object#next(iter))
        return 1
      endif
    endwhile
  catch 'StopIteration'
    return 0
  endtry
endfunction

function! object#Lib#iter#IterSelf() dict abort "{{{1
  return self
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
