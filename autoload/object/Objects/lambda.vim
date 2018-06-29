let s:lambdaobj = object#Lib#builtins#Type_New('lambda')

function! s:lambdaobj.__new__(args, expr, ...) "{{{1
  call object#Lib#value#TakeAtMost('lambda.__new__', 1, a:0)
  let args = object#Lib#value#CheckString('lambda.__new__', 1, a:args)
  let expr = object#Lib#value#CheckString('lambda.__new__', 2, a:expr)
  if a:0 == 1
    let closure = object#Lib#value#CheckDict('lambda.__new__', 3, a:1)
  endif
  let obj = object#Lib#class#Object_New(s:lambdaobj)
  let obj.__args__ = split(args)
  let obj.__code__ = expr
  if a:0 == 1
    let obj.__closure__ = closure
  endif
  return obj
endfunction

function! s:lambdaobj.__call__(...) "{{{1
  return object#Objects#lambda#Eval([self] + a:000)
endfunction

function! object#Objects#lambda#Eval(lmbd, ...) abort "{{{1
  try
    let args = object#Lib#callable#UnpackArgs(a:lmbd.__args__, a:000)
  catch 'TypeError'
    call object#TypeError('lambda takes exactly %d arguments (%d given)',
          \ len(a:lmbd.__args__), len(a:000))
  endtry
  for [Key, Val] in args
    let {Key} = Val
  endfor
  if has_key(a:lmbd, '__closure__')
    let c = a:lmbd.__closure__
  endif
  return object#Lib#func#Call('eval', a:lmbd.__code__)
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
