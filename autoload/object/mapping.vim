""
" @section Mapping, mapping
" An interface to key-value containers.
" A mapping is an object that supports accessing its values through a set of
" keys or in short, the subscription operator. The built-in |String|, |Dict|
" and |List| can all be viewed as mapping. This idea is generalized by the
" functions provided.
"
" Features:
"   * Hookable hash() works for built-in types.
"   * Hookable getitem() and setitem() functions works built in types.


" Any better way to guess the bitwidth of Number?
" TODO: Add performance test for the strhash().
" TODO: delitem()
" TODO: Check for OverflowError for hash(int).


let s:INT32_MAX = 2147483647
let s:INT64_MAX = 9223372036854775807

if s:INT64_MAX > 0
  let s:INT_WIDTH = 64
  let s:INT_MAX = s:INT64_MAX
else
  let s:INT_WIDTH = 32
  let s:INT_MAX = s:INT32_MAX
endif

let s:HEX_WIDTH = s:INT_WIDTH / 4

"
" Multiply 2 non-negative Numbers.
" Wrap overflowed product into 2-complement value.
"
function! object#mapping#xmult(x, y)
  return object#mapping#unsigned(a:x * a:y)
endfunction

"
" Return INT_WIDTH and INT_MAX in a |Dict|.
"
function! object#mapping#nrinfo()
  return {
        \ 'width': s:INT_WIDTH,
        \ 'max': s:INT_MAX,
        \ }
endfunction

"
" The djb2 hash
"
function! object#mapping#strhash_djb2(str)
  let hash = 5381
  let [i, N] = [0, len(a:str)]
  while i < N
    let c = a:str[i]
    let hash = xor(object#mapping#xmult(hash, 33), c)
    let i += 1
  endwhile
  return hash
endfunction


if has('cryptv')
  "
  " The sha256 hash
  "
  function! object#mapping#strhash_sha256(str)
    " Since all Number of Vimscirpt is signed, we can only use
    " 31 bits which is 7 hex bits plus the inclusive slice of Vim.
    return str2nr(sha256(a:str)[: s:HEX_WIDTH-2], 16)
  endfunction

  function! object#mapping#strhash(str)
    return object#mapping#strhash_sha256(a:str)
  endfunction
else
  function! object#mapping#strhash(str)
    return object#mapping#strhash_djb2(a:str)
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
function! object#mapping#unsigned(nr)
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
  function! object#mapping#hash(obj)
    if a:obj is# v:none || a:obj is# v:false || a:obj is# v:null
      return 0
    endif
    if a:obj is# v:true
      return 1
    endif
    return object#mapping#hash_(a:obj)
  endfunction
else
  function! object#mapping#hash(obj)
    return object#mapping#hash_(a:obj)
  endfunction
endif

function! object#mapping#hash_(obj)
  if maktaba#value#IsNumber(a:obj)
    return object#mapping#unsigned(a:obj)
  endif
  if maktaba#value#IsString(a:obj)
    return object#mapping#strhash(a:obj)
  endif
  if maktaba#value#IsFuncref(a:obj)
    return object#mapping#strhash(string(a:obj))
  endif
  if object#protocols#hasattr(a:obj, '__hash__')
    return maktaba#ensure#IsNumber(object#protocols#call(a:obj.__hash__))
  endif
  call object#except#not_avail('hash', a:obj)
endfunction

""
" @function getitem(...)
" Return the value at {key} in {obj} as if {obj} is a mapping.
" >
"   getitem(obj, key) -> obj[key]
" <
" If {obj} is a |List|, |String| or plain |Dict|, checked-version
" of built-in subscription will be called.
" Vim error about |List| index will translate to @exception(IndexError).
" Vim's ignorance about the index to |String| will be augmented by checking
" the emptiness of the value.
"
" @throws WrongType if {obj} is a |String| or |List| but {key} is not a
" |Number| or {obj} is a |Dict| but {key} is not a |String|.
"
" @throws IndexError if {key} is out of range for |String| or |List|.
" @throws KeyError if {key} is not present in the |Dict|.
function! object#mapping#getitem(obj, key)
  if maktaba#value#IsList(a:obj)
    try
      let val = a:obj[maktaba#ensure#IsNumber(a:key)]
    catch /E684/
      throw object#IndexError('list index out of range: %d', a:key)
    endtry
    return val
  endif

  if maktaba#value#IsString(a:obj)
    let val = a:obj[maktaba#ensure#IsNumber(a:key)]
    if val isnot# ''
      return val
    endif
    throw object#IndexError('string index out of range: %d', a:key)
  endif

  if maktaba#value#IsDict(a:obj)
    if has_key(a:obj, '__getitem__')
      return object#protocols#call(a:obj.__getitem__, a:key)
    endif
    try
      let val = a:obj[maktaba#ensure#IsString(a:key)]
    catch /E716/
      throw object#KeyError('key not present in dictionary: %s', string(a:key))
    endtry
    return val
  endif

  call object#except#not_avail('getitem', a:obj)
endfunction

""
" @function setitem(...)
" Set the value at {key} of {obj} to {val}.
" >
"   setitem(obj, key, val) -> let obj[key] = val
" <
" If {obj} is a |List|, |String| or a |Dict|,
" subscription version of |let| will be uesd.
" Otherwise, __setitem__ of {obj} will be used.
function! object#mapping#setitem(obj, key, val)
  if maktaba#value#IsList(a:obj)
    try
      let a:obj[maktaba#ensure#IsNumber(a:key)] = a:val
      return
    catch /E684/
      throw object#IndexError('list index out of range: %d', a:key)
    endtry
  endif

  if maktaba#value#IsDict(a:obj)
    if has_key(a:obj, '__setitem__')
      call object#protocols#call(a:obj.__setitem__, a:key, a:val)
    else
      let a:obj[maktaba#ensure#IsString(a:key)] = a:val
    endif
    return
  endif

  " String does not support setitem()
  call object#except#not_avail('setitem', a:obj)
endfunction
