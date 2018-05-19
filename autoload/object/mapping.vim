" Any better way to guess the bitwidth of Number?
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
" Wrap overflowed product into 2-complement value
"
function! object#mapping#xmult(x, y)
  return object#mapping#unsigned(a:x * a:y)
endfunction

"
" Return info about Number.
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

function! object#mapping#strhash_sha256(str)
  " Since all Number of Vimscirpt is signed, we can only use
  " 31 bits which is 7 hex bits plus the inclusive slice of Vim.
    return str2nr(sha256(a:str)[: s:HEX_WIDTH-2], 16)
endfunction

if has('cryptv')
  function! object#mapping#strhash(str)
    return object#mapping#strhash_sha256(a:str)
  endfunction
else
  function! object#mapping#strhash(str)
    return object#mapping#strhash_djb2(a:str)
  endfunction
endif

"
" Return a none-negative number as hash value for {nr}.
function! object#mapping#unsigned(nr)
  return a:nr >= 0 ? a:nr : s:INT_MAX + a:nr
endfunction

""
" Return the hash value of {obj}.
function! object#mapping#hash(obj)
  if maktaba#value#IsNumber(a:obj)
    return object#mapping#unsigned(a:obj)
  endif
  if maktaba#value#IsString(a:obj)
    return object#mapping#strhash(a:obj)
  endif
  if maktaba#value#IsFuncref(a:obj)
    return object#mapping#strhash(string(a:obj))
  endif
  if a:obj is# v:none || a:obj is# v:false || a:obj is# v:null
    return 0
  endif
  if a:obj is# v:true
    return 1
  endif
  if object#protocols#hasattr(a:obj, '__hash__')
    return maktaba#ensure#IsNumber(a:obj.__hash__())
  endif
  throw object#TypeError('hash() not available for %s object',
        \ object#types#name(a:obj))
endfunction

""
" Return the value at {key} in {obj} as if {obj} is a mapping.
" If {obj} is a |List| or |Dict|, operator[] of Vim will be used.
function! object#mapping#getitem(obj, key)
  if maktaba#value#IsString(a:obj) || maktaba#value#IsList(a:obj)
    return a:obj[a:key]
  endif
  if maktaba#value#IsDict(a:obj)
    if !has_key(a:obj, '__getitem__')
      return a:obj[a:key]
    endif
    call maktaba#ensure#IsFuncref(a:obj.__getitem__)
    return a:obj.__getitem__(a:key)
  endif
  throw object#TypeError('getitem() not available for %s object',
        \ object#types#name(a:obj))
endfunction

""
" Set the value at {key} of {obj} to {value}.
" If {obj} is a |List| or |Dict|, let {obj}[{key}] = {value}
" will be used. Otherwise, __setitem__() of {obj} will be used.
function! object#mapping#setitem(obj, key, val)
  if maktaba#value#IsString(a:obj) || maktaba#value#IsList(a:obj)
    let a:obj[a:key] = a:val
    return
  endif
  if maktaba#value#IsDict(a:obj)
    if !has_key(a:obj, '__setitem__')
      let a:obj[a:key] = a:val
      return
    endif
    call maktaba#ensure#IsFuncref(a:obj.__setitem__)
    call a:obj.__setitem__(a:key, a:val)
    return
  endif
  throw object#TypeError('setitem() not available for %s object',
        \ object#types#name(a:obj))
endfunction
