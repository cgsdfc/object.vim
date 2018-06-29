" Serves as the builtins module.
let s:PATH_TO_OBJECTS = printf('%s/Objects/*.vim',
      \ fnamemodify(expand('<sfile>'), ':h:h'))

let s:builtins = {
      \ 'object': {},
      \ 'type': {},
      \ 'None': {},
      \ 'NotImplemented': {},
      \}

call extend(s:builtins.object, {
      \ '__name__': 'object',
      \ '__class__': s:builtins.type,
      \ '__base__': s:builtins.None,
      \ '__bases__': [],
      \ '__mro__': [s:builtins.object],
      \})

call extend(s:builtins.type, {
      \ '__name__': 'type',
      \ '__class__': s:builtins.type,
      \ '__base__': s:builtins.object,
      \ '__bases__': [s:builtins.object],
      \ '__mro__': [s:builtins.type, s:builtins.object],
      \})

function! object#Lib#builtins#Bootstrap() abort "{{{1
  " Bootstrap the builtin types.
  let files = glob(s:PATH_TO_OBJECTS, 0, 1)
  for f in files
    silent! source f
  endfor
endfunction

function! object#Lib#builtins#GetModuleDict() "{{{1
  return s:builtins
endfunction

function! object#Lib#builtins#Get(name)
  return get(s:builtins, a:name)
endfunction

function! object#Lib#builtins#New_(name, args) "{{{1
  " Create an object of builtin type.
  let type = get(s:builtins, a:name)
  return object#Lib#class#Object_New_(type, a:args)
endfunction

function! object#Lib#builtins#Type_New(...) "{{{1
  " Create and register a builtin type.
  let type = call('object#Lib#class#FastType_New', a:000)
  let s:builtins[a:1] = type
endfunction

function! object#Lib#builtins#IteratorType_New(...) abort "{{{1
  let type = call('object#Lib#builtin#Type_New', a:000)
  let type.__iter__ = function('object#Lib#iter#IterSelf')
  let type.__setattr__ = function('object#Lib#attr#ReadonlyAttros')
  return type
endfunction
function! object#Lib#builtins#Call_(name, args) " {{{1
  " Call a builtin function by name.
  return object#Lib#func#Call_(get(s:builtins, a:name), a:args)
endfunction

function! object#Lib#builtins#Call(name, ...) " {{{1
  " Call a builtin function by name.
  return object#Lib#func#Call_(get(s:builtins, a:name), a:000)
endfunction

" Load all the builtin functions that are not loaded.

" vim: set sw=2 sts=2 et fdm=marker:
