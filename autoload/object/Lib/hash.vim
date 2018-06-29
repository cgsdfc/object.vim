let s:config = object#Lib#config#Get()

" TODO: Use more real-life hashing strategy.
" Referencing Python3 is a good starting point
" but it is a too serious piece of C code that
" I'd like to leave to the next iteration.
" For now just patch hash() so that it gives
" well-defined results for any object.
" let s:NumberInfo = object#builtin#NumberInfo()
" if s:NumberInfo.INT_HEX_WIDTH == 16
"   let s:PyHASH_BITS = 61
" else
"   let s:PyHASH_BITS = 31
" endif
" let s:PyHASH_INF = 31
" let s:PyHASH_NAN = 0
" let s:PyHASH_MODULUS = s:NumberInfo.INT_MAX


" Funcrefs are hashed by their name. As the
" comparison of Funcrefs does, partials of function
" with the same name are equal.
" Keeping with the builtin operator makes the result
" less surprising. Consider MyClass derives from object
" the `__init__()` method and for the two __init__, although
" they have different dict, they still compare equal, and their
" hash should be equal.
function! object#Lib#hash#HashFuncref(funcref) abort "{{{1
  return object#Lib#hash#HashString(object#Lib#func#FuncName(a:funcref))
endfunction

function! object#Lib#hash#HashNumber(number) abort "{{{1
  " Since currently we don't have arbitrary large integer,
  " the hash is just the very beginning of the long_hash().
  return a:number == -1 ? -2 : a:number
endfunction

function! object#Lib#hash#HashFloat(float) abort "{{{1
  return 0
endfunction

function! object#Lib#hash#HashJob(job) abort "{{{1
  return 0
endfunction

" Multiply 2 non-negative Numbers.
" Wrap overflowed product into 2-complement value.
function! object#Lib#hash#xmult(x, y) abort "{{{1
  return object#Lib#hash#WrapNumber(a:x * a:y)
endfunction

function! object#Lib#hash#Hash_DJB2(str) abort "{{{1
  let hash = 5381
  let [i, N] = [0, len(a:str)]
  while i < N
    let c = a:str[i]
    let hash = xor(hash * 33, c)
    let i += 1
  endwhile
  return hash
endfunction

function! object#Lib#hash#Hash_SHA256(str) abort "{{{1
  " Since all Number of Vimscirpt is signed, we can only use
  " 31 bits which is 7 hex bits plus the inclusive slice of Vim.
  return str2nr(sha256(a:str)[: s:NumberInfo.INT_HEX_WIDTH-2], 16)
endfunction

function! object#Lib#hash#HashString(str) abort "{{{1
  return  s:config.HAS_SHA256 ? object#Lib#hash#Hash_SHA256(a:str):
        \ object#Lib#hash#Hash_DJB2(a:str)
endfunction

"
" Wrap {nr} if it is negative. Since there is no WrapNumber
" type in Vim, the sign digit will be cut off when turning
" a negative signed number to an WrapNumber one. Thus, -1 will
" be turned into INT_MAX but not UINT_MAX (if present).
" TODO: watch out for OverflowError when {nr} is INT_MIN
" This algorithm is clever enough so that INT_MIN -> 0.
" Since there is one more negative number than positive ones,
" it uses zero to fill the hole. However, I still wonder if abs()
" is better than wrapping around.
" >
"   nr >= 0 ? nr : -(nr+1)
" <
" OverflowError appears when -0/0 is supposed to be positive, but
" in fact is 0/0. (0/0 is INT_MIN).
function! object#Lib#hash#WrapNumber(nr) abort "{{{1
  return a:nr >= 0 ? a:nr : s:NumberInfo.INT_MAX + a:nr + 1
endfunction

function! object#Lib#hash#hash(obj) abort "{{{1
  let obj = object#Lib#hash#CheckHashable(a:obj)
  if object#Lib#value#IsBool(obj) || object#Lib#value#IsNone(obj)
    return !!obj
  endif
  if object#Lib#value#IsNumber(obj)
    return object#Lib#hash#HashNumber(obj)
  endif
  if object#Lib#value#IsFloat(obj)
    return object#Lib#hash#HashFloat(obj)
  endif
  if object#Lib#value#IsFuncref(obj)
    return object#Lib#hash#HashFuncref(obj)
  endif
  if object#Lib#value#IsString(obj)
    return object#Lib#hash#HashString(obj)
  endif
  if object#Lib#proto#HasProtocol(obj, '__hash__')
    return object#Lib#hash#CheckNumber(object#Lib#func#CallFuncref(obj.__hash__))
  endif
  if object#Lib#type#IsType(obj)
    return object#Lib#hash#CheckNumber(
          \ object#Lib#func#CallClassMethod(obj, '__hash__'))
  endif
endfunction

function! object#Lib#hash#CheckNumber(X) abort "{{{1
  if object#Lib#value#IsNumber(a:X)
    return a:X
  endif
  call object#TypeError("__hash__ method should return an integer")
endfunction

function! object#Lib#hash#CheckHashable(X) abort "{{{1
  if object#Lib#IsHashable(a:X)
    return a:X
  endif
  call object#TypeError("unhashable type: '%s',
        \ object#bulitin#TypeName(a:X))
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
