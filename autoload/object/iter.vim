""
" @section Iterator, iter
" Iterator protocol.
"
" Features:
"   * Vim-compatible map() and filter() that works with iterators.
"   * dict() creates |Dict| from an iterator and a lambda,
"     which is similar to dict comprehension.
"   * filter() evaluates lambda using |object#types#bool()|.
"   * Provide iterators for |String| and |List| that works transparently.
"   * Helpers like sum(), all(), any(), zip() and enumerate() all work as expected.
"   * for() function let you execute nearly arbitrary code while iterating.
"
" Examples:
" >
"   :echo object#all(range(10))
"   0
"
"   :echo object#list(object#enumerate('abc'))
"   [[0, 'a'], [1, 'b'], [2,'c']]
"
"   :echo object#dict('abc', '[toupper(v:val), v:val]')
"   {'A': 'a', 'B': 'b', 'C': 'c'}
"
"   :echo object#dict(object#enumerate('abc'), '[v:val[1], v:val[0]]')
"   {'a': 0, 'b': 1, 'c': 2}
"
"   :echo object#dict(object#zip('abc', range(3)))
"   {'a': 0, 'b': 1, 'c': 2}
"
"   :echo object#sum(range(1, 100))
"   5050
"
"   :echo object#filter(['1', '2', ''], 'v:val')
"   ['1', '2']
"
"   :echo object#list('abc')
"   ['a', 'b', 'c']
"
"   :call object#for('key val', object#enumerate([1, 2]), 'echo key val')
"   0 1
"   1 2
" <
"
" Limitations:
"   * No generator and yield() supported.
"   * No closure for the code segments executed in the for() function.

let s:list_iter = object#class('list_iter')
let s:str_iter = object#class('str_iter')
let s:enum_iter = object#class('enumerate')
let s:zip_iter = object#class('zip_iter')

function! s:list_iter.__init__(list)
  let self.idx = 0
  let self.list = a:list
endfunction

" When the list index goes out of range, Vim throws E684.
function! s:list_iter.__next__()
  try
    let Item = self.list[self.idx]
  catch /E684/
    throw object#StopIteration()
  endtry
  let self.idx += 1
  return Item
endfunction

function! s:str_iter.__init__(str)
  let self.idx = 0
  let self.str = a:str
endfunction

" When the index to a string goes out of range, Vim
" returns an empty string, which is an indicator of StopIteration.
function! s:str_iter.__next__()
  let Item = self.str[self.idx]
  if Item isnot# ''
    let self.idx += 1
    return Item
  endif
  throw object#StopIteration()
endfunction

function! s:enum_iter.__init__(iter, start)
  let self.iter = a:iter
  let self.idx = a:start
endfunction

function! s:enum_iter.__next__()
  let Item = [self.idx, object#next(self.iter)]
  let self.idx += 1
  return Item
endfunction

function! s:zip_iter.__init__(iters)
  let self.iters = a:iters
endfunction

function! s:zip_iter.__next__()
  return map(copy(self.iters), 'object#next(v:val)')
endfunction

function! s:ensure_iter(x)
  if object#hasattr(a:x, '__iter__') && maktaba#value#IsFuncref(a:x.__iter__)
    return a:x
  endif
  throw object#TypeError('object is not an iterator')
endfunction

""
" Return an iterator from {obj}. If {obj} is already an iterator, it is
" returned as it. Built-in |List| and |String| have iterators. An __iter__
" method of {obj} that returns an iterator will be used if possible.
"
" @throws WrongType if {obj} has an unusable __next__.
" @throws TypeError if the __iter__ of {obj} does not return an iterator.
function! object#iter#iter(obj)
  if object#hasattr(a:obj, '__next__')
    call maktaba#ensure#IsFuncref(a:obj.__next__)
    return a:obj
  endif

  if maktaba#value#IsList(a:obj)
    return object#new(s:list_iter, a:obj)
  endif

  if maktaba#value#IsString(a:obj)
    return object#new(s:str_iter, a:obj)
  endif

  if object#hasattr(a:obj, '__iter__')
    return s:ensure_iter(object#protocols#call(a:obj.__iter__))
  endif

  call object#except#not_avail('iter', a:obj)
endfunction

""
" Retrieve the next item from the iterator {obj}.
function! object#iter#next(obj)
  if object#hasattr(a:obj, '__next__')
    return object#protocols#call(a:obj.__next__)
  endif
  call object#except#not_avail('next', a:obj)
endfunction

""
" Return true iff any item from {iter} is true. Truthness is evaluated using
" object#bool(). {iter} can be anything iterable.
function! object#iter#any(iter)
  let iter = object#iter(a:iter)
  try
    while 1
      let Item = object#iter#next(iter)
      if object#bool(Item) | return 1 | endif
    endwhile
  catch /StopIteration/
    return 0
  endtry
endfunction

""
" Return true iff all item from {iter} is true. Truthness is evaluated using
" object#bool(). {iter} can be anything iterable.
function! object#iter#all(iter)
  let iter = object#iter(a:iter)
  try
    while 1
      let Item = object#iter#next(iter)
      if !object#bool(Item) | return 0 | endif
    endwhile
  catch /StopIteration/
    return 1
  endtry
endfunction

function! s:ensure_2_lists(x)
  if maktaba#value#IsList(a:x) && len(a:x) == 2
    return a:x
  endif
  throw object#TypeError('not a 2-lists')
endfunction

""
" >
"   dict() -> an empty dictionary.
"   dict(iterable) -> initiazed with 2-list items.
"   dict(iterable, lambda) -> applies lambda to iterable, initiazed with the resulting list.
"   dict(plain dictionary) -> a copy of the argument.
" <
"
" Turn an iterator that returns 2-list into a |Dict|.
" If no [iter] is given, an empty |Dict| is returned.
" If a |Dict| is given, it is effectively |copy()|'ed.
function! object#iter#dict(...)
  call object#util#ensure_argc(2, a:0)
  if !a:0
    return {}
  endif

  " Plain dictionary.
  if maktaba#value#IsDict(a:1) && !has_key(a:1, '__next__')
    return copy(a:1)
  endif

  let dict = {}
  let iter = object#iter(a:1)
  let list = a:0 == 2 ? object#map(iter, a:2) : object#list(iter)

  for x in map(list, 's:ensure_2_lists(v:val)')
    let dict[x[0]] = x[1]
  endfor
  return dict
endfunction

""
" >
"   list() -> an empty list.
"   list(iterable) -> initiazed with items of iterable.
" <
"
" Turn an iterator into a |List|.
" If no [iter] is given, an empty |List| is returned.
" If a |List| is given, it is effectively |copy()|'ed.
function! object#iter#list(...)
  call object#util#ensure_argc(1, a:0)
  if !a:0
    return []
  endif

  if maktaba#value#IsList(a:1)
    return copy(a:1)
  endif

  let iter = object#iter(a:1)
  let list = []
  try
    while 1
      call add(list, object#next(iter))
    endwhile
  catch /StopIteration/
    return list
  endtry
endfunction

""
" Return an iterator for index, value of {iter}
" Take an optional [start].
function! object#iter#enumerate(iter, ...)
  let argc = object#util#ensure_argc(1, a:0)
  let iter = object#iter(a:iter)
  let start =  argc ? maktaba#ensure#IsNumber(a:1) : 0
  return object#new(s:enum_iter, iter, start)
endfunction

""
" Return an iterator that returns [seq1[i], seq[i], ...]
" for the ith call of object#next(). The iterator stops when
" the first StopIteration is raised by one of the [iters].
function! object#iter#zip(iter, ...)
  let iter = object#iter(a:iter)
  if !a:0
    return iter
  endif

  let iters = insert(map(copy(a:000), 'object#iter(v:val)'), iter)
  return object#new(s:zip_iter, iters)
endfunction

""
" Create a new list by applying {lambda} to each item of an {iter}.
" {lambda} should be a |String| that is acceptable by built-in |map()|.
function! object#iter#map(iter, lambda)
  let iter = object#iter(a:iter)
  let lambda = maktaba#ensure#IsString(a:lambda)
  return map(object#list(iter), lambda)
endfunction

""
" Create a new list by removing the item from {iter} when {lambda}
" return false. Truthness is evaluated by object#bool().
" {lambda} should be a |String| that is acceptable by built-in |filter()|.
function! object#iter#filter(iter, lambda)
  let iter = object#iter(a:iter)
  let lambda = maktaba#ensure#IsString(a:lambda)
  return filter(object#list(iter), 'object#bool('.lambda.')')
endfunction

""
" Return the sum of items from {iter} plus the value of
" parameter [start], which defaults to 0. Items must be either |Number|s
" or |Float|s, i.e., numeric.
" If {iter} is empty, [start] is returned.
"
" @throws WrongType if any item is not numeric.
function! object#iter#sum(iter, ...)
  call object#util#ensure_argc(1, a:0)
  let start = a:0 ? maktaba#ensure#IsNumeric(a:1) : 0
  let iter = object#iter(a:iter)
  try
    while 1
      let start += maktaba#ensure#IsNumeric(object#next(iter))
    endwhile
  catch /StopIteration/
    return start
  endtry
endfunction

"
" Execute {__excmds} with {__items} set as items
" from the iterator.
function! s:execute_cmds(__excmds, __items)
  for __i in a:__items
    let {__i[0]} = __i[1]
  endfor
  execute a:__excmds
endfunction

"
" Unpack the {Vals} into {names} and return a 2-lists
" list for each name-value pair.
" If there is only one name, it will take the entire of {Vals}.
" Otherwise, {Vals} must be a |List| and its len should match
" that of the {names}.
"
" @throws WrongType if Vals is not a List but len(names) > 1.
" @throws TypeError if the len of names does not match that of
" Vals.
function! s:make_items(names, Vals)
  let names_nr = len(a:names)
  if names_nr ==# 1
    return [ [a:names[0], a:Vals] ]
  endif
  let Vals = maktaba#ensure#IsList(a:Vals)
  let Vals_nr = len(Vals)
  if names_nr ==# Vals_nr
    let i = 0
    let result = []
    while i < names_nr
      call add(result, [a:names[i], Vals[i]])
      let i += 1
    endwhile
    return result
  endif
  throw object#TypeError(names_nr > Vals_nr ?
        \ 'more targets than list items':
        \ 'less targets than list items')
endfunction

""
" Execute a |List| of commands while iterating over {iterable}.
" {names} is a space-separated |String|s that contains the variable
" names used as the items in the {iterable}.
"
" {cmd} is a |String| of Ex command or a |List| of such strings.
" During each iteration, the commands are executed
" in the order that they are specified in the list.
" Examples:
" >
"   call object#for('x', range(10), ['if x > 0', 'echo x', 'endif'])
"   call object#for('f', files, 'call f.close()')
"   call object#for('key val', items({'a': 1}), 'echo key val')
" <
function! object#iter#for(names, iterable, cmds)
  let names = map(split(maktaba#ensure#IsString(a:names)),
        \ 'object#util#ensure_identifier(v:val)')
  let iter = object#iter(a:iterable)
  " let capture = maktaba#ensure#IsDict(a:capture)
  if maktaba#value#IsString(a:cmds)
    let excmds = a:cmds
  else
    let cmds =  map(maktaba#ensure#IsList(a:cmds), 'maktaba#ensure#IsString(v:val)')
    let excmds = join(cmds, "\n")
  endif

  try
    while 1
      let Items = s:make_items(names, object#next(iter))
      call s:execute_cmds(excmds, Items)
    endwhile
  catch /StopIteration/
    return
  endtry
endfunction
