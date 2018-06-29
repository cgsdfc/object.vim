let s:reprobj = {
      \ 'seen': [],
      \ 'List_Repr': function('object#Lib#repr#List_Repr'),
      \ 'Dict_Repr': function('object#Lib#repr#Dict_Repr'),
      \ 'ReprImpl': function('object#Lib#repr#ReprImpl'),
      \}

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

function! object#Lib#repr#Dict_Repr(obj) dict abort "{{{1
  return printf('{%s}', join(map(items(a:obj),
        \ 'printf("''%s'': %s", v:val[0], self.ReprImpl(v:val[1]))'),
        \ ', '))
endfunction

function! object#Lib#repr#List_Repr(obj) dict abort "{{{1
  return printf('[%s]', join(map(copy(a:obj),
        \ 'self.ReprImpl(v:val)'), ', '))
endfunction

function! object#Lib#repr#ReprImpl(obj) dict abort "{{{1
  if object#Lib#value#IsContainer(a:obj)
    if object#Lib#seqn#Any(self.seen, 'a:obj is v:val')
      return object#Lib#value#IsList(a:obj) ? '[...]' : '{...}'
    endif
    call add(self.seen, a:obj)
    let repr = object#Lib#value#IsList(a:obj) ?
          \ self.List_Repr(a:obj): self.Dict_Repr(a:obj)
    call remove(self.seen, -1)
    return repr
  endif
  if object#Lib#value#IsString(a:obj)
    return object#Lib#repr#String_Repr(a:obj)
  endif
  if object#Lib#type#IsType(a:obj)
    return object#Lib#func#CallClassMethod(a:obj, '__repr__')
  endif
  if object#Lib#value#IsObj(a:obj)
    return object#Lib#func#CallFuncref(a:obj.__repr__)
  endif
  "TODO: Funcref
  return string(a:obj)
endfunction

function! object#Lib#repr#String_Repr(str) abort "{{{1
  if a:str =~# "[\001-\037']"
    return printf('"%s"', s:gsub(a:str, "[\001-\037\"\\\\]",
          \ '\=get(s:escapes, submatch(0), printf("\\%03o", char2nr(submatch(0))))'))
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

function! object#Lib#repr#Repr(obj) abort "{{{1
  return deepcopy(s:reprobj).ReprImpl(a:obj)
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
