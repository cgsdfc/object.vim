" FINAL CLASS: str_iterator {{{1
call object#class#builtin_class('str_iterator', s:object, s:)
let s:str_iterator.__final__ = 1

function! s:str_iterator.__init__(str)
  let self.idx = 0
  let self.str = a:str
endfunction

" When the index to a string goes out of range, Vim
" returns an empty string, which is an indicator of StopIteration.
function! s:str_iterator.__next__()
  let Item = self.str[self.idx]
  if Item is ''
    call object#StopIteration()
  endif
  let self.idx += 1
  return Item
endfunction

let s:str_iterator.__iter__ = object#slots#iter_self()
let s:str_iterator.__setattr__ = object#slots#readonly_attribute()

" FUNCTION: iter() {{{1
function! object#str#iter#iter(str)
  return object#new(s:str_iterator, a:str)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
