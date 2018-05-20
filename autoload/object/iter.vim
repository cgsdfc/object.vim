let s:list_iter = object#class('list_iter')
let s:str_iter = object#class('str_iter')
let s:enum_iter = object#class('enumerate')
let s:zip_iter = object#class('zip_iter')

function! s:list_iter.__init__(list)
  let self.idx = 0
  let self.list = a:list
endfunction

function! s:list_iter.__next__()
  try
    let item = self.list[self.idx]
    let self.idx += 1
    return item
  catch /E684: list index out of range:/
    throw object#StopIteration()
  endtry
endfunction

function! s:str_iter.__init__(str)
  let self.idx = 0
  let self.str = a:str
  let self.len = len(a:str)
endfunction

function! s:str_iter.__next__()
  if self.idx < self.len
    let item = self.str[self.idx]
    let self.idx += 1
    return item
  endif
  throw object#StopIteration()
endfunction

function! s:enum_iter.__init__(iter, start)
  let self.iter = a:iter
  let self.idx = a:start
endfunction

function! s:enum_iter.__next__()
  let item = [self.idx, object#next(self.iter)]
  let self.idx += 1
  return item
endfunction

function! s:zip_iter.__init__(iters)
  let self.iters = a:iters
endfunction

function! s:zip_iter.__next__()
  return map(copy(self.iters), 'object#next(v:val)')
endfunction

""
" Return an iterator from {obj}.
"
function! object#iter#iter(obj)
  if object#hasattr(a:obj, '__next__')
    return a:obj
  endif
  if maktaba#value#IsList(a:obj)
    return object#new(s:list_iter, a:obj)
  endif
  if maktaba#value#IsString(a:obj)
    return object#new(s:str_iter, a:obj)
  endif
  if object#hasattr(a:obj, '__iter__')
    return object#protocols#call(a:obj.__iter__)
  endif
  call object#protocols#not_avail('iter', a:obj)
endfunction

""
" Retrieve the next item from the iterator {obj}.
"
function! object#iter#next(obj)
  if object#hasattr(a:obj, '__next__')
    return object#protocols#call(a:obj.__next__)
  endif
  call object#protocols#not_avail('next', a:obj)
endfunction

function! object#iter#any(iter)
  let iter = object#iter#iter(a:iter)
  try
    while 1
      let item = object#iter#next(iter)
      if object#bool(item) | return 1 | endif
    endwhile
  catch /StopIteration/
    return 0
  endtry
endfunction

function! object#iter#all(iter)
  let iter = object#iter#iter(a:iter)
  try
    while 1
      let item = object#iter#next(iter)
      if !object#bool(item) | return 0 | endif
    endwhile
  catch /StopIteration/
    return 1
  endtry
endfunction

function! object#iter#dict(iter)
  let iter = object#iter(a:iter)
  let dict = {}
  try
    while 1
      let item = object#next(iter)
      let dict[item[0]] = item[1]
    endwhile
  catch /StopIteration/
    return dict
  endtry
endfunction

function! object#iter#list(iter)
  let iter = object#iter(a:iter)
  let list = []
  try
    while 1
      call add(list, object#next(iter))
    endwhile
  catch /StopIteration/
    return list
  endtry
endfunction

function! object#iter#map(expr, iter)

endfunction

function! object#iter#sum(iter)
  let iter = object#iter(a:iter)
  let x = object#next(iter)
  try
    while 1
      let x += object#next(iter)
    endwhile
  catch /StopIteration/
    return x
  endtry
endfunction

function! object#iter#filter(expr, iter)

endfunction

""
" iterator for index, value of iterable.
" Take an optional [start].
"
function! object#iter#enumerate(iter, ...)
  let argc = object#util#ensure_argc(1, a:0)
  let iter = object#iter(a:iter)
  let start =  argc ? maktaba#ensure#IsNumber(a:1) : 0
  return object#new(s:enum_iter, iter, start)
endfunction

function! object#iter#zip(iter, ...)
  let iter = object#iter(a:iter)
  if !a:0 | return iter | endif
  let iters = [iter] + a:000
  return object#new(s:zip_iter, iters)
endfunction
