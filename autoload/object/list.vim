" FUNCTION: getitem() {{{1
function! object#list#getitem(list, index)
  " Python just report 'list index out of range' without giving
  " the explicit index, while Vim makes it wrong for negative index
  " by giving the `index + len`.
  let index = object#list#CheckIndex(a:index)
  try
    let Val = a:list[index]
  catch 'E684:'
    " index out of range.
    " Vim gets wrong about negative index.
    call object#IndexError('list index out of range: %d', a:index)
  endtry
  return Val
endfunction

" FUNCTION: setitem() {{{1
function! object#list#setitem(list, index, val)
  let index = object#list#CheckIndex(a:index)
  try
    let a:list[index] = a:val
  catch 'E684:'
    " index out of range
    call object#IndexError('list index out of range: %d', a:index)
  catch 'E741:'
    " lockvar
    call object#RuntimeError(object#builtin#ReOrderVimError(v:exception))
  endtry
endfunction

" FUNCTION: delitem() {{{1
function! object#list#delitem(list, index)
  let index = object#list#CheckIndex(a:index)
  try
    unlet a:list[index]
  catch 'E684:'
    call object#IndexError('list index out of range: %d', a:index)
  endtry
endfunction

" FUNCTION: CheckIndex() {{{1
function! object#list#CheckIndex(index)
  if object#builtin#IsNumber(a:index)
    return a:index
  endif
  call object#TypeError("list indices must be integers or slices, not %s",
        \ object#builtin#TypeName(a:index))
endfunction

" FUNCTION: contains() {{{1
function! object#list#contains(haystack, needle)
  " TODO: object#eq
  return index(a:haystack, a:needle) >= 0
endfunction

" FUNCTION: repr() {{{1
" Return representation of a plain |List|.
function! object#list#repr(list)
  return printf('[%s]', join(map(copy(a:list), 'object#repr(v:val)'), ', '))
endfunction

" FUNCTION: list() {{{1
""
" @function list(...)
" Create a plain |List|.
" >
"   list() -> an empty list.
"   list(plain list) -> a shallow copy of it.
"   list(iterable) -> initiazed with items of iterable.
"   list(list object) -> a copy of the underlying list.
" <
function! object#list#list(...)
  call object#builtin#TakeAtMostOptional('list', 1, a:0)
  if !a:0
    return []
  endif

  if object#builtin#IsList(a:1)
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

" vim: set sw=2 sts=2 et fdm=marker:
