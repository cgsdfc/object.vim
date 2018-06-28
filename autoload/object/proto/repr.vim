" FINAL CLASS: repr {{{1
let s:repr = object#class('repr')
let s:repr._escapes = {
      \ "\b": '\b',
      \ "\e": '\e',
      \ "\f": '\f',
      \ "\n": '\n',
      \ "\r": '\r',
      \ "\t": '\t',
      \ "\"": '\"',
      \ "\\": '\\'}

function! s:repr.__init__()
  let self._seen = []
endfunction

function! s:repr.__call__(object)
  for i in self._seen
    if a:object is i
      return object#builtin#IsList(a:object) ? '[...]' : '{...}'
    endif
  endfor
  if object#builtin#IsString(a:object)
    return self._do_str(a:object)
  endif
  if object#builtin#IsDict(a:object)
    return 
  endif
endfunction

" FUNCTION: repr() {{{1
" @function repr(...)
" Generate string representation for {obj}. Fail back on |string()|.
" >
"   repr(obj) -> String
" <
" TODO: Make it more serious
" 'maxfuncdepth' default 100
" E132
" RecursionError: maximum recursion depth exceeded
" E132: Function call depth is higher than 'maxfuncdepth'
" sys.setrecursionlimit()
" sys.getrecursionlimit()
function! object#proto#repr(obj)
  return object#builtin#Call('object#proto#repr#Repr', a:obj)
endfunction

function! s:FuncrefRepr(funcref)

endfunction

function! s:DictRepr(dict)

endfunction

function! s:ListRepr(dict)

endfunction

function! s:StringRepr(string)

endfunction

function! s:CheckedRepr(object) dict
  if object#builtin#IsList(a:obj)
    return object#list#repr(a:obj)
  endif

  if object#builtin#IsFuncref(a:obj)
    return object#callable#repr(a:obj)
  endif

  if object#builtin#IsDict(a:obj)
    if has_key(a:obj, '__mro__')
      " TODO: In terms of metaclass, we should use:
      " obj.__class__.__repr__
      return printf("<class '%s'>", a:obj.__name__)
    endif

    if has_key(a:obj, '__repr__')
      let string = object#builtin#Call(a:obj.__repr__)
      if object#builtin#IsString(string)
        return string
      endif
      call object#TypeError('__repr__ returned non-string (type %s)',
            \ object#builtin#TypeName(string))
    else
      return object#dict#repr(a:obj)
    endif
  endif
  " Number, Float, String, Job and Channel, and Special.
  return string(a:obj)

endfunction
