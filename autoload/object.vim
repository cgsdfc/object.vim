if exists('s:loaded')
  finish
endif

call object#Lib#bootstrap#Initialize()
let s:loaded = 1

" TODO: Use the Lib.builtins
" MODULE: types.vim {{{1

function! object#object(...) abort
  return object#Lib#builtin#New_('object', a:000)
endfunction

function! object#None(...) abort
  return call('object#class#types#None', a:000)
endfunction
" }}}1

" MODULE: class.vim {{{1

function! object#class(...) abort
  return call('object#class#class', a:000)
endfunction

function! object#type(...) abort
  return call('object#class#type', a:000)
endfunction

function! object#new_(...) abort
  return call('object#class#new_', a:000)
endfunction

function! object#new(...) abort
  return call('object#class#new', a:000)
endfunction

function! object#isinstance(...) abort
  return call('object#class#isinstance', a:000)
endfunction

function! object#issubclass(...) abort
  return call('object#class#issubclass', a:000)
endfunction
" }}}1

" MODULE: proto.vim {{{1
function! object#repr(...) abort
  return call('object#proto#repr', a:000)
endfunction
" }}}1

" MODULE: attr.vim {{{1
function! object#dir(...) abort
  return call('object#proto#attr#dir', a:000)
endfunction

function! object#getattr(...) abort
  return call('object#proto#attr#getattr', a:000)
endfunction

function! object#delattr(...) abort
  return call('object#proto#attr#delattr', a:000)
endfunction

function! object#setattr(...) abort
  return call('object#proto#attr#setattr', a:000)
endfunction

function! object#hasattr(...) abort
  return call('object#proto#attr#hasattr', a:000)
endfunction
" }}}1

" MODULE: seqn.vim Sequence Protocols {{{1
function! object#len(...) abort
  return call('object#proto#seqn#len', a:000)
endfunction

function! object#in(...) abort
  return call('object#proto#seqn#in', a:000)
endfunction
" }}}1
" }}}1

" MODULE: hash.vim {{{1
function! object#hash(...) abort
  return call('object#hash#hash', a:000)
endfunction
" }}}1

" MODULE: mapping.vim {{{1
function! object#delitem(...) abort
  return call('object#proto#mapping#delitem', a:000)
  return object#Modules#builtin('delitem', a:000)
endfunction

function! object#getitem(...) abort
  return call('object#proto#mapping#getitem', a:000)
endfunction

function! object#setitem(...) abort
  return call('object#proto#mapping#setitem', a:000)
endfunction
" }}}1

" MODULE: except.vim: raise() and Exception Hierarchy {{{1

function! object#raise(...) abort
  return call('object#except#raise', a:000)
endfunction

function! object#Exception(...) abort
  return call('object#except#throw#Exception', a:000)
endfunction

function! object#ValueError(...) abort
  return call('object#except#throw#ValueError', a:000)
endfunction

function! object#TypeError(...) abort
  return call('object#except#throw#TypeError', a:000)
endfunction

function! object#StopIteration(...) abort
  return call('object#except#throw#StopIteration', a:000)
endfunction

function! object#AttributeError(...) abort
  return call('object#except#throw#AttributeError', a:000)
endfunction

function! object#IndexError(...) abort
  return call('object#except#throw#IndexError', a:000)
endfunction

function! object#KeyError(...) abort
  return call('object#except#throw#KeyError', a:000)
endfunction

function! object#OSError(...) abort
  return call('object#except#throw#OSError', a:000)
endfunction

function! object#NameError(...) abort
  return call('object#except#throw#NameError', a:000)
endfunction

function! object#VimError(...) abort
  return call('object#except#throw#VimError', a:000)
endfunction

function! object#RuntimeError(...) abort
  return call('object#except#throw#RuntimeError', a:000)
endfunction

function! object#SyntaxError(...) abort
  return call('object#except#throw#SyntaxError', a:000)
endfunction
" }}}1

" MODULE: iter.vim {{{1

function! object#iter(...) abort
  return call('object#iter#iter', a:000)
endfunction

function! object#next(...) abort
  return call('object#iter#next', a:000)
endfunction

function! object#all(...) abort
  return call('object#iter#all', a:000)
endfunction

function! object#any(...) abort
  return call('object#iter#any', a:000)
endfunction

function! object#sum(...) abort
  return call('object#iter#sum', a:000)
endfunction
" }}}1

" MODULE: enumerate, zip, map, filter {{{1
function! object#enumerate(...) abort
  return object#Lib#BuiltinType_New('enumerate', a:000)
endfunction

function! object#zip(...) abort
  return call('object#iter#zip#zip', a:000)
endfunction

function! object#map(...) abort
  return call('object#iter#map#map', a:000)
endfunction

function! object#filter(...) abort
  return call('object#iter#filter#filter', a:000)
endfunction
" }}}1

" MODULE: range {{{1
function! object#range(...) abort
  return call('object#iter#range#range', a:000)
endfunction
" }}}1

" MODULE: reversed {{{1
function! object#reversed(...) abort
  return call('object#iter#reversed#reversed', a:000)
endfunction
" }}}1

" MODULE: file.vim {{{1

function! object#open(...) abort
  return call('object#io#file#open', a:000)
endfunction

function! object#file_(...) abort
  return call('object#io#file#file_', a:000)
endfunction
" }}}1

" MODULE: lambda.vim {{{1

function! object#lambda(...) abort
  return call('object#lambda#lambda', a:000)
endfunction

function! object#_lambda(...) abort
  return call('object#lambda#_lambda', a:000)
endfunction

function! object#lambda_(...) abort
  return call('object#lambda#lambda_', a:000)
endfunction

function! object#for(...) abort
  return call('object#lambda#for', a:000)
endfunction
" }}}1

" MODULE: super.vim {{{1

function! object#super(...) abort
  return call('object#class#super#super', a:000)
endfunction

function! object#super_(...) abort
  return call('object#class#super#super_', a:000)
endfunction
" }}}1

" MODULE: list.vim {{{1
"
function! object#list_(...) abort
  return call('object#list#list#list_', a:000)
endfunction

function! object#list(...) abort
  return call('object#list#list', a:000)
endfunction

function! object#_list(...) abort
  return call('object#list#list#_list', a:000)
endfunction
" }}}1

" MODULE: dict.vim {{{1
"
function! object#dict_(...) abort
  return call('object#dict#dict#dict_', a:000)
endfunction

function! object#dict(...) abort
  return call('object#dict#dict', a:000)
endfunction

function! object#_dict(...) abort
  return call('object#dict#dict#_dict', a:000)
endfunction
" }}}1

" MODULE: str.vim {{{1
"
function! object#str(...) abort
  return call('object#str#str', a:000)
endfunction

function! object#chr(...) abort
  return call('object#str#chr', a:000)
endfunction

function! object#ord(...) abort
  return call('object#str#ord', a:000)
endfunction

function! object#_str(...) abort
  return call('object#str#str#_str', a:000)
endfunction

function! object#str_(...) abort
  return call('object#str#str#str_', a:000)
endfunction
" }}}1

" MODULE: int.vim {{{1
function! object#int(...) abort
  return call('object#number#int#int', a:000)
endfunction

function! object#_int(...) abort
  return call('object#number#int#_int', a:000)
endfunction

function! object#int_(...) abort
  return call('object#number#int#int_', a:000)
endfunction

function! object#bin(...) abort
  return call('object#number#int#bin', a:000)
endfunction

function! object#hex(...) abort
  return call('object#number#int#hex', a:000)
endfunction

function! object#oct(...) abort
  return call('object#number#int#oct', a:000)
endfunction

function! object#abs(...) abort
  return call('object#number#int#abs', a:000)
endfunction
" }}}1

" MODULE: bool.vim {{{1
function! object#bool(...) abort
  return call('object#bool#bool', a:000)
endfunction
" }}}1

" vim: set sw=2 sts=2 et fdm=marker:
