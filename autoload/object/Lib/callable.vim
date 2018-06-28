" function {<num>} get the definition for a numbered function
" which is a great way for inspection!
" function /<pattern> can search for a pattern of functions.
let s:plain_function = '\C\V\^function(''\(\.\*\)'')\$'
let s:dict_function = '\C\V\^function(''\(\.\*\)'', {\(\.\*\)})\$'
let s:class_function = '\C\V\^function(''\(\.\*\)'', {\.\*''__mro__'':})\$'

" word(#word)+
let s:autoload_funcname = '\C\V\^\(\w+\%(#\w\+\)\+\$'
let s:script_funcname = '\C\V\^<SNR>\d\+_\w\+\$'
let s:number_funcname = '\C\V\^\d\+\$'

let s:keyval = '\C\V''\w\{-1,}'': \[^,]\{-1,}'
let s:outmost__mro__ = '\C\V''__mro__'''

let s:valid_object = '\C\V''__class__'': ''\w\{-1,}'''
let s:valid_class = '\C\V
let s:__name__entry = '\C\V''__name__'': ''\(\w\{-1,}\)'''

" We currently handle 3 kinds of functions:
" - Plain function like printf(), len().
" - Dict function:
"   - class => <function cls.method>
"   - obj => <bound method cls.method of <repr(obj)>>
"   - module => <function module.name>
"   - Plain dict => <dict function name>
"   Later we will handle:
"   - classmethod => <bound method cls.method of <repr(cls)>>
"   - staticmethod => <function cls.method>
"
" NOTE: We are unable to do repr() with obj or cls since there
" is no way can we fetch the bound dict.
function! object#callable#repr(X)
  let raw = string(a:X)
  let funcname = matchstr(raw, s:plain_function)
  " XXX: Maybe we can use optional dict and capture the dict and funcname
  " at the same time.
  if name isnot ''
    return printf('<function %s>', funcname)
  endif
  let [_, funcname, dict] = matchlist(raw, s:dict_function)
  let 
  " With name as value in dict, lookup the key (attribute name)
  let name = object#callable#GetMethodName(funcname, dict)
  " Figure out the enclosing name and the type of the enclosing scopes:
  " object, class, module.
  if dict !~# s:object_scope
    " Plain dict function
    return printf('<dict function %s'>, name)
  endif
  let enclosing = object#callable#GetEnclosingName(dict)
  elseif dict =~# s:class_scope || dict =~# s:module_scope
    return printf('<function %s.%s>', enclosing, name)
  else
    return printf('<bound method %s.%s>', enclosing, name)
  endif
endfunction

function! object#callable#GetMethodName(funcname, dict)
  " '<name>': <funcname>
  " Match <funcname> in dict and return <name>
  let entry = printf('\C\V''\(\w\{-1,}\)'': %s', a:funcname)
  let list = matchlist(a:dict, entry)
  if empty(list)
    call object#SystemError('BUG: funcname %s not in dict %s (pattern: %s)',
          \ a:funcname, a:dict, a:entry)
  endif
  return list[1]
endfunction

function! object#callable#GetEnclosingName(dict)
  let list = matchlist(a:dict, s:__name__entry)
  if empty(list)
    call object#SystemError('BUG: Cannot find __name__ (pattern: %s)',
          \ s:__name__entry)
  endif
  return list[1]
endfunction
