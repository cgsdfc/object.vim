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
  call object#TypeError('%s() argument %d must be %s, not %s',
        \ s:typenames[type], s:typenames[a:code])
endfunction

function! object#builtin#CheckNumber(func, nr, X)
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

function! object#builtin#CheckFuncref(func, nr, X)
  return object#builtin#CheckX(a:func, a:nr, a:X, s:Funcref)
endfunction

function! object#builtin#CheckBool(func, nr, X)
  let type = type(a:X)
  if type == s:Boolean || a:X is 0 || a:X is 1
    return a:X
  endif
  call object#TypeError('%s() argument %d must be bool, not %s',
        \ a:func, s:typenames[type])
endfunction

function! object#builtin#CheckObj(func, nr, X)
  let type = type(a:X)
  if type == s:Dict && has_key(a:X, '__class__')
    return a:X
  endif
  call object#TypeError('%s() argument %d must be object, not %s',
        \ a:func, s:typenames[type])
endfunction

" FUNCTION: IsXXX() {{{1
function! object#builtin#IsBool(X)
  " TODO: True and False object is bool.
  return type(a:X) == s:Boolean || a:X is 0 || a:X is 1
endfunction

function! object#builtin#IsNumber(X)
  return type(a:X) == s:Number
endfunction

function! object#builtin#IsFloat(X)
  return type(a:X) == s:Float
endfunction

function! object#builtin#IsNumeric(X)
  len type = type(a:X) 
  return  type == s:Number || type == s:Float
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

function! object#builtin#IsFuncref(X)
  return type(a:X) == s:Funcref
endfunction

function! object#builtin#IsObj(X)
  return type(a:X) == s:Dict && has_key(a:X, '__class__')
endfunction

" FUNCTION: Others {{{1
function! object#builtin#TakeAtMostOptional(func, atmost, actual)
  if a:atmost < a:actual
    call object#TypeError('%s() takes at most %d optional arguments (%d given)',
          \  a:func, a:atmost, a:actual)
  endif
endfunction

" FUNCTION: Return typename of a built-in or object type.
function! object#builtin#TypeName(X)
  if object#builtin#IsDict(a:X) && has_key(a:X, '__class__')
    return a:X.__class__.__name__
  endif
  return s:typename[type(a:X)]
endfunction

" FUNCTION: Call a protocol methods. {{{1
" Translate Vim error to Python-style error.
" Since X is meant to be user-defined functions, some error thrown by
" built-in functions are not caught.
" >
"   call object#builtin#CallProtocolMethod(obj.__init__, a:000)
"   return object#builtin#CallProtocolMethodVarargs(obj.__len__)
" <
function! object#builtin#CallProtocolMethod(X, args)
  try
    let Val = call(a:X, a:args)
  catch /E117/
    call object#TypeError("'%s' object is not callable",
          \ object#builtin#TypeName(a:X))
  catch /E118\|E119/ " Too many or not enough args.
    call object#TypeError(v:exception)
  catch /E699/ " args > 20
    call object#TypeError('maximum number of arguments exceeded')
  endtry
  return Val
endfunction

function! object#builtin#CallProtocolMethodVarargs(X, ...)
  return object#builtin#CallProtocolMethod(a:X, a:000)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
