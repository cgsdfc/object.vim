""
" @section Protocols, protocols
" A set of basic hookable functions that inspect and operate on different
" properties of an object. A protocol in this context means an global function
" that has well defined behaviours for built-in types and can be overriden by
" the corresponding methods with double underscores names.

let s:dir_ignored = ['__mro__', '__bases__', '__base__', '__name__',]

" FUNCTION: Attribute getting, setting, testing and listing. {{{1
function! object#protocol#CheckAttrName(func, name)
  if object#builtin#IsString(a:name)
    return a:name
  endif
  call object#TypeError("%s(): attribute name must be string, not '%s'",
        \ a:func, object#builtin#TypeName(a:name))
endfunction

""
" @function getattr(...)
" Get the attribute {name} from {obj}.
" >
"   getattr(obj, name[,default]) -> attribute of obj
" <
" `getattr()` goes through three stages to lookup an attribute:
" 1. Dictionary lookup `obj[name]`. If `__getattribute__()` is defined for {obj},
"   it will be called instead.
" 2. If 1 fails with `AttributeError` and if `__getattr__()` is defined
"   for {obj}, it will be tried. Otherwise, 2 fails.
" 3. If 2 fails, and if [default] is given, it will be returned.
"   Otherwise, the latest `AttributeError` is thrown.
function! object#protocols#getattr(obj, name, ...)
  call object#builtin#TakeAtMostOptional('getattr', 1, a:0)
  let obj = object#builtin#CheckObj('getattr', 1, a:obj)
  let name = object#protocol#CheckAttrName('getattr', a:name)

  let getter = has_key(obj, '__getattribute__') ?
        \ 'object#builtin#CallProtocolMethodVarargs(obj.__getattribute__, name)'
        \ : 'object#protocols#dict_lookup(obj, name)'
  try
    let Val = eval(getter)
  catch /AttributeError/
    if has_key(obj, '__getattr__')
      try
        let Val = object#builtin#CallProtocolMethodVarargs(obj.__getattr__, name)
      catch /AttributeError/
        if a:0 == 1
          let Val = a:1
        else
          throw v:exception
        endif
      endtry
    elseif a:0 == 1
      let Val = a:1
    else
      throw v:exception
    endif
  endtry
  return Val
endfunction

function! object#protocols#dict_lookup(obj, key)
  try
    let Val = a:obj[a:key]
  catch /E716/
    if has_key(a:obj, '__mro__')
      call object#AttributeError("type object %s has no attribute '%s'",
            \ a:obj.__name__,  a:key)
    else
      call object#AttributeError("'%s' object has no attribute '%s'",
            \ object#builtin#TypeName(a:obj),  a:key)
    endif
  endtry
  return Val
endfunction

""
" @function setattr(...)
" Set the {name} attribute of {obj} to {val}.
" >
"   setattr(plain dict, name, val) -> let d[name] = val
"   setattr(obj, name, val) -> obj.__setattr__(name, val)
" <
function! object#protocols#setattr(obj, name, val)
  let obj = object#builtin#CheckObj('setattr', 1, a:obj)
  let name = object#protocol#CheckAttrName('setattr', a:name)

  " NOTE: Currently, special attrs not not lookuped through
  " getattr().
  if has_key(obj, '__setattr__')
    call object#builtin#CallProtocolMethodVarargs(obj.__setattr__,
          \  name, a:val)
  else
    let obj[name] = a:val
  endif
endfunction

""
" @function hasattr(...)
" Test whether {obj} has attribute {name}.
" >
"   hasattr(obj, name) -> getattr(obj, name) succeeds or not.
" <
" @throws WrongType if {name} is not a String.
" @throws WrongType if {obj} is not a Dict.
function! object#protocols#hasattr(obj, name)
  let name = object#protocol#CheckAttrName('hasattr', a:name)
  try
    call object#getattr(a:obj, name)
  catch
    return 0
  endtry
  return 1
endfunction

""
" @function dir(...)
" Return a |List| of names of all attributes from {obj}. If
" {obj} defines __dir__(), it is called instead.
" >
"   dir(obj) -> list of attribute names.
" <
function! object#protocols#dir(obj)
  let obj = object#builtin#CheckObj('dir', 1, a:obj)
  if has_key(obj, '__dir__')
    let names = object#builtin#CallProtocolMethodVarargs(obj.__dir__)
    return sort(object#list(names))
  endif

  " TODO: differentiate module, class and object.
  let dict = copy(obj)
  let cls = has_key(obj, '__mro__') ? obj : obj.__class__
  if obj isnot cls
    call extend(dict, cls, 'keep')
  endif
  for x in cls.__bases__
    call extend(dict, x, 'keep')
  endfor
  " NOTE: Python3 says some names will be missing, which will be
  " different from release to release.
  " We only filter some common patterns like __mro__.
  return sort(keys(filter(dict, 'index(s:dir_ignored, v:key)<0')))
endfunction

"}}}1

""
" @function repr(...)
" Generate string representation for {obj}.
" >
"   repr(obj) -> String
" <
" Fail back on |string()|.
function! object#protocols#repr(obj)
  if object#class#is_valid_class(a:obj)
    return printf('<class %s>', string(a:obj.__name__))
  endif
  if maktaba#value#IsList(a:obj)
    return object#list#repr(a:obj)
  endif
  if maktaba#value#IsDict(a:obj)
    if has_key(a:obj, '__repr__')
      return maktaba#ensure#IsString(object#protocols#call(a:obj.__repr__))
    else
      return object#dict#repr(a:obj)
    endif
  endif
  return string(a:obj)
endfunction

" FUNCTION: Sequence protocols: len(), contains() {{{1
""
" @function len(...)
" Return the length of {obj}.
" >
"   len(String, List or Dict) -> len(obj)
"   len(obj) -> obj.__len__()
" <
function! object#protocols#len(obj)
  if maktaba#value#IsString(a:obj) || maktaba#value#IsList(a:obj)
    return len(a:obj)
  endif
  if maktaba#value#IsDict(a:obj)
    if has_key(a:obj, '__len__')
      return maktaba#ensure#IsNumber(object#protocols#call(a:obj.__len__))
    else
      return len(a:obj)
    endif
  endif
  call object#except#not_avail('len', a:obj)
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
  if maktaba#value#IsDict(a:obj)
    if has_key(a:obj, '__contains__')
      return maktaba#ensure#IsBool(
            \ object#protocols#call(a:obj.__contains__, a:item))
    else
      return has_key(a:obj, maktaba#ensure#IsString(a:item))
    endif
  endif
  call object#except#not_avail('contains', a:obj)
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
