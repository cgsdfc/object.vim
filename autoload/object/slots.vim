" Boilerplate methods to implement certain behaviours of
" builtin types go here.

" Use Dictionary Function so that function becomes Funcref
" once they are defined.
let s:slots = {}

function! s:slots.readonly_attribute(name, val)
  call object#AttributeError('readonly attribute')
endfunction

function! s:slots.iter_self()
  return self
endfunction

function! object#slots#readonly_attribute()
  return s:slots.readonly_attribute
endfunction

function! object#slots#iter_self()
  return s:slots.iter_self
endfunction
