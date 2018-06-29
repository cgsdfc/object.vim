let s:intobj = object#Lib#builtins#Type_New('int')

function! s:intobj.__new__(...)
  let self = object#Lib#class#Object_New(s:intobj)
  let self.real = call('object#lib#number#int', a:000)
  let self.imag = 0
  let self.denominator = 1
  let self.numerator = self.real
  return self
endfunction

function! s:intobj.__abs__()
  return abs(self.real)
endfunction

function! s:intobj.__int__()
  return self.real
endfunction

function! s:intobj.__repr__()
  return object#repr(self.real)
endfunction

function! s:intobj.__str__()
  return object#str(self.real)
endfunction

function! s:intobj.__hash__()
  return object#hash(self.real)
endfunction

function! s:intobj.__bool__()
  return object#bool(self.real)
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
