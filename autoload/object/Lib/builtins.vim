" Serves as the builtins module.
function! object#Lib#builtins#GetModuleDict()
  return s:
endfunction

function! object#Lib#builtins#New_(name, args) "{{{1
  " Create an object of builtin type.
  let type = get(s:, a:name)
  return object#Lib#class#Object_New_(type, a:args)
endfunction

function! object#Lib#builtins#Type_New(name) "{{{1
  " Create and register a builtin type.
  let type = object#Lib#class#BuiltinType_New(a:name)
  let s:{a:name} = type
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
