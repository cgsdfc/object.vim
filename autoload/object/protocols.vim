""
" @section Protocols, protocols
" A set of basic hookable functions that inspect and operate on different
" properties of an object. A protocol in this context means an global function
" that has well defined behaviours for built-in types and can be overriden by
" the corresponding methods with double underscores names.

" TODO:
"   * fix the __getattribute__ and __getattr__

"
" Call a __protocol__ function {X} (ensure {X} is a Funcref)
"
function! object#protocols#call(X, ...)
  return call(maktaba#ensure#IsFuncref(a:X), a:000)
endfunction

""
" @function getattr(...)
" Get the attribute {name} from {obj}.
" >
"   getattr(obj, name[,default]) -> attribute name of obj, fall back on
"   default.
" <
function! object#protocols#getattr(obj, name, ...)
  call object#util#ensure_argc(1, a:0)
  let obj = maktaba#ensure#IsDict(a:obj)
  let name = maktaba#ensure#IsString(a:name)
  let getter = has_key(obj, '__getattribute__') ?
        \ 'object#protocols#call(obj.__getattribute__, name)'
        \ : 'object#protocols#dict_lookup(obj, name)'
  try
    let val = eval(getter)
  catch /AttributeError/
    if has_key(obj, '__getattr__')
      try
        let val = object#protocols#call(obj.__getattr__, name)
      catch /AttributeError/
        if a:0 == 1
          let val = a:1
        else
          throw v:exception
        endif
      endtry
    elseif a:0 == 1
      let val = a:1
    else
      throw v:exception
    endif
  endtry
  return val
endfunction

function! object#protocols#dict_lookup(d, key)
  if has_key(a:d, a:key)
    return a:d[a:key]
  endif
  throw object#AttributeError('object has no attribute %s', string(a:key))
endfunction

""
" @function setattr(...)
" Set the {name} attribute of {obj} to {val}.
" >
"   setattr(obj, name, val) -> set attribute name of obj to val
" <
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
" @function hasattr(...)
" Test whether {obj} has attribute {name}.
" >
"   hasattr(obj, name) -> if obj has attribute name.
" <
" Return false if {obj} is not a |Dict|.
function! object#protocols#hasattr(obj, name)
  let name = maktaba#ensure#IsString(a:name)
  return maktaba#value#IsDict(a:obj) && has_key(a:obj, name)
endfunction

""
" @function repr(...)
" Generate string representation for {obj}.
" >
"   repr(obj) -> String
" <
" Fail back on |string()|.
function! object#protocols#repr(obj)
  if object#class#is_valid_class(a:obj)
    return printf('<type %s>', string(a:obj.__name__))
  endif
  if object#protocols#hasattr(a:obj, '__repr__')
    return maktaba#ensure#IsString(object#protocols#call(a:obj.__repr__))
  endif
  if maktaba#value#IsList(a:obj)
    return object#list#repr(a:obj)
  endif
  if maktaba#value#IsDict(a:obj)
    return object#dict#repr(a:obj)
  endif
  return string(a:obj)
endfunction

""
" @function len(...)
" Return the length of {obj}.
" >
"   len(String, List or Dict) -> len(obj)
"   len(obj) -> obj.__len__()
" <
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
" @function dir(...)
" Return a |List| of names of all attributes from {obj}. If
" {obj} defines __dir__(), it is called instead.
" >
"   dir(obj) -> a list of names of attributes of obj.
" <
function! object#protocols#dir(obj)
  let obj = maktaba#ensure#IsDict(a:obj)
  if !has_key(obj, '__dir__')
    return keys(obj)
  endif
  return maktaba#ensure#IsList(object#protocols#call(obj.__dir__))
endfunction

""
" @function contains(...)
" Test whether {item} is in {obj}.
" >
"   contains(item, obj) -> item in obj.
" <
function! object#protocols#contains(item, obj)
  if maktaba#value#IsList(a:obj)
    return index(a:obj, a:item) >= 0
  endif
  if maktaba#value#IsString(a:obj)
    return stridx(a:obj, maktaba#ensure#IsString(a:item)) >= 0
  endif
  if object#hasattr(a:obj, '__contains__')
    return maktaba#ensure#IsBool(
          \ object#protocols#call(a:obj.__contains__, a:item))
  endif
  if maktaba#value#IsDict(a:obj)
    return has_key(a:obj, maktaba#ensure#IsString(a:item))
  endif
  return 0
endfunction
