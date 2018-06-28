let s:builtins = object#Lib#builtins#GetModuleDict()

let s:builtins.len = function('object#Lib#Len')
let s:builtins.in = function('object#Lib#in')


" vim: set sw=2 sts=2 et fdm=marker:
