"
" Test whether {obj} has an attribute {name} which is a |Funcref|.
function! object#protocols#has(obj, name)
  return has_key(a:obj, a:name) && maktaba#value#IsFuncref(a:obj[a:name])
endfunction

""
" Get the attribute {name} from {obj}.
" Note: The __getattr__() hook overrides the dictionary lookup
" completely. That means it is not consulted after dictionary lookup
" failed but used directly if there is a usable one.
"
function! object#protocols#getattr(obj, name, ...)
  let obj = maktaba#ensure#IsDict(a:obj)
  let name = maktaba#ensure#IsString(a:name)
  let argc = object#util#ensure_argc(1, a:0)

  if object#protocols#has(obj, '__getattr__')
    return obj.__getattr__(name)
  endif

  if has_key(obj, name)
    return obj[name]
  endif

  if argc == 1
    return a:1
  endif

  throw object#AttributeError('%s object has no attribute %s',
        \ object#types#name(obj), string(name))
endfunction

""
" setattr(obj, name, val)
" Set the {name} attribute of {obj} to {val}.
"
" Set attribute {name} to {val} for {obj}
function! object#protocols#setattr(obj, name, val)
  let obj = maktaba#ensure#IsDict(a:obj)
  let name = maktaba#ensure#IsString(a:name)

  if object#protocols#has(obj, '__setattr__')
    call obj.__setattr__(name, a:val)
    return
  endif

  let obj[name] = a:val
endfunction

""
" hasattr(obj, name)
" Return whether {obj} has attribute {name}.
"
" Test whether {obj} has attribute {name}.
" Return false if {obj} is not a |Dict|.
function! object#protocols#hasattr(obj, name)
  let name = maktaba#ensure#IsString(a:name)
  return maktaba#value#IsDict(a:obj) && has_key(a:obj, name)
endfunction

function! object#protocols#repr(obj)
  if !object#protocols#hasattr(a:obj, '__repr__')
    return string(a:obj)
  endif
  call maktaba#ensure#IsFuncref(a:obj.__repr__)
  return maktaba#ensure#IsString(a:obj.__repr__())
endfunction

""
" len(obj)
" Return the length of {obj}. If {obj} is a |List|
" or a |Dict|, |len()| will be called. Otherwise, the __len__()
" of {obj} will be called.
function! object#protocols#len(obj)
  if maktaba#value#IsString(a:obj)
    return len(a:obj)
  endif
  if !object#protocols#hasattr(a:obj, '__len__')
    return len(maktaba#ensure#IsCollection(a:obj))
  endif
  call maktaba#ensure#IsFuncref(a:obj.__len__)
  return maktaba#ensure#IsNumber(a:obj.__len__())
endfunction

""
" dir(obj)
" Return a |List| of names of all attributes from {obj}. If
" {obj} defines __dir__(), it is called instead.
"
function! object#protocols#dir(obj)
  let obj = maktaba#ensure#IsDict(a:obj)
  if !has_key(obj, '__dir__')
    return keys(obj)
  endif
  call maktaba#ensure#IsFuncref(a:obj.__dir__)
  return maktaba#ensure#IsList(obj.__dir__())
endfunction
