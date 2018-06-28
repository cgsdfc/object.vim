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

" FUNCTION: repr()
" Representation of plain Dict.
function! object#dict#repr(dict)
  return printf('{%s}', join(map(items(a:dict),
        \ 'printf("''%s'': %s", v:val[0], object#repr(v:val[1]))'), ', '))
endfunction

""
" @function dict(...)
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
" vim: set sw=2 sts=2 et fdm=marker:
