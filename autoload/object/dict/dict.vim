" CLASS: dict
call object#class#builtin_class('dict', object#object_(), s:)

""
" @function _dict(...)
" Create a dict object. See @function(dict).
function! object#dict#_dict(...)
  return object#new_(s:dict, a:000)
endfunction

""
" @function dict_()
" Return the dict type.
function! object#dict#dict_()
  return s:dict
endfunction

" CLASS: dict {{{1
let s:dict = object#class('dict')

""
" @dict dict
" Initialize a dict with [args].
" See @function(object#dict#dict) for signature.
function! s:dict.__init__(...)
  let self._dict = call('object#dict', a:000)
endfunction

""
" @dict dict
" Representation of a dict.
function! s:dict.__repr__()
  return object#dict#repr(self._dict)
endfunction

""
" @dict dict
" Test for emptiness of the dict.
function! s:dict.__bool__()
  return object#bool(self._dict)
endfunction

""
" @dict dict
" Get an item from the dict.
" If {key} is not present but the subclass of dict defines a `__missing__`
" method, return or throw whatever it returns or throws. `__missing__` must
" be a method.
"
" @throws KeyError if {key} is not present.
" @throws WrongType if `__missing__` is not a |Funcref|.
function! s:dict.__getitem__(Key)
  try
    return object#getitem(self._dict, a:Key)
  catch /KeyError/
    if has_key(self, '__missing__')
      return maktaba#ensure#IsFuncref(self.__missing__)(a:Key)
    endif
    throw v:exception
  endtry
endfunction

""
" @dict dict
" Set value for a dict item.
function! s:dict.__setitem__(Idx, Val)
  return object#setitem(self._dict, a:Idx, a:Val)
endfunction

""
" @dict dict
" Test whether {key} is in dict.
function! s:dict.__contains__(Key)
  return object#contains(a:Key, self._dict)
endfunction

""
" @dict dict
" Return the length of the dict.
function! s:dict.__len__()
  return object#len(self._dict)
endfunction

""
" @dict dict
" Remove all items from the dict.
function! s:dict.clear()
  if empty(self._dict)
    return
  endif
  let self._dict = {}
endfunction

""
" @dict dict
" Return a shallow copy of the dict object.
function! s:dict.copy()
  " Effectively call object#dict(self._dict), which
  " shallow-copy the |Dict|.
  return object#new(s:dict, self._dict)
endfunction

""
" @dict dict
" Get a value from the dict and fall back on [default].
" @throws KeyError if the {key} is not present and no [default] is given.
function! s:dict.get(Key, ...)
  call object#util#ensure_argc(1, a:0)
  try
    return object#getitem(self._dict, a:Key)
  catch /KeyError/
    if a:0 == 1
      return a:1
    endif
    throw v:exception
  endtry
endfunction

""
" @dict dict
" Return a list of 2-lists for the items of the dict.
function! s:dict.items()
  return items(self._dict)
endfunction

""
" @dict dict
" Return a list from the values of the dict.
function! s:dict.values()
  return values(self._dict)
endfunction

""
" @dict dict
" Return a list from the keys of the dict.
function! s:dict.keys()
  return keys(self._dict)
endfunction

""
" @dict dict
" Get and set {default} for the {key}.
function! s:dict.setdefault(Key, Default)
  try
    return object#getitem(self._dict, a:Key)
  catch /KeyError/
    call object#setitem(self._dict, a:Key, a:Default)
    return a:Default
  endtry
endfunction

""
" @dict dict
" Extend the dict with a [dict_like] object.
"
" If an optional [flag] is given, it should be one of
" 'keep', 'force' and 'error', which will be passed to built-in
" |extend()|.
function! s:dict.extend(Dict_like, ...)
  call object#util#ensure_argc(1, a:0)
  let d = object#dict(a:Dict_like)
  if a:0 == 0
    call extend(self._dict, d)
    return
  endif

  try
    call extend(self._dict, d, maktaba#ensure#IsString(a:1))
  catch /E475/
    throw object#ValueError('bad flag %s', string(a:1))
  catch /E737/
    throw object#KeyError("key already exists '%s'",
          \ substitute(v:exception, '\v\C^.*: (.*)$', '\1', 'g'))
  endtry
endfunction

""
" @dict dict
" Test whether self has {Key}.
function! s:dict.has_key(Key)
  return self.__contains__(a:Key)
endfunction

""
" @dict dict
" Remove the specified {key} and return the corresponding value.
" If {key} is not found, [default] is returned if given,
" otherwise KeyError if thrown.
function! s:dict.pop(Key, ...)
  call object#util#ensure_argc(1, a:0)
  try
    let val = object#getitem(self._dict, a:Key)
  catch /KeyError/
    if a:0 == 1
      return a:1
    endif
    throw v:exception
  endtry
  unlet self._dict[a:Key]
  return val
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
