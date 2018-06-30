let s:intobj = object#Lib#builtins#Type_New('int')

function! s:intobj.__new__(...)
  let obj = object#Lib#class#Object__new__(s:intobj)
  let obj.real = call('object#lib#number#int', a:000)
  let obj.imag = 0
  let obj.denominator = 1
  let obj.numerator = obj.real
  return obj
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
