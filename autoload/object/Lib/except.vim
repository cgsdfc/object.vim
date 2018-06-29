let s:builtins = object#Lib#builtins#GetModuleDict()

function! object#Lib#except#Raise(...) abort "{{{1
  " raise() -> Re-throw v:exception.
  " raise(type, ...) -> throw str(type(...)).
  if !a:0
    if v:exception isnot ''
      throw v:exception
    endif
    call object#RuntimeError('No active exception to reraise')
  endif
  if object#Lib#type#IsSubclass(a:1, s:BaseException)
    let e = object#Lib#class#Object_New_(a:except, a:args)
    throw printf('%s: %s', a:except.__name__, e.__str__())
  else
    call object#TypeError('exceptions must derive from BaseException')
  endif
endfunction
let s:builtins.raise = function('object#Lib#except#Raise')

function! object#Lib#except#FastThrowException(name, args) abort "{{{1
  " Implement functions like `object#ValueError()`.
  throw printf('%s: %s', a:name, len(a:args) == 0 ? '' :
        \ len(a:args) == 1 ? a:args[0]: call('printf', a:args))
endfunction

function! object#Lib#except#FormatVimError(error) abort "{{{1
  " Prettify v:exception.
  " ```
  "   Vim(let): E111: something bad happened
  "   becomes
  "   something bad happened (E111)
  " ```
  " I don't think the let is any useful.
  " What is really useful is the complete line of code
  " that goes wrong, the filename and the line number.
  " A plain let gives you too little than nothing.
  "
  " The oddness of the format of v:exception:
  " - When it is `throw`, it is the string that was thrown.
  " - When it is run in the prompt (interactively), the `Vim(xxx)`
  "   disappear.
  " - When run in a script, we have the full `Vim(xxx): E111: xxxx`.
  let list = matchlist(a:error, '\V\C\^\.\*\(E\d\+\): \(\.\+\)\$')
  if empty(list)
    return a:error
  endif
  return printf('%s (%s)', list[2], list[1])
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
