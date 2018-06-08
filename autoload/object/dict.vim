""
" @section Dict, dict
" A wrapper class of built-in |Dict|.
let s:dict = object#class('dict')

""
" Create a plain |Dict|.
" >
"   dict() -> an empty dictionary.
"   dict(iterable) -> initiazed with 2-list items.
"   dict(plain dictionary) -> a copy of the argument.
"   dict(dict object) -> a copy of the underlying dictionary.
" <
function! object#dict#dict(...)
  call object#util#ensure_argc(1, a:0)
  if !a:0
    return {}
  endif
  if object#isinstance(a:1, s:dict)
    return copy(a:1._dict)
  endif
  try
    let iter = object#iter(a:1)
  catch /TypeError/
    if maktaba#value#IsDict(a:1)
      return copy(a:1)
    endif
    throw object#TypeError('wrong type: %s', object#types#name(a:1))
  endtry
  return object#dict#from_iter(a:1)
endfunction

""
" Create a dict object
function! object#dict#_dict(...)
  return object#new_(s:dict, a:000)
endfunction

""
" Return the dict type.
function! object#dict#dict_()
  return s:dict
endfunction

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

" Representation of plain Dict.
function! object#dict#repr(dict)
  return printf('{%s}', join(map(items(a:dict),
        \ 'printf("''%s'': %s", v:val[0], object#repr(v:val[1]))'), ', '))
endfunction

function! object#dict#ensure_2_lists(X)
  if maktaba#value#IsList(a:X) && len(a:X) == 2
    return a:X
  endif
  throw object#TypeError('not a 2-lists')
endfunction

" Create a |Dict| from an iterator.
function! object#dict#from_iter(iter)
  let iter = object#iter(a:iter)
  let d = {}
  try
    while 1
      let X = object#dict#ensure_2_lists(object#next(iter))
      let d[X[0]] = X[1]
    endwhile
  catch /StopIteration/
    return d
  endtry
endfunction
