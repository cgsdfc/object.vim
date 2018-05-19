""
" hash(object)
" Return the hash value of {object}. TODO
function! object#mapping#hash(obj)

endfunction

""
" getitem(object, key)
" Return the value at {key} in {object} as if {object} is a mapping.
" If {object} is a |List| or |Dict|, operator[] of Vim will be used.
function! object#mapping#getitem(obj, key)

endfunction

""
" setitem(object, key, value)
" Set the value at {key} of {object} to {value}.
" If {object} is a |List| or |Dict|, let {object}[{key}] = {value}
" will be used. Otherwise, __setitem__() of {object} will be used.
function! object#mapping#setitem(obj, key, val)

endfunction
