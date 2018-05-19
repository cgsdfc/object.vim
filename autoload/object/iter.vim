""
" Return an iterator from {obj}.
"
function! object#iter#iter(obj)

endfunction

""
" Retrieve the next item from the iterator {obj}.
"
function! object#iter#next(obj)
  return maktab#ensure#IsFuncref(object#getattr(a:obj, '__next__'))()
endfunction

function! object#iter#any(iterable)

endfunction

function! object#iter#all(iterable)

endfunction
