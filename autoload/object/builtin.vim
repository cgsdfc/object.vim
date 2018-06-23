" Handle built-in types, following the style of maktaba#value(ensure)
" but use Python's tone to report error :)

" VARIABLE: Builtin type names and type codes. {{{1
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

let [ s:Number, s:String, s:Funcref, s:List, s:Dict, s:Float, s:Boolean, s:None, s:Job, s:Channel ] = range(10)

" FUNCTION: CheckXXX() {{{1
function! object#builtin#CheckX(func, nr, X, expected)
  let actual = type(a:X)
  if actual == a:expected
    return a:X
  endif
  call object#TypeError('%s() argument %d must be %s, not %s',
        \ a:func, a:nr, s:typenames[a:expected], s:typenames[actual])
endfunction

function! object#builtin#CheckNumber(func, nr, X)
  return object#builtin#CheckX(a:func, a:nr, a:X, s:Number)
endfunction

function! object#builtin#CheckNumeric(func, nr, X)
  if object#builtin#IsNumeric(a:X)
    return a:X
  endif
  call object#TypeError('%s() argument %d must be numeric, not %s',
        \ a:func, a:nr, s:typenames[type(a:X)])
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
  if object#builtin#IsBool(a:X)
    return a:X
  endif
  call object#TypeError('%s() argument %d must be bool, not %s',
        \ a:func, a:nr, s:typenames[type(a:X)])
endfunction

function! object#builtin#CheckObj(func, nr, X)
  let actual = type(a:X)
  if actual == s:Dict && has_key(a:X, '__class__')
    return a:X
  endif
  call object#TypeError('%s() argument %d must be object, not built-in %s',
        \ a:func, a:nr, s:typenames[actual])
endfunction

" FUNCTION: IsXXX() {{{1
" By the good convention of Vim, 0/1 are considered bool.
function! object#builtin#IsBool(X)
  " Note: `is` can avoid "can only compare Dict with Dict"
  return type(a:X) == s:Boolean || a:X is 0 || a:X is 1
endfunction

function! object#builtin#IsNumeric(X)
  return type(a:X) == s:Number || type(a:X) == s:Float
endfunction

function! object#builtin#IsNumber(X)
  return type(a:X) == s:Number
endfunction

function! object#builtin#IsFloat(X)
  return type(a:X) == s:Float
endfunction

function! object#builtin#IsNumeric(X)
  let type = type(a:X)
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

function! object#builtin#IsNone(X)
  return type(a:X) == s:None
endfunction

function! object#builtin#IsObj(X)
  return type(a:X) == s:Dict && has_key(a:X, '__class__')
endfunction

function! object#builtin#IsClass(X)
  return object#builtin#IsObj(a:X) && has_key(a:X, '__mro__')
endfunction

function! object#builtin#IsSequence(X)
  return object#builtin#IsList(a:X) || object#builtin#IsString(a:X)
endfunction

function! object#builtin#IsContainer(X)
  return object#builtin#IsList(a:X) ||
        \ (object#builtin#IsDict(a:X) && !has_key(a:X, '__class__'))
endfunction

" FUNCTION: TakeAtMostOptional() {{{1
function! object#builtin#TakeAtMostOptional(func, atmost, actual)
  if a:atmost < a:actual
    call object#TypeError('%s() takes at most %d optional arguments (%d given)',
          \  a:func, a:atmost, a:actual)
  endif
endfunction

" FUNCTION: TypeName() {{{1
" Return typename of a built-in or object type.
function! object#builtin#TypeName(X)
  if object#builtin#IsDict(a:X) && has_key(a:X, '__class__')
    return a:X.__class__.__name__
  endif
  return s:typenames[type(a:X)]
endfunction

" FUNCTION: Call() {{{1
function! object#builtin#Call(X, ...)
  return object#builtin#Call_(a:X, a:000)
endfunction

" FUNCTION: Call_()  {{{1
" Only accept Funcref
function! object#builtin#Call_(X, args)
  " Should we need a catch-all to throw something like:
  " 'Unrecognized Vim Error'? No, not at all.
  " - If it is a user exception, just let it go.
  " - If it is an unrecognized exception, just let it out, it
  "   will be added here after all.
  " We use Exxx to recognize VimError, but what if we end up
  " match what we produced since for user's benefits we enclose
  " the error code in it?
  " We should match a unique pattern that only Vim should throw.
  if !object#builtin#IsFuncref(a:X)
    call object#TypeError("'%s' object is not callable",
          \ object#builtin#TypeName(a:X))
  endif
  return object#builtin#CallStringFuncref_(a:X, a:args)
endfunction

" FUNCTION: CallStringFuncref() {{{1
function! object#builtin#CallStringFuncref(X, ...)
  return object#builtin#CallStringFuncref_(X, a:000)
endfunction

" FUNCTION: CallStringFuncref_() {{{1
" Accept both Funcref and String.
function! object#builtin#CallStringFuncref_(X, args)
  try
    let Val = call(a:X, a:args)
  catch 'E118:\|E119:'
    " E118: Too many or not enough args.
    " E119: Too many or not enough args.
    call object#TypeError(object#builtin#ReOrderVimError(v:exception))
  catch 'E117:\|E121:'
    " E117: Unknown function.
    " E121: Undefined variables.
    " NOTE: Unknown function can also be caused by
    " using something non-callable, which is actually
    " TypeError.
    " However, the word "Unknown" makes it very like
    " an undefined name.
    call object#NameError(object#builtin#ReOrderVimError(v:exception))
  catch 'E488:'
    " E488: Trailing characters
    call object#SyntaxError(object#builtin#ReOrderVimError(v:exception))
  catch 'E713:\|E716:\|E717'
    " E716: Key not present
    call object#KeyError(object#builtin#ReOrderVimError(v:exception))
  catch 'E684:'
    " index out of range.
    call object#IndexError(object#builtin#ReOrderVimError(v:exception))
  catch 'E741:'
    " lockvar
    call object#RuntimeError(object#builtin#ReOrderVimError(v:exception))
  catch 'E\d\+:'
    call object#VimError(object#builtin#ReOrderVimError(v:exception))
  endtry
  return Val
endfunction

" FUNCTION: ReOrderVimError() {{{1
" Prettify v:exception.
" >
"   Vim(let): E111: something bad happened
"   becomes
"   something bad happens (E111)
" <
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
" TODO: Is there a better name for it? It sounds very like an exception.
function! object#builtin#ReOrderVimError(error)
  let list = matchlist(a:error, '\V\C\^\.\*\(E\d\+\): \(\.\+\)\$')
  if empty(list)
    return a:error
  endif
  return printf('%s (%s)', list[2], list[1])
endfunction

" FUNCTION: CheckXXX2() {{{1
" Alternative forms of type-check.
function! object#builtin#CheckNumber2(X)
  if object#builtin#IsNumber(a:X)
    return a:X
  endif
  call object#TypeError("'%s' object cannot be interpreted as an integer",
        \ object#builtin#TypeName(a:X))
endfunction

" FUNCTION: NumberInfo() {{{1
" Return a dictionary where limits and width of Number are defined.
let s:number_info = {
      \ 'INT_MAX': 1/0,
      \ 'INT_MIN': 0/0,
      \ 'INT_HEX_WIDTH': len(printf('%x', 1/0)),
      \ }

function! object#builtin#NumberInfo()
  return s:number_info
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
