let s:object = object#object_()

" FINAL CLASS: range {{{1
call object#class#builtin_class('range', s:object, s:)
let s:range.__final__ = 1

" METHOD: __init__() {{{1
" Note: all of these attributes are readonly.
function! s:range.__init__(...)
  if a:0 < 1
    call object#TypeError("range expected at least 1 arguments, got 0")
  endif
  if a:0 > 3
    call object#TypeError("range expected at most 3 arguments, got %d", a:0)
  endif
  " Check all args are int.
  call map(copy(a:000), 'object#builtin#CheckNumber2(v:val)')
  if a:0 == 3 && a:3 == 0
    call object#ValueError("range() arg 3 must not be zero")
  endif
  let self.start = a:0 >= 2 ? a:1 : 0
  let self.stop = a:0 >= 2 ? a:2 : a:1
  let self.step = a:0 == 3 ? a:3 : 1
  let self._length = s:ComputeLength(self.start, self.stop, self.step)
endfunction

" METHOD: __repr__() {{{1
function! s:range.__repr__()
  return self.step == 1 ? printf('range(%d, %d)', self.start, self.stop):
        \ printf('range(%d, %d, %d)', self.start, self.stop, self.step)
endfunction

let s:range.__str__ = s:range.__repr__

" METHOD: __setattr__() {{{1
let s:range.__setattr__ = object#slots#readonly_attribute()

" METHOD: __eq__() {{{1
function! s:range.__eq__(other)
  if !object#builtin#IsObj(a:other)
    return 0
  endif
  if self is a:other
    return 1
  endif
  if a:other.__class__ isnot s:range
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

function! s:range.__ne__(other)
  return !self.__eq__(a:other)
endfunction

" METHOD: __contains__() {{{1
function! s:range.__contains__(value)
  if !object#builtin#IsNumber(a:value)
    return object#iter#contains(self, a:value)
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

" METHOD: __getitem__() {{{1
function! s:range.__getitem__(index)
  if object#builtin#IsNumber(a:index)
    let index = a:index < 0 ? a:index + self._length : a:index
    if 0 <= index && index < self._length
      return self.start + index * self.step
    endif
    call object#IndexError("range object index out of range")
  endif

  " TODO slice
  call object#TypeError("range indices must be integers or slices, not %s",
          \ object#builtin#TypeName(a:index))
endfunction

" METHOD: __iter__() {{{1
function! s:range.__iter__()
  return object#new(s:range_iterator,
        \ self.start,
        \ self.step,
        \ self._length)
endfunction

" METHOD: __reversed__() {{{1
function! s:range.__reversed__()
  return object#new(s:range_iterator,
        \ self.start + (self._length-1) * self.step,
        \ -self.step,
        \ self._length)
endfunction

" METHOD: __len__() {{{1
function! s:range.__len__()
  return self._length
endfunction

" METHOD: count() {{{1
function! s:range.count(value)
  if object#builtin#IsNumber(a:value)
    return self.__contains__(a:value)
  endif
  return object#iter#count(self, a:value)
endfunction

" METHOD: index() {{{1
function! s:range.index(value)
  if !object#builtin#IsNumber(a:value)
    return object#iter#index(self, a:value)
  endif
  if self.__contains__(a:value)
    return (a:value - self.start) / self.step
  endif
  call object#ValueError("%d is not in range", a:value)
endfunction

" }}}1

" FINAL CLASS: range_iterator {{{1
call object#class#builtin_class('range_iterator', s:object, s:)
let s:range_iterator.__final__ = 1

" METHOD: __init__() {{{1
function! s:range_iterator.__init__(start, step, length)
  let self._start = a:start
  let self._step = a:step
  let self._length = a:length
  let self._index = 0
endfunction

" SLOTS: {{{1
let s:range_iterator.__iter__ = object#slots#iter_self()
let s:range_iterator.__setattr__ = object#slots#readonly_attribute()

" METHOD: __next__() {{{1
function! s:range_iterator.__next__()
  if self._index < self._length
    let N = self._index * self._step + self._start
    let self._index += 1
    return N
  endif
  call object#StopIteration()
endfunction
" }}}1

" FUNCTION: range() {{{1
function! object#iter#range#range(...)
  return object#new_(s:range, a:000)
endfunction

" FUNCTION: ComputeLength() {{{1
function! s:ComputeLength(start, stop, step)
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
