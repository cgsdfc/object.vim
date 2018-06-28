" TODO: Don't use s:slots.
" The dictionary holding up all these slots only to make them
" Funcref is unnecessary. User can use `function()` themselves.
" All we need to do is define the operations here.
" like:
" function! object#slots#getitem(obj, key)
"   return a:obj[a:key]
" endfunction
"
" User can also take advantage of `object#bulitin#Call()` so that
" exceptions get properly translated.
"
" TODO: For locked variables, use VariableLockedError or some
" bigger name other than RuntimeError.
" After all, exceptions stand for their names.

" Boilerplate methods to implement certain behaviours of
" builtin types go here.

" Use Dictionary Function so that function becomes Funcref
" once they are defined.
let s:slots = {}

" Slots {{{1
function! s:slots.readonly_attribute2(name, val)
  try
    call object#getattr(self, a:name)
  catch 'AttributeError'
    throw v:exception
  endtry
  call object#AttributeError("'%s' object attribute '%s' is read-only",
        \ self.__class__.__name__, a:name)
endfunction

function! s:slots.readonly_attribute(name, val)
  call object#AttributeError('readonly attribute')
endfunction

function! s:slots.iter_self()
  return self
endfunction

function! s:slots.getitem(obj, key)
  return a:obj[a:key]
endfunction

function! s:slots.setitem(obj, key, val)
  let a:obj[a:key] = a:val
endfunction

" Getter of the slots. {{{1
function! object#slots#readonly_attribute2()
  return s:slots.readonly_attribute2
endfunction

function! object#slots#readonly_attribute()
  return s:slots.readonly_attribute
endfunction

function! object#slots#iter_self()
  return s:slots.iter_self
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
