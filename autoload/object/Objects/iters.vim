let s:enumobj = object#Lib#builtins#IteratorType_New('enumerate')

" Note: enumerate is subclassable, that's why moving
" logic into __init__.
function! s:enumobj.__init__(iterable, ...) "{{{1
  call object#Lib#args#TakeAtMostOptional('enumerate', 1, a:0)
  let self._iterable = object#iter(a:iterable)
  let self._index = a:0 ? object#Lib#value#CheckNumber2(a:1) : 0
endfunction

function! s:enumobj.__next__() "{{{1
  let next = [self._index, object#next(self._iterable)]
  let self._index += 1
  return next
endfunction


let s:zip = object#Lib#builtins#IteratorType_New('zip')

function! s:zip.__init__(...) "{{{1
  let self._seqns = map(copy(a:000), 'object#iter(v:val)')
endfunction

function! s:zip.__next__() "{{{1
  if empty(self._seqns)
    call object#StopIteration()
  endif
  return map(copy(self._seqns), 'object#next(v:val)')
endfunction

let s:map = object#Lib#builtins#IteratorType_New('map')

function! s:map.__init__(callable, ...) "{{{1
  if !a:0
    call object#TypeError("map() must have at least two arguments")
  endif
  " Note: It does not check it immediately.
  let self._callable = a:callable
  let self._seqns = map(copy(a:000), 'object#iter(v:val)')
endfunction

function! s:map.__next__() "{{{1
  return object#builtin#Call_(self._callable,
        \ map(copy(self._seqns), 'object#next(v:val)'))
endfunction

let s:filterobj = object#Lib#builtins#IteratorType_New('filter')

" Note: Currently predicate doesn't support None.
" Use function('object#bool') instead.
function! s:filterobj.__init__(predicate, iterable) "{{{1
  let self._predicate = a:predicate
  let self._iterable = object#iter(a:iterable)
endfunction

function! s:filterobj.__next__() "{{{1
  while 1
    let N = object#next(self._iterable)
    if object#bool(object#Lib#func#Call(self._predicate, N))
      return N
    endif
  endwhile
endfunction

let s:str_iterator = object#Lib#builtins#IteratorType_New('str_iterator')
let s:str_iterator.__final__ = 1

function! s:str_iterator.__init__(str) "{{{1
  let self._index = 0
  let self._string = a:str
endfunction

" When the index to a string goes out of range, Vim
" returns an empty string, which is an indicator of StopIteration.
function! s:str_iterator.__next__() "{{{1
  let N = self._string[self._index]
  if N is ''
    call object#StopIteration()
  endif
  let self._index += 1
  return N
endfunction

let s:reversed = object#Lib#builtins#IteratorType_New('reversed')

function! s:reversed.__new__(seqn) "{{{1
  let seqn = s:CheckReversible(a:seqn)
  if object#Lib#value#IsList(seqn)
    return object#Lib#builtins#Object_New('list_reverseiterator', seqn)
  endif
  if object#Lib#proto#HasMethod(seqn, '__reversed__')
    return object#builtin#func#CallFuncref(seqn.__reversed__)
  endif
  let obj = object#Lib#class#Object_New(s:reversed)
  let obj._seqn = a:seqn
  let obj._index = object#len(a:seqn) - 1
  return obj
endfunction

function! s:reversed.__next__() "{{{1
  if self._index == -1
    call object#StopIteration()
  endif
  let N = object#getitem(self._seqn, self._index)
  let self._index -= 1
  return N
endfunction

function! s:CheckReversible(X) "{{{1
  if s:IsReversible(a:X)
    return a:X
  endif
  call object#TypeError("'%s' object is not reversible",
        \ object#Lib#value#TypeName(a:X))
endfunction

" - object with __reversed__()
" - Sequence object
" - Builtin sequence.
function! s:IsReversible(X) "{{{1
  return object#Lib#proto#HasMethod(a:X, '__reversed__') ||
        \ object#Lib#proto#IsSequence(a:X)
endfunction

let s:listiter = object#Lib#builtins#IteratorType_New('list_iterator')
let s:listiter.__final__ = 1

function! s:listiter.__init__(list) "{{{1
  let self._index = 0
  let self._list = a:list
endfunction

function! s:listiter.__next__() "{{{1
  try
    let N = self._list[self._index]
  catch 'E684:'
    " list index out of range.
    call object#StopIteration()
  endtry
  let self._index += 1
  return N
endfunction

let s:listreviter = object#Lib#builtins#IteratorType_New('list_reverseiterator')
let s:listreviter.__final__ = 1

" Note: To tell the truth, I don't quite understand why Python has a
" separated list_reverseiterator for list while other sequences all use
" plain reversed object.
function! s:listreviter.__init__(list) "{{{1
  let self._seqn = a:list
  let self._index = len(a:list) - 1
endfunction

function! s:listreviter.__next__() "{{{1
  if self._index == -1
    call object#StopIteration()
  endif
  let N = self._seqn[self._index]
  let self._index -= 1
  return N
endfunction

let s:callable_iterator = object#Lib#builtins#IteratorType_New('callable_iterator')
let s:callable_iterator.__final__ = 1

function! s:callable_iterator.__init__(callable, sentinel) "{{{1
  let self._callable = a:callable
  let self._sentinel = a:sentinel
endfunction

" TODO: self.callable can be method of other object,
" but it will forget the original self after put into
" callable_iterator.
" The callable module can detect this and create a method
" wrapper.
function! s:callable_iterator.__next__() "{{{1
  let Next = object#builtins#func#CallFuncref(self._callable)
  " TODO: __eq__()
  if Next ==# self._sentinel
    call object#StopIteration()
  endif
  return Next
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
