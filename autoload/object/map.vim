" FUNCTION: map(), filter() {{{1
" TODO: allow Funcref here (callable module).
" map object
""
" @function map(...)
" Tranform the iterable with lambda (String).
" >
"   map(iter, lambda) -> a new list mapped from iter
" <
function! object#iter#map(iter, lambda)
  return map(object#list(a:iter), object#builtin#CheckString(a:lambda))
endfunction


