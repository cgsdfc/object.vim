" Handle built-in types, following the style of maktaba#value(ensure)
" but use Python's tone to report error :)

let s:typenames = [ "{{{1
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

let [s:Number,s:String,s:Funcref,s:List,s:Dict,s:Float,s:Boolean,s:None,s:Job,s:Channel]=range(10)

function! object#Lib#value#CheckX(func, nr, X, expected) abort "{{{1
  " Implement other Checks
  let actual = type(a:X)
  if actual == a:expected
    return a:X
  endif
  call object#TypeError('%s() argument %d must be %s, not %s',
        \ a:func, a:nr, s:typenames[a:expected], s:typenames[actual])
endfunction

function! object#Lib#value#CheckNumber(func, nr, X) abort "{{{1
  return object#Lib#value#CheckX(a:func, a:nr, a:X, s:Number)
endfunction

function! object#Lib#value#CheckNumeric(func, nr, X) abort "{{{1
  if object#Lib#value#IsNumeric(a:X)
    return a:X
  endif
  call object#TypeError('%s() argument %d must be numeric, not %s',
        \ a:func, a:nr, s:typenames[type(a:X)])
endfunction

function! object#Lib#value#CheckString(func, nr, X) abort "{{{1
  return object#Lib#value#CheckX(a:func, a:nr, a:X, s:String)
endfunction

function! object#Lib#value#CheckFloat(func, nr, X) abort "{{{1
  return object#Lib#value#CheckX(a:func, a:nr, a:X, s:Float)
endfunction

function! object#Lib#value#CheckList(func, nr, X) abort "{{{1
  return object#Lib#value#CheckX(a:func, a:nr, a:X, s:List)
endfunction

function! object#Lib#value#CheckDict(func, nr, X) abort "{{{1
  return object#Lib#value#CheckX(a:func, a:nr, a:X, s:Dict)
endfunction

function! object#Lib#value#CheckFuncref(func, nr, X) abort "{{{1
  return object#Lib#value#CheckX(a:func, a:nr, a:X, s:Funcref)
endfunction

function! object#Lib#value#CheckBool(func, nr, X) abort "{{{1
  if object#Lib#value#IsBool(a:X)
    return a:X
  endif
  call object#TypeError('%s() argument %d must be bool, not %s',
        \ a:func, a:nr, s:typenames[type(a:X)])
endfunction

function! object#Lib#value#CheckObj(func, nr, X) abort "{{{1
  let actual = type(a:X)
  if actual == s:Dict && has_key(a:X, '__class__')
    return a:X
  endif
  call object#TypeError('%s() argument %d must be object, not built-in %s',
        \ a:func, a:nr, s:typenames[actual])
endfunction

function! object#Lib#value#IsBool(X) abort "{{{1
  " By the convention of Vim, 0/1 are considered bool.
  " Note: `is` can avoid "can only compare Dict with Dict"
  return type(a:X) == s:Boolean || a:X is 0 || a:X is 1
endfunction

function! object#Lib#value#IsNumber(X) abort "{{{1
  return type(a:X) == s:Number
endfunction

function! object#Lib#value#IsFloat(X) abort "{{{1
  return type(a:X) == s:Float
endfunction

function! object#Lib#value#IsNumeric(X) abort "{{{1
  return  type(a:X) == s:Number || type(a:X) == s:Float
endfunction

function! object#Lib#value#IsList(X) abort "{{{1
  return type(a:X) == s:List
endfunction

function! object#Lib#value#IsDict(X) abort "{{{1
  return type(a:X) == s:Dict && !has_key(a:X, '__class__')
endfunction

function! object#Lib#value#IsString(X) abort "{{{1
  return type(a:X) == s:String
endfunction

function! object#Lib#value#IsFuncref(X) abort "{{{1
  return type(a:X) == s:Funcref
endfunction

function! object#Lib#value#IsNone(X) abort "{{{1
  return type(a:X) == s:None
endfunction

function! object#Lib#value#IsObj(X) abort "{{{1
  return type(a:X) == s:Dict && has_key(a:X, '__class__')
endfunction

function! object#Lib#value#IsClass(X) abort "{{{1
  return object#Lib#value#IsObj(a:X) && has_key(a:X, '__mro__')
endfunction

function! object#Lib#value#IsSequence(X) abort "{{{1
  return object#Lib#value#IsList(a:X) || object#Lib#value#IsString(a:X)
endfunction

function! object#Lib#value#IsContainer(X) abort "{{{1
  return object#Lib#value#IsList(a:X) ||
        \ (object#Lib#value#IsDict(a:X) && !has_key(a:X, '__class__'))
endfunction

function! object#Lib#value#TakeAtMostOptional(func, atmost, actual) abort "{{{1
  if a:atmost < a:actual
    call object#TypeError('%s() takes at most %d optional arguments (%d given)',
          \  a:func, a:atmost, a:actual)
  endif
endfunction

" Return typename of a built-in or object type.
function! object#Lib#value#TypeName(X) abort "{{{1
  if object#Lib#value#IsDict(a:X) && has_key(a:X, '__class__')
    return a:X.__class__.__name__
  endif
  return s:typenames[type(a:X)]
endfunction

" TODO: Move it to number.vim
" Alternative forms of type-check.
function! object#Lib#value#CheckNumber2(X) abort "{{{1
  if object#Lib#value#IsNumber(a:X)
    return a:X
  endif
  call object#TypeError("'%s' object cannot be interpreted as an integer",
        \ object#Lib#value#TypeName(a:X))
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
