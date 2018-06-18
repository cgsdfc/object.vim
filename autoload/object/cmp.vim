""
" {a}
function! object#cmp#cmp(X, Y)
  let args = [a:X, a:Y]
  let richcmp = map(['lt', 'eq', 'gt'],
        \ 'call(printf("object#%s", v:val), args)')
  if count(richcmp, 1) != 1
    throw object#TypeError('cmp(): inconsistent richcmp results')
  endif
  " Which one says yes?
  return index(richcmp, 1) - 1
endfunction

function! object#cmp#has_builtin_eq(X)
  return maktaba#value#IsNumeric(a:X) || maktaba#value#IsString(a:X)
        \ maktaba#value#IsFuncref(a:X)
endfunction

function! object#cmp#call(X, Y)
  return maktaba#ensure#IsBool(object#protocols#call(a:X, a:Y))
endfunction

function! object#cmp#throw_unorderable(op, X, Y)
  throw object#TypeError('unorderable types: %s %s %s',
        \ a:op, object#types#name(a:X), object#types#name(a:Y))
endfunction

function! object#cmp#eq(X, Y)
  if type(a:X) != type(a:Y)
    return 0
  endif
  if object#cmp#has_builtin_eq(a:X)
    return a:X ==# a:Y
  endif
  if maktaba#value#IsList(a:X)
    return object#cmp#list_eq(a:X, a:Y)
  endif
  if maktaba#value#IsDict(a:X)
    if has_key(a:X, '__eq__')
      return object#cmp#call(a:X.__eq__, a:Y)
    else
      return object#cmp#dict_eq(a:X, a:Y)
    endif
  endif
  call object#cmp#throw_unorderable('==', a:X, a:Y)
endfunction

function! object#cmp#ne(X, Y)
  if type(a:X) != type(a:Y)
    return 1
  endif
  if object#cmp#has_builtin_eq(a:X)
    return a:X !=# a:Y
  endif
  if maktaba#value#IsList(a:X)
    return !object#cmp#list_eq(a:X, a:Y)
  endif
  if maktaba#value#IsDict(a:X)
    if has_key(a:X, '__ne__')
      return object#cmp#call(a:X.__ne__, a:Y)
    else
      return !object#cmp#dict_eq(a:X, a:Y)
    endif
  endif
  call object#cmp#throw_unorderable('!=', a:X, a:Y)
endfunction

function! object#cmp#lt(X, Y)
  if
endfunction

function! object#cmp#le(X, Y)
endfunction

function! object#cmp#gt(X, Y)
endfunction

function! object#cmp#ge(X, Y)
endfunction

function! object#cmp#dict_eq(X, Y)
  return object#cmp#list_eq(items(a:X), items(a:Y))
endfunction

function! object#cmp#list_eq(X, Y)
  let N = len(a:X)
  let M = len(a:Y)
  if N != M
    return 0
  endif
  let i = 0
  while i < N
    if !object#eq(a:X[i], a:Y[i])
      return 0
    endif
    let i += 1
  endwhile
  return 1
endfunction

