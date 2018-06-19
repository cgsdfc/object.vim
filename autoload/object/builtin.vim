" Handle built-in types, following the style of maktaba#value(ensure)
" but use Python's tone to report error :)

" VARIABLE: built-in typenames and type codes. {{{1
let s:typenames = [
      \ 'int',
      \ 'str',
      \ 'function',
      \ 'list',
      \ 'dict',
      \ 'float',
      \ 'bool',
      \ 'NoneType',
      \ 'job',
      \ 'channel',
      \]

let [
      \ s:Number,
      \ s:String,
      \ s:Funcref,
      \ s:List,
      \ s:Dict,
      \ s:Float,
      \ s:Boolean,
      \ s:None,
      \ s:Job,
      \ s:Channel,
      \] = range(10)

" FUNCTION: CheckXXX() {{{1
function! object#builtin#CheckX(func, nr, X, code)
  let type = type(a:X)
  if type == a:code
    return a:X
  endif
  call object#TypeError('%s argument %d must be %s, not %s',
        \ s:typenames[type], s:typenames[a:code])
endfunction

function! object#builtin#CheckInt(func, nr, X)
  return object#builtin#CheckX(a:func, a:nr, a:X, s:Number)
endfunction

function! object#builtin#CheckString(func, nr, X)
  return object#builtin#CheckX(a:func, a:nr, a:X, s:String)
endfunction

function! object#builtin#CheckFloat(func, nr, X)
  return object#builtin#CheckX(a:func, a:nr, a:X, s:Float)
endfunction

function! object#builtin#CheckList(func, nr, X)
  return object#builtin#CheckX(a:func, a:nr, a:X, s:List)
endfunction

function! object#builtin#CheckDict(func, nr, X)
  return object#builtin#CheckX(a:func, a:nr, a:X, s:Dict)
endfunction

function! object#builtin#CheckFunc(func, nr, X)
  return object#builtin#CheckX(a:func, a:nr, a:X, s:Funcref)
endfunction

function! object#builtin#CheckBool(func, nr, X)
  let type = type(a:X)
  if type == s:Boolean || a:X is 0 || a:X is 1
    return a:X
  endif
  call object#TypeError('%s argument %d must be bool, not %s', s:typenames[type])
endfunction

" FUNCTION: IsXXX() {{{1
function! object#builtin#IsBool(X)
  return type(a:X) == s:Boolean || a:X is 0 || a:X is 1
endfunction

function! object#builtin#IsInt(X)
  return type(a:X) == s:Number
endfunction

function! object#builtin#IsFloat(X)
  return type(a:X) == s:Float
endfunction

function! object#builtin#IsList(X)
  return type(a:X) == s:List
endfunction

function! object#builtin#IsDict(X)
  return type(a:X) == s:Dict
endfunction

function! object#builtin#IsString(X)
  return type(a:X) == s:String
endfunction

function! object#builtin#IsFunc(X)
  return type(a:X) == s:Funcref
endfunction

" FUNCTION: Others {{{1
function! object#builtin#TakeAtMost(func, atmost, actual)
  if a:atmost < a:actual
    call object#TypeError('%s takes at most %d arguments (%d given)', a:func, a:atmost, a:actual)
  endif
endfunction

" FUNCTION: Return typename of a built-in or object type.
function! object#builtin#TypeName(X)
  if object#builtin#IsDict(a:X) && has_key(a:X, '__class__')
    return a:X.__class__.__name__
  endif
  return s:typename[type(a:X)]
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
