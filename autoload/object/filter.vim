""
" @function filter(...)
" Create a new list filtering {iter} using a lambda (String).
" >
"   filter(iter) -> a new list without falsy items.
"   filter(iter, lambda) -> a new list filtered from iter.
" <
" Truthness is tested by `bool()`.
function! object#iter#filter(iter, ...)
  call object#builtin#TakeAtMostOptional('filter', 1, a:0)
  let core = a:0 ? printf('%s(v:val)', object#builtin#CheckString(a:1)):
        \ 'v:val'
  return filter(object#list(a:iter), 'object#bool('.core.')')
endfunction


