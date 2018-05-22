let s:identifier = '\v\C^[a-zA-Z_][a-zA-Z0-9_]*$'

function! object#util#ensure_argc(atmost, x)
  if a:x <= a:atmost
    return a:x
  endif
  throw object#TypeError('takes at most %d optional arguments (%d given)', a:atmost, a:x)
endfunction

function! object#util#ensure_identifier(x)
  if a:x =~# s:identifier
    return a:x
  endif
  throw object#ValueError('%s is not an identifier', string(a:x))
endfunction

" Helper to be used in __setattr__ to indicate that all the attributes
" are readonly.
" Examples:
" >
"   let s:cls.__setattr__ = function('object#util#readonly_setattr')
" <
"
" @throws AttributeError
function! object#util#readonly_setattr(name, unused_val) dict
  if !has_key(self, a:name)
    call object#except#throw_noattr(self, a:name)
  endif
  call object#except#throw_readonly_attr(self, a:name)
endfunction

" Helper to be used in __dir__ to filter out some attributes
" that should be invisible to object#dir().
" Examples:
" >
"   let cls.__dir__ = function('object#util#hiding_dir', [s:private])
" <
function! object#util#hiding_dir(pattern) dict
  return filter(keys(self), 'v:val !~# ' . string(a:pattern))
endfunction

" Helper to be used in __getattr__ to hide some attributes from being
" getattr()'ed.
"
" Examples:
" >
"   let cls.__getattr__ = function('object#util#hiding_getattr', [s:private])
" <
" @throws AttributeError
function! object#util#hiding_getattr(pattern, name) dict
  if !has_key(self, a:name) || a:name =~# a:pattern
    call object#except#throw_noattr(self, a:name)
  endif
  return self[a:name]
endfunction
