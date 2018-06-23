let s:NumberInfo = object#builtin#NumberInfo()

" FUNCTION: xmult() {{{1
" Multiply 2 non-negative Numbers.
" Wrap overflowed product into 2-complement value.
function! object#hash#xmult(x, y)
  return object#hash#WrapNumber(a:x * a:y)
endfunction

" FUNCTION: strhash_djb2() {{{1
function! object#hash#strhash_djb2(str)
  let hash = 5381
  let [i, N] = [0, len(a:str)]
  while i < N
    let c = a:str[i]
    let hash = xor(object#hash#xmult(hash, 33), c)
    let i += 1
  endwhile
  return hash
endfunction

" FUNCTION: strhash_sha256() {{{1
function! object#hash#strhash_sha256(str)
  " Since all Number of Vimscirpt is signed, we can only use
  " 31 bits which is 7 hex bits plus the inclusive slice of Vim.
  return str2nr(sha256(a:str)[: s:NumberInfo.INT_HEX_WIDTH-2], 16)
endfunction

function! object#hash#strhash(str)
  return exists('*sha256') ? object#hash#strhash_sha256(a:str):
        \ object#hash#strhash_djb2(a:str)
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
function! object#hash#WrapNumber(nr)
  return a:nr >= 0 ? a:nr : s:NumberInfo.INT_MAX + a:nr + 1
endfunction

" FUNCTION: hash() {{{1
function! object#hash#hash(obj)
  let obj = object#hash#CheckHashable(a:obj)
  if object#builtin#IsBool(obj) || object#builtin#IsNone(obj)
    return !!obj
  endif
  if object#builtin#IsNumeric(obj)
    " Note: Float is hashed as Number.
    return object#hash#WrapNumber(float2nr(obj))
  endif
  if object#builtin#IsString(obj)
    return object#hash#strhash(obj)
  endif
  if object#protocol#HasProtocol(obj, '__hash__')
    return object#hash#CheckNumber(object#builtin#Call(obj.__hash__))
  endif
  return object#hash#strhash(string(obj))
endfunction

" FUNCTION: CheckNumber() {{{1
function! object#hash#CheckNumber(X)
  if object#builtin#IsNumber(a:X)
    return a:X
  endif
  call object#TypeError("__hash__ method should return an integer")
endfunction

" FUNCTION: CheckHashable() {{{1
function! object#hash#CheckHashable(X)
  if object#protocol#IsHashable(a:X)
    return a:X
  endif
  call object#TypeError("unhashable type: '%s',
        \ object#bulitin#TypeName(a:X))
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
