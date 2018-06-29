" CLASS: list {{{1
let s:listobj = object#Lib#builtins#Type_New('list')

function! s:listobj.__new__(...)
  let obj = object#Lib#class#Object__new__(s:listobj)
endfunction

""
" TODO: Where to put the function that converts iterable
" into a builtin-list?

function! s:listobj.__reversed__()
  return object#new('list_reverseiter', self)
endfunction

function! s:listobj.__repr__()
  " Representation of a list.
  return object#repr(self._list)
endfunction

function! s:listobj.__bool__()
  " Test for emptiness of the list.
  return object#bool(self._list)
endfunction

function! s:listobj.__getitem__(key)
  " Get an item from the list.
  return object#getitem(self._list, a:key)
endfunction

function! s:listobj.__setitem__(key, val)
  " Set value for a list item.
  return object#setitem(self._list, a:key, a:val)
endfunction

function! s:listobj.__contains__(needle)
  " Test whether {item} is in list.
  return object#in(a:needle, self._list)
endfunction

function! s:listobj.__iter__()
  " Return an iterator over the list.
  return object#iter(self._list)
endfunction

function! s:listobj.__len__()
" Return the length f the list.
  return object#len(self._list)
endfunction

function! s:listobj.append(item)
" Add an item to the end of the list.
  call add(self._list, a:item)
endfunction

  " TODO: use object#equal()
function! s:listobj.count(value)
" Count the occurrences of {value}.
  return count(self._list, a:value)
endfunction

function! s:listobj.extend(iterable)
" Extend the list by appending elements from the {iterable}.
  let iter = object#iter(a:iterable)
  try
    while 1
      call add(self._list, object#next(iter))
    endwhile
  catch 'StopIteration'
    return
  endtry
endfunction

" TODO: use object#equal()
function! s:listobj.index(value, ...)
" Return the first index of {value} starting from [start].
" @throws ValueError if the {value} is not present.
  call object#Lib#value#TakeAtMostOptional('list.index', 1, a:0)
  let start = a:0 == 1 ? object#Lib#value#CheckNumber2(a:1) : 0
  return index(self._list, a:value, start)
endfunction

function! s:listobj.insert(index, item)
" Insert an {item} before {index} .
  call insert(self._list, a:item, object#Lib#value#CheckNumber2(a:index))
endfunction

function! s:listobj.pop(...)
  " Remove and return the item at [index] @default index=last.
  " @throws IndexError if the list is empty or [index] is out of range.
  call object#Lib#value#TakeAtMostOptional('list.pop', 1, a:0)
  " TODO: Use CheckIndex() to end this try-catch.
  let index = a:0 ? object#Lib#value#CheckNumber2(a:1) : object#len(self) - 1
  try
    return remove(self._list, index)
  catch 'E684:'
    call object#IndexError('list index out of range: %d', index)
  endtry
endfunction

function! s:listobj.remove(value)
  " Remove the first occurrence of {value}.
  " @throws ValueError if {value} is not present.
  " TODO: use object#equal()
  let index = index(self._list, a:value)
  if index < 0
    call object#ValueError('value not in list')
  endif
  call remove(self._list, index)
endfunction

function! s:listobj.reverse()
  " Reverse the list in-place.
  call reverse(self._list)
endfunction

function! s:listobj.sort()
  " Sort the list in-place.
  " A [cmp] |Funcref| can be used to customize ordering
  " of elements.
  " TODO: use object#cmp()
  call object#Lib#value#TakeAtMostOptional('list.sort', 1, a:0)
  " TODO: callable.vim
  call sort(self._list)
endfunction

function! s:listobjobj.__instancecheck__(obj)
  if object#Lib#value#IsList(a:obj)
    return 1
  endif
  if object#Lib#value#IsObj(a:obj)
    return object#Lib#type#Type__instancecheck__(self, a:obj)
  endif
  return 0
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
