" Serves as the builtins module.
let s:object = {}
let s:type = {}
let s:None = {}

call extend(s:object, {
      \ '__name__': 'object',
      \ '__class__': s:type,
      \ '__base__': s:None,
      \ '__bases__': [],
      \ '__mro__': [s:object],
      \})

call extend(s:type, {
      \ '__name__': 'type',
      \ '__class__': s:type,
      \ '__base__': s:object,
      \ '__bases__': [s:object],
      \ '__mro__': [s:type, s:object],
      \})

function! object#Lib#builtins#GetModuleDict() "{{{1
  return s:
endfunction

function! object#Lib#builtins#Get(name)
  return get(s:, a:name)
endfunction

function! object#Lib#builtins#New_(name, args) "{{{1
  " Create an object of builtin type.
  let type = get(s:, a:name)
  return object#Lib#class#New_(type, a:args)
endfunction

function! object#Lib#builtins#Type_New(...) "{{{1
  " Create and register a builtin type.
  let type = call('object#Lib#class#SimpleType_New', a:000)
  let s:{a:1} = type
endfunction

function! object#Lib#builtins#Call_(name, args) " {{{1
  " Call a builtin function by name.
  return object#Lib#func#Call_(get(s:, a:name), a:args)
endfunction

function! object#Lib#builtins#Call(name, ...) " {{{1
  " Call a builtin function by name.
  return object#Lib#func#Call_(get(s:, a:name), a:000)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
