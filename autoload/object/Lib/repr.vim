let s:escapes = {
      \ "\b": '\b',
      \ "\e": '\e',
      \ "\f": '\f',
      \ "\n": '\n',
      \ "\r": '\r',
      \ "\t": '\t',
      \ "\"": '\"',
      \ "\\": '\\'}

function! s:gsub(str,pat,rep) abort
  return substitute(a:str,'\v\C'.a:pat,a:rep,'g')
endfunction

function! object#Lib#repr#ReprImpl(seen, obj)
  if object#Lib#value#IsContainer(a:obj)
    for i in a:seen
      if i is a:obj
        return object#Lib#value#IsList(a:obj) ? '[...]' : '{...}'
      endif
    endfor
    call add(a:seen, a:obj)
    let repr = object#Lib#value#IsList(a:obj) ?
          \ object#Lib#repr#List_Repr(a:seen, a:obj):
          \ object#Lib#repr#Dict_Repr(a:seen, a:obj)
    call remove(a:seen, -1)
    return repr
  endif
  if object#Lib#value#IsString(a:obj)
    return object#Lib#repr#String_Repr(a:obj)
  endif
  if object#Lib#value#IsType(a:obj)
    return object#Lib#func#Call(function(a:obj.__repr__, a:obj.__class__))
  endif
  if object#Lib#value#IsObj(a:obj)
    return object#Lib#func#CallFuncref(a:obj.__repr__)
  endif
  return string(a:obj)
endfunction

function! object#Lib#repr#String_Repr(str) " {{{1
  if a:str =~# "[\001-\037']"
    return '"'.s:gsub(a:str, "[\001-\037\"\\\\]",
          \ '\=get(s:escapes, submatch(0), printf("\\%03o", char2nr(submatch(0))))').'"'
  else
    return string(a:str)
  endif
endfunction

function! object#Lib#repr#Type__repr__() dict abort "{{{1
  " Implement type.__repr__()
  return printf("<class '%s'>", self.__name__)
endfunction

function! object#Lib#repr#Object__repr__() dict abort "{{{1
  " Implement object.__repr__()
  return printf('<%s object>', self.__class__.__name__)
endfunction

function! object#Lib#repr#Dict_Repr(dict)
  return printf('{%s}', join(map(items(a:dict),
        \ 'printf("''%s'': %s", v:val[0], object#Lib#repr#ReprImpl(a:seen, v:val[1]))'), ', '))
endfunction

function! object#Lib#repr#List_Repr(seen, list)
  return printf('[%s]', join(map(copy(a:list),
        \ 'object#Lib#repr#ReprImpl(a:seen, v:val)'), ', '))
endfunction

function! object#Lib#repr#Repr(obj)
  return object#Lib#func#Call('object#Lib#repr#ReprImpl', [], a:obj)
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
