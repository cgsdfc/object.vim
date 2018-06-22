let s:object = object#object_()

" FINAL CLASS: range {{{1
call object#class#builtin_class('range', s:object, s:)

" Note: all of these attributes are readonly.
function! s:range.__init__(...)
  if a:0 < 1
    call object#TypeError("range expected at least 1 arguments, got 0")
  endif
  if a:0 > 3
    call object#TypeError("range expected at most 3 arguments, got %d", a:0)
  endif
  " Check all args are int.
  call map(a:000, 'object#builtin#CheckNumber2(v:val)')
  if a:0 == 3 && a:3 == 0
    call object#ValueError("range() arg 3 must not be zero")
  endif
  let self.step = a:0 == 3 ? a:3 : 1
  let self.start = a:0 == 2 ? a:1 : 0
  let self.stop = a:0 == 2 ? a:2 : a:1
  let self._length = object#range#compute_length(start, stop, step)
  let self._repr = object#range#compute_repr(a:000)
endfunction

function! s:range.__repr__()
  return self._repr
endfunction

function! s:range.__str__()
  return self._repr
endfunction

function! s:range.__setattr__(name, val)
  call object#AttributeError('readonly attribute')
endfunction

function! s:range.__eq__(other)
  if self is a:other
    return 1
  endif
  if !object#builtin#IsObj(a:other)
    return 0
  endif
  if a:other.__class__ isnot s:range
    return 0
  endif
  return self.start == a:other.start &&
        \self.stop == a:other.stop &&
        \self.step == a:other.step
endfunction

function! s:range.__ne__(other)
  return !self.__eq__(a:other)
endfunction

function! s:range.__contains__(value)
  if !object#builtin#IsNumber(a:value)
    return 0
  endif
  if self.step > 0
    return self.start <= a:value && a:value < self.stop
  endif
  return self.start >= a:value && a:value > self.stop
endfunction

function! s:range.__getitem__(index)
  if !object#builtin#IsNumber(a:index)
    call object#TypeError("range indices must be integers or slices, not %s",
          \ object#builtin#TypeName(a:index))
  endif
  let len = object#len(self)
  let index = a:index > 0 ? a:index : a:index + len

  if 0 <= index && index < len
    return self.start + a:index * self.step
  endif
  call object#IndexError("range object index out of range")
endfunction

function! s:range.count(value)
  return self.__contains__(a:value)
endfunction

function! s:range.index(value)
  if !self.__contains__(a:value)
    call object#ValueError(object#builtin#IsNumber(a:value)?
          \ printf('%d is not in range', a:value):
          \ "sequence.index(x): x not in sequence")
  endif
  return abs(a:value - self.start)
endfunction

function! s:range.__iter__()
  return object#new(s:range_iterator, self)
endfunction

function! s:range.__reversed__()
  " return object#new(s:range_iterator, 
endfunction

function! s:range.__len__()
  " Reference: Python-3.6.5/Objects/rangeobject.c
  let [lo, hi, step] = self.step > 0? [self.start, self.stop] :
        \ [self.stop, self.start]
  if lo >= hi
    return 0
  endif
  return ((hi - lo - 1) / abs(self.step)) + 1
endfunction

" }}}1

" FINAL CLASS: range_iterator {{{1
call object#class#builtin_class('range_iterator', s:object, s:)

function! s:range_iterator.__init__(start, stop, step)
  let self._curval = a:start
  let self._stop = a:stop
  let self._step = a:step
endfunction

function! s:range_iterator.__iter__()
  return self
endfunction

function! s:range_iterator.__next__()
  let nextval = self._curval
  if (self._step > 0 && nextval >= self._stop) ||
    \(self._step < 0 && nextval <= self._stop)
    call object#StopIteration()
  endif
  let self._curval += self._step
  return nextval
endfunction
" }}}1

" FUNCTION: range() {{{1
function! object#range#range(...)
  return object#new_(s:range, a:000)
endfunction

function! object#range#compute_length(start, stop, step)
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

function! object#range#compute_repr(args)
  return printf('range(%s)', join(copy(a:args), ', '))
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
