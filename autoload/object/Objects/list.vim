" FUNCTION: _list() {{{1
""
" @function _list(...)
" Create a list object.
function! object#list#_list(...)
  return object#new_(s:list, a:000)
endfunction

""
" @function list_(...)
" Return the list type.
function! object#list#list_()
  return s:list
endfunction

let s:object = object#object_()

" CLASS: list {{{1
call object#class#builtin_class('list', s:object, s:)

""
" TODO: use __new__ to create the list so that subclass
" won't need to call super(). And delete __init__
" function! s:list.__new__(cls, ...)
"   let obj = call(s:object.__new__, a:000, a:cls)
"   let obj._list = call('object#list', a:000)
"   return obj
" endfunction

" @dict list
" Initialize a list.
function! s:list.__init__(...)
  let self._list = call('object#list', a:000)
endfunction

" METHOD: __reversed__() {{{1
function! s:list.__reversed__()
  return object#list#iter#reversed(self._list)
endfunction

""
" @dict list
" Representation of a list.
function! s:list.__repr__()
  return object#repr(self._list)
endfunction

""
" @dict list
" Test for emptiness of the list.
function! s:list.__bool__()
  return object#bool(self._list)
endfunction

""
" @dict list
" Get an item from the list.
function! s:list.__getitem__(key)
  return object#getitem(self._list, a:key)
endfunction

""
" @dict list
" Set value for a list item.
function! s:list.__setitem__(key, val)
  return object#setitem(self._list, a:key, a:val)
endfunction

""
" @dict list
" Test whether {item} is in list.
function! s:list.__contains__(needle)
  return object#in(a:needle, self._list)
endfunction

""
" @dict list
" Return an iterator over the list.
function! s:list.__iter__()
  return object#iter(self._list)
endfunction

""
" @dict list
" Return the length of the list.
function! s:list.__len__()
  return object#len(self._list)
endfunction

" METHOD: {{{1
""
" @dict list
" Add an item to the end of the list.
function! s:list.append(Item)
  call add(self._list, a:Item)
endfunction

""
" @dict list
" Count the occurrences of {value}.
function! s:list.count(Value)
  " TODO: use object#equal()
  return count(self._list, a:Value)
endfunction

""
" @dict list
" Extend the list by appending elements from the {iterable}.
function! s:list.extend(Iterable)
  let iter = object#iter(a:Iterable)
  try
    while 1
      call add(self._list, object#next(iter))
    endwhile
  catch 'StopIteration'
    return
  endtry
endfunction

""
" @dict list
" Return the first index of {value} starting from [start].
" @throws ValueError if the {value} is not present.
function! s:list.index(Value, ...)
  " TODO: use object#equal()
  call object#builtin#TakeAtMostOptional('index()', 1, a:0)
  let start = a:0 >= 1 ? maktaba#ensure#IsNumber(a:1) : 0
  return index(self._list, a:Value, start)
endfunction

""
" @dict list
" Insert an {item} before {index} .
function! s:list.insert(Index, Item)
  call insert(self._list, a:Item, maktaba#ensure#IsNumber(a:Index))
endfunction

""
" @dict list
" Remove and return the item at [index] @default index=last.
" @throws IndexError if the list is empty or [index] is out of range.
function! s:list.pop(...)
  call object#builtin#TakeAtMostOptional('pop', 1, a:0)
  let idx = a:0 ? maktaba#ensure#IsNumber(a:1) : object#len(self) - 1
  try
    return remove(self._list, idx)
  catch 'E684:'
    call object#IndexError('list index out of range: %d', idx)
  endtry
endfunction

""
" @dict list
" Remove the first occurrence of {value}.
" @throws ValueError if {value} is not present.
function! s:list.remove(Val)
  " TODO: use object#equal()
  let idx = index(self._list, a:Val)
  if idx < 0
    call object#ValueError('value not in list')
  endif
  call remove(self._list, idx)
endfunction

""
" @dict list
" Reverse the list in-place.
function! s:list.reverse()
  call reverse(self._list)
endfunction

""
" @dict list
" Sort the list in-place.
" A [cmp] |Funcref| can be used to customize ordering
" of elements.
function! s:list.sort(...)
  " TODO: use object#cmp()
  call object#builtin#TakeAtMostOptional(1, a:0)
  " TODO: callable.vim
  let Order = a:0 == 1? maktaba#ensure#IsFuncref(a:1):
        \ function('object#cmp')
  call sort(self._list, Order)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
