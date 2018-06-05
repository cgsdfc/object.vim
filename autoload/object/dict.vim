""
" @dict dict
" A wrapper class of built-in |Dict|.

let s:dict = object#type('dict', [], {
      \ '__init__': function('object#dict#__init__'),
      \ '__repr__': function('object#dict#__repr__'),
      \ '__bool__': function('object#dict#__bool__'),
      \ '__getitem__': function('object#dict#__getitem__'),
      \ '__setitem__': function('object#dict#__setitem__'),
      \ 'clear': function('object#list#clear'),
      \ 'copy': function('object#list#copy'),
      \ 'fromkeys': function('object#list#fromkeys'),
      \ 'get': function('object#list#get'),
      \ 'items': function('object#list#items'),
      \ 'keys': function('object#list#keys'),
      \ 'pop': function('object#list#pop'),
      \ 'setdefault': function('object#list#setdefault'),
      \ 'update': function('object#list#update'),
      \ 'values': function('object#list#values'),
      \})

""
" @dict dict
" Initialize a dict
function! object#dict#__init__(...)
  " TODO: call super()
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
function! object#dict#__getitem__(idx) dict
  return object#getitem(self._dict, a:idx)
endfunction

""
" @dict dict
" Set value for a dict item.
function! object#dict#__setitem__(idx, val) dict
  return object#setitem(self._dict, a:idx, a:val)
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
" Return a shallow copy of the dict.
function! object#dict#copy() dict
  return copy(self._dict)
endfunction

"""
"" @dict dict
"function! object#dict#fromkeys(iterable, ...)
"  call object#util#ensure_argc(1, a:0)
"  let value = a:0 == 1? a:1 : object#None()

""
" @dict dict
" Get a value from the dict and fall back on [default].
" @throws KeyError if the key is not present and no [default] is given.
function! object#dict#get(key, ...) dict
  call object#util#ensure_argc(1, a:0)
  try
    return self.__getitem__(a:key)
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
    return self.__getitem__(a:key)
  catch /KeyError/
    call self.__setitem__(a:key, a:default)
    return a:default
  endtry
endfunction

""
" @dict dict
" Remove the specified {key} and return the corresponding value.
" If {key} is not found, [default] is returned if given,
" otherwise KeyError if thrown.
function! object#dict#pop(key, ...)
  
endfunction


