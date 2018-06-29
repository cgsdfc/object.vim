if exists('s:loaded') && s:loaded is 1
  finish
endif

call object#Lib#builtins#Bootstrap()
let s:loaded = 1

function! object#object() abort "{{{1
  return object#Lib#builtins#Object_New('object')
endfunction

function! object#None(...) abort "{{{1
  return object#Lib#builtins#Get('None')
endfunction

function! object#class(...) abort "{{{1
  return object#Lib#builtins#Call_('class', a:000)
endfunction

function! object#type(...) abort "{{{1
  return object#Lib#builtins#Object_New_('type', a:000)
endfunction

function! object#new(...) abort "{{{1
  return object#Lib#builtins#Call_('new', a:000)
endfunction

function! object#isinstance(...) abort "{{{1
  return object#Lib#builtins#Call_('isinstance', a:000)
endfunction

function! object#issubclass(...) abort "{{{1
  return object#Lib#builtins#Call_('issubclass', a:000)
endfunction

function! object#repr(...) abort "{{{1
  return object#Lib#builtins#Call_('repr', a:000)
endfunction

function! object#dir(...) abort "{{{1
  return object#Lib#builtins#Call_('dir', a:000)
endfunction

function! object#getattr(...) abort "{{{1
  return object#Lib#builtins#Call_('getattr', a:000)
endfunction

function! object#delattr(...) abort "{{{1
  return object#Lib#builtins#Call_('delattr', a:000)
endfunction

function! object#setattr(...) abort "{{{1
  return object#Lib#builtins#Call_('setattr', a:000)
endfunction

function! object#hasattr(...) abort "{{{1
  return object#Lib#builtins#Call_('hasattr', a:000)
endfunction

function! object#len(...) abort "{{{1
  return object#Lib#builtins#Call_('len', a:000)
endfunction

function! object#in(...) abort "{{{1
  return object#Lib#builtins#Call_('in', a:000)
endfunction

function! object#hash(...) abort "{{{1
  return object#Lib#builtins#Call_('hash', a:000)
endfunction

function! object#delitem(...) abort "{{{1
  return object#Lib#builtins#Call_('delitem', a:000)
endfunction

function! object#getitem(...) abort "{{{1
  return object#Lib#builtins#Call_('getitem', a:000)
endfunction

function! object#setitem(...) abort "{{{1
  return object#Lib#builtins#Call_('setitem', a:000)
endfunction


function! object#raise(...) abort "{{{1
  return object#Lib#builtins#Call_('raise', a:000)
endfunction

" TODO: Since they are frequently used, don't rely on
" the system, just throw them.
function! object#Exception(...) abort "{{{1
  return object#Lib#except#FastThrowException('Exception', a:000)
endfunction

function! object#ValueError(...) abort "{{{1
  return object#Lib#except#FastThrowException('ValueError', a:000)
endfunction

function! object#TypeError(...) abort "{{{1
  return object#Lib#except#FastThrowException('TypeError', a:000)
endfunction

function! object#StopIteration(...) abort "{{{1
  return object#Lib#except#FastThrowException('StopIteration', a:000)
endfunction

function! object#AttributeError(...) abort "{{{1
  return object#Lib#except#FastThrowException('AttributeError', a:000)
endfunction

function! object#IndexError(...) abort "{{{1
  return object#Lib#except#FastThrowException('IndexError', a:000)
endfunction

function! object#KeyError(...) abort "{{{1
  return object#Lib#except#FastThrowException('KeyError', a:000)
endfunction

function! object#OSError(...) abort "{{{1
  return object#Lib#except#FastThrowException('OSError', a:000)
endfunction

function! object#NameError(...) abort "{{{1
  return object#Lib#except#FastThrowException('NameError', a:000)
endfunction

function! object#VimError(...) abort "{{{1
  return object#Lib#except#FastThrowException('VimError', a:000)
endfunction

function! object#RuntimeError(...) abort "{{{1
  return object#Lib#except#FastThrowException('RuntimeError', a:000)
endfunction

function! object#SyntaxError(...) abort "{{{1
  return object#Lib#except#FastThrowException('SyntaxError', a:000)
endfunction


function! object#iter(...) abort "{{{1
  return object#Lib#builtins#Call_('iter', a:000)
endfunction

function! object#next(...) abort "{{{1
  return object#Lib#builtins#Call_('next', a:000)
endfunction

function! object#all(...) abort "{{{1
  return object#Lib#builtins#Call_('all', a:000)
endfunction

function! object#any(...) abort "{{{1
  return object#Lib#builtins#Call_('any', a:000)
endfunction

function! object#sum(...) abort "{{{1
  return object#Lib#builtins#Call_('sum', a:000)
endfunction

function! object#enumerate(...) abort "{{{1
  return object#Lib#builtins#Object_New_('enumerate', a:000)
endfunction

function! object#zip(...) abort "{{{1
  return object#Lib#builtins#Object_New_('zip', a:000)
endfunction

function! object#map(...) abort "{{{1
  return object#Lib#builtins#Object_New_('map', a:000)
endfunction

function! object#filter(...) abort "{{{1
  return object#Lib#builtins#Object_New_('filter', a:000)
endfunction

function! object#range(...) abort "{{{1
  return object#Lib#builtins#Object_New_('range', a:000)
endfunction

function! object#reversed(...) abort "{{{1
  return object#Lib#builtins#Object_New_('reversed', a:000)
endfunction




function! object#lambda(...) abort "{{{1
  return object#Lib#builtins#Object_New_('lambda', a:000)
endfunction

function! object#for(...) abort "{{{1
  return object#Lib#builtins#Call_('for', a:000)
endfunction


function! object#super(...) abort "{{{1
  return object#Lib#builtins#Object_New_('super', a:000)
endfunction

function! object#super_(...) abort "{{{1
  return object#Lib#builtins#Call_('super_', a:000)
endfunction


function! object#list(...) abort "{{{1
  return object#Lib#builtins#Object_New_('list', a:000)
endfunction



function! object#dict(...) abort "{{{1
  return object#Lib#builtins#Object_New_('dict', a:000)
endfunction


function! object#str(...) abort "{{{1
  return object#Lib#builtins#Object_New_('str', a:000)
endfunction

function! object#chr(...) abort "{{{1
  return object#Lib#builtins#Call_('chr', a:000)
endfunction

function! object#ord(...) abort "{{{1
  return object#Lib#builtins#Call_('ord', a:000)
endfunction

function! object#int(...) abort "{{{1
  return object#Lib#builtins#Call_('int', a:000)
endfunction

function! object#bin(...) abort "{{{1
  return object#Lib#builtins#Call_('bin', a:000)
endfunction

function! object#hex(...) abort "{{{1
  return object#Lib#builtins#Call_('hex', a:000)
endfunction

function! object#oct(...) abort "{{{1
  return object#Lib#builtins#Call_('oct', a:000)
endfunction

function! object#abs(...) abort "{{{1
  return object#Lib#builtins#Call_('abs', a:000)
endfunction

function! object#bool(...) abort "{{{1
  return call('object#Lib#bool#Bool', a:000)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
