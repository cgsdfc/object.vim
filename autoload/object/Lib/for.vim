function! s:CheckCmds(X) "{{{1
  if object#Lib#value#IsString(a:X)
    return a:X
  endif
  if object#Lib#value#IsList(a:X)
    return map(copy(a:X), 'object#Lib#value#CheckString2(v:val)')
  endif
  call object#TypeError("for(): cmds must be a string or a list of strings")
endfunction

function! s:ExecuteForBody(__excmds, __items, __closure) "{{{1
  call extend(l:, a:__items)
  let c = a:__closure
  silent! execute a:__excmds
endfunction

function! object#Lib#for#for(names, iterable, cmds, ...) abort "{{{1
  " for('i', range(10), 'echo i')
  call object#Lib#value#TakeAtMostOptional('for', 1, a:0)
  let names = object#Lib#value#CheckString('for', 1, a:names)
  let iter = object#iter(a:iterable)
  let cmds = s:CheckCmds(a:cmds)
  let closure = a:0 ? object#Lib#value#CheckDict(a:1) : {}
  let excmds = object#Lib#value#IsString(cmds)? cmds : join(cmds, "\n")
  try
    while 1
      let N = object#next(iter)
      call s:ExecuteForBody(excmds,
            \ object#Lib#callable#UnpackIterator(names, N) , closure)
    endwhile
  catch 'StopIteration'
    return
  endtry
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
