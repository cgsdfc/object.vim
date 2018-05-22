""
" @section Protocols, protocols
" A set of basic hookable functions that inspect and operate on different
" properties of an object. A protocol in this context means an global function
" that has well defined behaviours for built-in types and can be overriden by
" the corresponding methods with double underscores names.


"
" Call a __protocol__ function {X} (ensure {X} is a Funcref)
"
function! object#protocols#call(X, ...)
  return call(maktaba#ensure#IsFuncref(a:X), a:000)
endfunction

"
" Indicate the the {func} is not available for {obj} because of
" lack of hooks or invcompatible type. {func} is the name of the
" function without parentheses.
"
function! object#protocols#not_avail(func, obj)
  throw object#TypeError('%s() not available for %s object', a:func,
        \ object#types#name(a:obj))
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

  if object#protocols#hasattr(a:obj, '__getattr__')
    return object#protocols#call(a:obj.__getattr__, name)
  endif

  if has_key(obj, name)
    return obj[name]
  endif

  if argc == 1
    return a:1
  endif
  call object#except#throw_noattr(obj, name)
endfunction

""
" Set the {name} attribute of {obj} to {val}.
"
function! object#protocols#setattr(obj, name, val)
  let obj = maktaba#ensure#IsDict(a:obj)
  let name = maktaba#ensure#IsString(a:name)

  if object#protocols#hasattr(obj, '__setattr__')
    call object#protocols#call(obj.__setattr__, name, a:val)
    return
  endif

  let obj[name] = a:val
endfunction

""
" Test whether {obj} has attribute {name}.
" Return false if {obj} is not a |Dict|.
"
function! object#protocols#hasattr(obj, name)
  let name = maktaba#ensure#IsString(a:name)
  return maktaba#value#IsDict(a:obj) && has_key(a:obj, name)
endfunction

""
" Generate string representation for {obj}. Fail back on |string()|
"
function! object#protocols#repr(obj)
  if object#class#is_valid_class(a:obj)
    return printf('<type %s>', string(a:obj.__name__))
  endif
  if !object#protocols#hasattr(a:obj, '__repr__')
    " TODO: recurse into list and dict
    " so that objects keep happy in containers.
    return string(a:obj)
  endif
  return maktaba#ensure#IsString(object#protocols#call(a:obj.__repr__))
endfunction

""
" Return the length of {obj}. If {obj} is a |List|
" or a |Dict|, |len()| will be called. Otherwise, the __len__()
" of {obj} will be called.
"
function! object#protocols#len(obj)
  if maktaba#value#IsString(a:obj)
    return len(a:obj)
  endif
  if !object#protocols#hasattr(a:obj, '__len__')
    return len(maktaba#ensure#IsCollection(a:obj))
  endif
  return maktaba#ensure#IsNumber(object#protocols#call(a:obj.__len__))
endfunction

""
" Return a |List| of names of all attributes from {obj}. If
" {obj} defines __dir__(), it is called instead.
"
function! object#protocols#dir(obj)
  let obj = maktaba#ensure#IsDict(a:obj)
  if !has_key(obj, '__dir__')
    return keys(obj)
  endif
  return maktaba#ensure#IsList(object#protocols#call(obj.__dir__))
endfunction
