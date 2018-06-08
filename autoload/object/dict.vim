""
" @dict dict
" A wrapper class of built-in |Dict|.

let s:dict = object#type('dict', [], {
      \ '__init__': function('object#dict#__init__'),
      \ '__len__': function('object#dict#__len__'),
      \ '__repr__': function('object#dict#__repr__'),
      \ '__bool__': function('object#dict#__bool__'),
      \ '__getitem__': function('object#dict#__getitem__'),
      \ '__setitem__': function('object#dict#__setitem__'),
      \ '__contains__': function('object#dict#__contains__'),
      \ 'clear': function('object#list#clear'),
      \ 'copy': function('object#list#copy'),
      \ 'get': function('object#list#get'),
      \ 'items': function('object#list#items'),
      \ 'keys': function('object#list#keys'),
      \ 'pop': function('object#list#pop'),
      \ 'setdefault': function('object#list#setdefault'),
      \ 'extend': function('object#list#extend'),
      \ 'values': function('object#list#values'),
      \})

""
" Return the dict type.
function! object#dict#dict_()
  return s:dict
endfunction

""
" @dict dict
" Initialize a dict with [args], which can be:
"   * a plain |Dict| -> copy args.
"   * a @dict(dict) object -> copy underlying |Dict|.
"   * an iterable -> fill with 2-lists item.
"   * an iterable and a |String| -> fill with map(iterable, string).
function! object#dict#__init__(...) dict
  let self._dict = call('object#dict', a:000)
endfunction

""
" @dict dict
" Representation of a dict.
function! object#dict#__repr__() dict
  return object#repr(self._dict)
endfunction

""
" @dict dict
" Test for emptiness of the dict.
function! object#dict#__bool__() dict
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
function! object#dict#__getitem__(key) dict
  try
    return object#getitem(self._dict, a:key)
  catch /KeyError/
    if has_key(self, '__missing__')
      return maktaba#ensure#IsFuncref(self.__missing__)(a:key)
    endif
    throw v:exception
  endtry
endfunction

""
" @dict dict
" Set value for a dict item.
function! object#dict#__setitem__(idx, val) dict
  return object#setitem(self._dict, a:idx, a:val)
endfunction

""
" @dict dict
" Test whether {key} is in dict.
function! object#dict#__contains__(key) dict
  return object#contains(self._dict, a:key)
endfunction

""
" @dict dict
" Return the length of the dict.
function! object#dict#__len__() dict
  return object#len(self._dict)
endfunction

""
" @dict dict
" Remove all items from the dict.
function! object#dict#clear() dict
  let self._dict = {}
endfunction

""
" @dict dict
" Return a shallow copy of the dict object.
function! object#dict#copy() dict
  " Effectively call object#dict(self._dict), which
  " shallow-copy the |Dict|.
  return object#new(s:dict, self._dict)
endfunction

"""
"" @dict dict
"function! object#dict#fromkeys(iterable, ...)
"  call object#util#ensure_argc(1, a:0)
"  let value = a:0 == 1? a:1 : object#None()

""
" @dict dict
" Get a value from the dict and fall back on [default].
" @throws KeyError if the {key} is not present and no [default] is given.
function! object#dict#get(key, ...) dict
  call object#util#ensure_argc(1, a:0)
  try
    return object#getitem(self._dict, a:key)
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
function! object#dict#items() dict
  return items(self._dict)
endfunction

""
" @dict dict
" Return a list from the values of the dict.
function! object#dict#values() dict
  return values(self._dict)
endfunction

""
" @dict dict
" Return a list from the keys of the dict.
function! object#dict#keys() dict
  return keys(self._dict)
endfunction

""
" @dict dict
" Get and set {default} for the {key}.
function! object#dict#setdefault(key, default) dict
  try
    return object#getitem(self._dict, a:key)
  catch /KeyError/
    call object#setitem(self._dict, a:key, a:default)
    return a:default
  endtry
endfunction

""
" @dict dict
" Remove the specified {key} and return the corresponding value.
" If {key} is not found, [default] is returned if given,
" otherwise KeyError if thrown.
function! object#dict#pop(key, ...)
  call object#util#ensure_argc(1, a:0)
  try
    let val = object#getitem(self._dict, a:key)
  catch /KeyError/
    if a:0 == 1
      return a:1
    endif
    throw v:exception
  endtry
  unlet self._dict[a:key]
  return val
endfunction

""
" @dict dict
" Extend the dict with a [dict_like] object, which can be
" a @dict(dict) object, a plain |Dict| or an iterable
" that yields 2-lists.
" If an optional [flag] is given, it should be one of
" 'keep', 'force' and 'error', which will be passed to built-in
" |extend()|.
function! object#dict#extend(dict_like, ...)
  call object#util#ensure_argc(1, a:0)
  " It must be at least a |Dict|.
  let dict_like = maktaba#ensure#IsDict(a:dict_like)
  if object#isinstance(dict_like, s:dict)
    let d = dict_like._dict
  elseif object#hasattr(dict_like, '__iter__')
    let d = object#dict(dict_like)
  else
    let d = dict_like
  endif

  if a:0 == 1
    call extend(self._dict, d, maktaba#ensure#IsString(a:1))
  else
    call extend(self._dict, d)
  endif
endfunction
