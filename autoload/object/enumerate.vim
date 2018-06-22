" CLASS: enumerate {{{1
let s:object = object#object_()
call object#class#builtin_class('enumerate', s:object, s:)

function! s:enumerate.__init__(iter, start)
  let self.iter = a:iter
  let self.idx = a:start
endfunction

function! s:enumerate.__next__()
  let next = [self.idx, object#next(self.iter)]
  let self.idx += 1
  return next
endfunction
" }}}1

" FUNCTION: enumerate() {{{1
""
" @function enumerate(...)
" Return an iterator for index, value of {iter}.
" >
"   enumerate(iterable, start=0) -> [start, item_0], ..., [N, item_N]
" <
function! object#iter#enumerate(iter, ...)
  call object#builtin#TakeAtMostOptional('enumerate', 1, a:0)
  let iter = object#iter(a:iter)
  let start =  a:0 ? object#builtin#CheckNumber(a:1) : 0
  return object#new(s:enumerate, iter, start)
endfunction
" }}}1

" vim: set sw=2 sts=2 et fdm=marker:
