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


" FUNCTION: HashFuncref() {{{1
" Funcrefs are hashed by their name. As the
" comparison of Funcrefs does, partials of function
" with the same name are equal.
" Keeping with the builtin operator makes the result
" less surprising. Consider MyClass derives from object
" the `__init__()` method and for the two __init__, although
" they have different dict, they still compare equal, and their
" hash should be equal.
function! object#proto#hash#HashFuncref(funcref)
  return object#proto#hash#HashString(object#builtin#FuncName(a:funcref))
endfunction

" FUNCTION: HashNumber() {{{1
function! object#proto#hash#HashNumber(number)
  " Since currently we don't have arbitrary large integer,
  " the hash is just the very beginning of the long_hash().
  return a:number == -1 ? -2 : a:number
endfunction

" FUNCTION: HashFloat() {{{1
function! object#proto#hash#HashFloat(float)
  return 0
endfunction

" FUNCTION: HashJob() {{{1
function! object#proto#hash#HashJob(job)
  return 0
endfunction

" FUNCTION: xmult() {{{1
" Multiply 2 non-negative Numbers.
" Wrap overflowed product into 2-complement value.
function! object#proto#hash#xmult(x, y)
  return object#proto#hash#WrapNumber(a:x * a:y)
endfunction

" FUNCTION: strhash_djb2() {{{1
function! object#proto#hash#strhash_djb2(str)
  let hash = 5381
  let [i, N] = [0, len(a:str)]
  while i < N
    let c = a:str[i]
    let hash = xor(hash * 33, c)
    let i += 1
  endwhile
  return hash
endfunction

" FUNCTION: strhash_sha256() {{{1
function! object#proto#hash#strhash_sha256(str)
  " Since all Number of Vimscirpt is signed, we can only use
  " 31 bits which is 7 hex bits plus the inclusive slice of Vim.
  return str2nr(sha256(a:str)[: s:NumberInfo.INT_HEX_WIDTH-2], 16)
endfunction

" FUNCTION: HashString() {{{1
function! object#proto#hash#HashString(str)
  return exists('*sha256') ? object#proto#hash#strhash_sha256(a:str):
        \ object#proto#hash#strhash_djb2(a:str)
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
function! object#proto#hash#WrapNumber(nr)
  return a:nr >= 0 ? a:nr : s:NumberInfo.INT_MAX + a:nr + 1
endfunction

" FUNCTION: hash() {{{1
function! object#proto#hash#hash(obj)
  let obj = object#proto#hash#CheckHashable(a:obj)
  if object#builtin#IsBool(obj) || object#builtin#IsNone(obj)
    return !!obj
  endif
  if object#builtin#IsNumber(obj)
    return object#proto#hash#HashNumber(obj)
  endif
  if object#builtin#IsFloat(obj)
    return object#proto#hash#HashFloat(obj)
  endif
  if object#builtin#IsFuncref(obj)
    return object#proto#hash#HashFuncref(obj)
  endif
  if object#builtin#IsString(obj)
    return object#proto#hash#HashString(obj)
  endif
  if object#proto#HasMethod(obj, '__hash__')
    return object#proto#hash#CheckNumber(object#builtin#CallFuncref(obj.__hash__))
  endif
  return object#proto#hash#HashOther(obj)
endfunction

" FUNCTION: CheckNumber() {{{1
function! object#proto#hash#CheckNumber(X)
  if object#builtin#IsNumber(a:X)
    return a:X
  endif
  call object#TypeError("__hash__ method should return an integer")
endfunction

" FUNCTION: CheckHashable() {{{1
function! object#proto#hash#CheckHashable(X)
  if object#proto#IsHashable(a:X)
    return a:X
  endif
  call object#TypeError("unhashable type: '%s',
        \ object#bulitin#TypeName(a:X))
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
