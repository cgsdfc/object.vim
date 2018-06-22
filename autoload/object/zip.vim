let s:object = object#object_()

" CLASS: zip {{{1
call object#class#builtin_class('zip', s:object, s:)

function! s:zip.__init__(...)
  let self.seqs = map(copy(a:000), 'object#iter(v:val)')
endfunction

function! s:zip.__iter__()
  return self
endfunction

function! s:zip.__next__()
  if empty(self.seqs)
    call object#StopIteration()
  endif
  return map(copy(self.seqs), 'object#next(v:val)')
endfunction

" }}}1

""
" @function zip(...)
" Return an iterator that zips a list of sequences.
" >
"   zip(iter[,*iters]) -> [seq1[0], seq2[0], ...], ...
"   zip() -> an empty iterator
" <
" The iterator stops at the shortest sequence.
function! object#zip#zip(...)
  return object#new_(s:zip, a:000)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
