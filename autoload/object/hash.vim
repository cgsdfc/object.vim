"
" Multiply 2 non-negative Numbers.
" Wrap overflowed product into 2-complement value.
"
function! object#hash#xmult(x, y)
  return object#hash#unsigned(a:x * a:y)
endfunction

"
" Return INT_WIDTH and INT_MAX in a |Dict|.
"
function! object#hash#nrinfo()
  return {
        \ 'width': s:INT_WIDTH,
        \ 'max': s:INT_MAX,
        \ }
endfunction

"
" The djb2 hash
"
function! object#hash#str_djb2(str)
  let hash = 5381
  let [i, N] = [0, len(a:str)]
  while i < N
    let c = a:str[i]
    let hash = xor(object#hash#xmult(hash, 33), c)
    let i += 1
  endwhile
  return hash
endfunction


if exists('*sha256')
  "
  " The sha256 hash
  "
  function! object#hash#str_sha256(str)
    " Since all Number of Vimscirpt is signed, we can only use
    " 31 bits which is 7 hex bits plus the inclusive slice of Vim.
    return str2nr(sha256(a:str)[: s:HEX_WIDTH-2], 16)
  endfunction

  function! object#hash#strhash(str)
    return object#hash#strhash_sha256(a:str)
  endfunction
else
  function! object#hash#strhash(str)
    return object#hash#strhash_djb2(a:str)
  endfunction
endif

"
" Wrap {nr} if it is negative. Since there is no unsigned
" type in Vim, the sign digit will be cut off when turning
" a negative signed number to an unsigned one. Thus, -1 will
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
function! object#hash#unsigned(nr)
  return a:nr >= 0 ? a:nr : s:INT_MAX + a:nr + 1
endfunction

if object#util#has_special_variables()
""
" @function hash(...)
" Return the hash value of {obj}.
"
" {obj} can be a |Number|, a |String| a |Funcref| or
" special variables like |v:none| and |v:false| (if present),
" or an object with __hash__() defined.
"
" @throws TypeError if hash() is not possible for {obj}.
" @throws WrongType if __hash__ is not a |Funcref| or returns
" something NAN (Not A Number).
  function! object#hash#hash(obj)
    if a:obj is# v:none || a:obj is# v:false || a:obj is# v:null
      return 0
    endif
    if a:obj is# v:true
      return 1
    endif
    return object#hash#hash_(a:obj)
  endfunction
else
  function! object#hash#hash(obj)
    return object#hash#hash_(a:obj)
  endfunction
endif

function! object#hash#hash_(obj)
  if object#builtin#IsNumber(a:obj)
    return object#hash#unsigned(a:obj)
  endif
  if object#builtin#IsString(a:obj)
    return object#hash#strhash(a:obj)
  endif
  if object#builtin#IsFuncref(a:obj)
    return object#hash#strhash(string(a:obj))
  endif
  if object#protocols#hasattr(a:obj, '__hash__')
    return object#builtin#CheckNumber(object#builtin#Call(a:obj.__hash__))
  endif
  call object#except#not_avail('hash', a:obj)
endfunction

