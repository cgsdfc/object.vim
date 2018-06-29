let rangeobj = object#Lib#builtins#Type_New('range')
let s:rangeobj.__final__ = 1

" Note: all of these attributes are readonly.
function! s:rangeobj.__init__(...) "{{{1
  if a:0 < 1
    call object#TypeError("range expected at least 1 arguments, got 0")
  endif
  if a:0 > 3
    call object#TypeError("range expected at most 3 arguments, got %d", a:0)
  endif
  " Check all args are int.
  call map(copy(a:000), 'object#Lib#value#CheckNumber2(v:val)')
  if a:0 == 3 && a:3 == 0
    call object#ValueError("range() arg 3 must not be zero")
  endif
  let self.start = a:0 >= 2 ? a:1 : 0
  let self.stop = a:0 >= 2 ? a:2 : a:1
  let self.step = a:0 == 3 ? a:3 : 1
  let self._length = s:ComputeLength(self.start, self.stop, self.step)
endfunction

function! s:rangeobj.__repr__() "{{{1
  return self.step == 1 ? printf('range(%d, %d)', self.start, self.stop):
        \ printf('range(%d, %d, %d)', self.start, self.stop, self.step)
endfunction

let s:rangeobj.__str__ = s:rangeobj.__repr__
let s:rangeobj.__setattr__ = function('object#Lib#attr#ReadonlyAttro')

function! s:rangeobj.__eq__(other) "{{{1
  if !object#Lib#value#IsObj(a:other)
    return 0
  endif
  if self is a:other
    return 1
  endif
  if a:other.__class__ isnot s:rangeobj
    return 0
  endif
  if self._length != a:other._length
    return 0
  endif
  if !self._length
    return 1
  endif
  if self.start != a:other.start
    return 0
  endif
  if self._length == 1
    return 1
  endif
  return self.step == a:other.step
endfunction

function! s:rangeobj.__ne__(other) "{{{1
  return !self.__eq__(a:other)
endfunction

function! s:rangeobj.__contains__(value) "{{{1
  if !object#Lib#value#IsNumber(a:value)
    return object#Lib#seqn#Iterable_Contains(self, a:value)
  endif
  " Check if value is ever possible to be in range.
  if self.step > 0
    let cmp1 = self.start <= a:value
    let cmp2 = a:value < self.stop
  else
    let cmp1 = self.start >= a:value
    let cmp2 = a:value > self.stop
  endif
  if cmp1 == 0 || cmp2 == 0
    return 0
  endif
  " Check if stride invalidate membership of value.
  return 0 == (a:value - self.start) % self.step
endfunction

function! s:rangeobj.__getitem__(index) "{{{1
  if object#Lib#value#IsNumber(a:index)
    let index = a:index < 0 ? a:index + self._length : a:index
    if 0 <= index && index < self._length
      return self.start + index * self.step
    endif
    call object#IndexError("range object index out of range")
  endif
  " TODO slice
  call object#TypeError("range indices must be integer, not %s",
          \ object#Lib#value#TypeName(a:index))
endfunction

function! s:rangeobj.__iter__() "{{{1
  return object#Lib#builtins#Object_New('range_iterator',
        \ self.start,
        \ self.step,
        \ self._length)
endfunction

function! s:rangeobj.__reversed__() "{{{1
  return object#Lib#builtins#Object_New('range_iterator',
        \ self.start + (self._length-1) * self.step,
        \ -self.step,
        \ self._length)
endfunction

function! s:rangeobj.__len__() "{{{1
  return self._length
endfunction

function! s:rangeobj.count(value) "{{{1
  if object#Lib#value#IsNumber(a:value)
    return self.__contains__(a:value)
  endif
  return object#iter#count(self, a:value)
endfunction

function! s:rangeobj.index(value) "{{{1
  if !object#Lib#value#IsNumber(a:value)
    return object#iter#index(self, a:value)
  endif
  if self.__contains__(a:value)
    return (a:value - self.start) / self.step
  endif
  call object#ValueError("%d is not in range", a:value)
endfunction

let s:rangeiter = object#Lib#builtins#IteratorType_New('range_iterator')
let s:rangeiter.__final__ = 1

function! s:rangeiter.__init__(start, step, length) "{{{1
  let self._start = a:start
  let self._step = a:step
  let self._length = a:length
  let self._index = 0
endfunction

let s:rangeiter.__iter__ = function('object#Lib#iter#IterSelf')
let s:rangeiter.__setattr__ = function('object#Lib#attr#ReadonlyAttro')

function! s:rangeiter.__next__() "{{{1
  if self._index < self._length
    let N = self._index * self._step + self._start
    let self._index += 1
    return N
  endif
  call object#StopIteration()
endfunction

function! s:ComputeLength(start, stop, step) "{{{1
  " Reference: Python-3.6.5/Objects/rangeobject.c
  if a:step > 0
    let lo = a:start
    let hi = a:stop
    let step = a:step
  else
    let lo = a:stop
    let hi = a:start
    let step = -a:step
  endif
  if lo >= hi
    return 0
  endif
  return ((hi - lo - 1) / step) + 1
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
