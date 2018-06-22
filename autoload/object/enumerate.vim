" CLASS: enumerate {{{1
let s:object = object#object_()
call object#class#builtin_class('enumerate', s:object, s:)

function! s:enumerate.__iter__()
  return self
endfunction

" Note: enumerate is subclassable, that's why moving
" logic into __init__.
function! s:enumerate.__init__(iterable, ...)
  call object#builtin#TakeAtMostOptional('enumerate', 1, a:0)
  let self.iter = object#iter(a:iterable)
  let self.idx = a:0 ? object#builtin#CheckNumber2(a:1) : 0
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
function! object#enumerate#enumerate(...)
  return object#new_(s:enumerate, a:000)
endfunction
" }}}1

" vim: set sw=2 sts=2 et fdm=marker:
