""
" @dict list
" A wrapper class of built-in |List|.

let s:list = object#type('list', [], {
      \ '__init__': function('object#list#__init__'),
      \ '__repr__': function('object#list#__repr__'),
      \ '__bool__': function('object#list#__bool__'),
      \ '__getitem__': function('object#list#__getitem__'),
      \ '__setitem__': function('object#list#__setitem__'),
      \ '__contains__': function('object#list#__contains__'),
      \ '__iter__': function('object#list#__iter__'),
      \ 'append': function('object#list#append'),
      \ 'count': function('object#list#count'),
      \ 'extend': function('object#list#extend'),
      \ 'index': function('object#list#index'),
      \ 'insert': function('object#list#insert'),
      \ 'pop': function('object#list#pop'),
      \ 'remove': function('object#list#remove'),
      \ 'reverse': function('object#list#reverse'),
      \ 'sort': function('object#list#sort'),
      \})

""
" Return the list type.
function! object#list#list_()
  return s:list
endfunction

""
" @dict list
" Initialize a list.
function! object#list#__init__(...) dict
  " TODO: call super()
  let self._list = call('object#list', a:000)
endfunction

""
" @dict list
" Representation of a list.
function! object#list#__repr__() dict
  return object#repr(self._list)
endfunction

""
" @dict list
" Test for emptiness of the list.
function! object#list#__bool__() dict
  return object#bool(self._list)
endfunction

""
" @dict list
" Get an item from the list.
function! object#list#__getitem__(idx) dict
  return object#getitem(self._list, a:idx)
endfunction

""
" @dict list
" Set value for a list item.
function! object#list#__setitem__(idx, val) dict
  return object#setitem(self._list, a:idx, a:val)
endfunction

""
" @dict list
" Test whether {item} is in list.
function! object#list#__contains__(item) dict
  return object#contains(self._list, a:item)
endfunction

""
" @dict list
" Return an iterator over the list.
function! object#list#__iter__() dict
  return object#iter(self._list)
endfunction

""
" @dict list
" Return the length of the list.
function! object#list#__len__() dict
  return object#len(self._list)
endfunction

""
" @dict list
" Add an item to the end of the list.
function! object#list#append(item) dict
  call add(self._list, a:item)
endfunction

""
" @dict list
" Count the occurrences of {value}.
function! object#list#count(value) dict
  " TODO: use object#equal()
  return count(self._list, a:value)
endfunction

""
" @dict list
" Extend the list by appending elements from the {iterable}.
function! object#list#extend(iterable) dict
  let iter = object#iter(a:iterable)
  try
    while 1
      call add(self._list, object#next(iter))
    endwhile
  catch /StopIteration/
    break
  endtry
endfunction

""
" @dict list
" Return the first index of {value} starting from [start].
" @throws ValueError if the {value} is not present.
function! object#list#index(value, ...) dict
  " TODO: use object#equal()
  call object#util#ensure_argc(1, a:0)
  let start = a:0 >= 1 ? maktaba#ensure#IsNumber(a:1) : 0
  return index(self._list, a:value, start)
endfunction

""
" @dict list
" Insert an {item} before {index} .
function! object#list#insert(index, item)
  call insert(self._list, a:item,
        \ maktaba#ensure#IsNumber(a:index))
endfunction

""
" @dict list
" Remove and return the item at [index] @default index=last.
" @throws IndexError if the list is empty or [index] is out of range.
function! object#list#pop(...) dict

endfunction

""
" @dict list
" Remove the first occurrence of {value}.
" @throws ValueError if {value} is not present.
function! object#list#remove(value) dict
  " TODO: use object#equal()
endfunction

""
" @dict list
" Reverse the list in-place.
function! object#list#reverse() dict
  if empty(self._list)
    return
  endif
  call reverse(self._list)
endfunction

""
" @dict list
" Sort the list in-place.
" A [cmp] |Funcref| can be used to customize ordering
" of elements.
function! object#list#sort(...)
  " TODO: use object#cmp()
  call object#util#ensure_argc(1, a:0)
  let Order = a:0 == 1? maktaba#ensure#IsFuncref(a:1):
        \ function('object#cmp')
  call sort(self._list, Order)
endfunction
