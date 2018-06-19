""
" @section Protocols, protocols
" A set of basic hookable functions that inspect and operate on different
" properties of an object. A protocol in this context means an global function
" that has well defined behaviours for built-in types and can be overriden by
" the corresponding methods with double underscores names.

" VARIABLE: Some names ignored by dir().
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

" FUNCTION: repr() {{{1
""
" @function repr(...)
" Generate string representation for {obj}. Fail back on |string()|.
" >
"   repr(obj) -> String
" <
function! object#protocols#repr(obj)
  let obj = object#builtin#CheckObj('repr', 1, a:obj)
  if has_key(obj, '__mro__')
    " TODO: In terms of metaclass, we should use:
    " obj.__class__.__repr__
    return printf("<class '%s'>", obj.__name__)
  endif

  if object#builtin#IsList(obj)
    return object#list#repr(obj)
  endif

  " TODO: When obj is a Funcref, we can detect its dict
  " to find whether it is a bound-method, unbound-method
  " or plain function. The string(obj.__init__) is too ugly
  " to accept.

  if object#builtin#IsDict(obj)
    if has_key(obj, '__repr__')
      let string = object#builtin#CallProtocolMethodVarargs(obj.__repr__)
      if object#builtin#IsString(string)
        return string
      endif
      call object#TypeError('__repr__ returned non-string (type %s)',
            \ object#builtin#TypeName(string))
    else
      return object#dict#repr(obj)
    endif
  endif
  " Number, Float, String, Job and Channel, and Special.
  return string(obj)
endfunction

" FUNCTION: Sequence protocols: len(), in() {{{1
""
" @function len(...)
" Return the length of {obj}.
" >
"   len(String, List or Dict) -> len(obj)
"   len(obj) -> obj.__len__()
" <
function! object#protocols#len(obj)
  if object#builtin#IsString(a:obj)
    " TODO: Unicode handling.
    return object#str#len(a:obj)
  endif

  if object#builtin#IsList(a:obj)
    return len(a:obj)
  endif

  if object#builtin#IsDict(a:obj)
    if has_key(a:obj, '__len__')
      let number = object#builtin#CallProtocolMethodVarargs(
            \ a:obj.__len__)
      if object#builtin#IsNumber(number)
        return number
      endif
      call object#TypeError("'%s' object cannot be interpreted as an integer",
            \ object#builtin#TypeName(number))
    else
      return len(a:obj)
    endif
  endif
  call object#TypeError("object of type '%s' has no len()",
        \ object#builtin#TypeName(a:obj))
endfunction

""
" @function in(...)
" Test whether {needle} is in {haystack}.
" >
"   in(key, dict) -> has_key(dict, key).
"   in(sub, string) -> sub in string.
"   in(needle, iterable) -> needle in list(iterable).
"   in(needle, obj) -> bool(obj.__contains__(needle)).
" <
function! object#protocols#in(needle, haystack)
  " XXX: operator.contains(haystack, needle).
  " We are inverted.
  " Change the order or use object#in(needle, haystack).
  if object#builtin#IsList(a:haystack)
    return object#list#contains(a:haystack, a:needle)
  endif

  if object#builtin#IsString(a:haystack)
    return object#str#contains(a:haystack, a:needle)
  endif

  if object#builtin#IsDict(a:haystack)
    if has_key(a:haystack, '__contains__')
      let answer = object#builtin#CallProtocolMethodVarargs(
            \ a:haystack.__contains__(a:needle))
      " NOTE: return value of __contains__() is a bool context.
      return object#bool(answer)
    elseif has_key(a:haystack, '__iter__')
      let iter = object#iter(a:haystack)
      try
        while 1
          " TODO: use object#eq()
          if maktaba#value#IsEqual(a:needle, object#next(iter))
            return 1
          endif
        endwhile
      catch 'StopIteration'
        return 0
      endtry
    else " Plain dict.
      return has_key(a:haystack, a:needle)
    endif
  endif
  call object#TypeError("argument of type '%s' is not iterable",
        \ object#builtin#TypeName(a:haystack))
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
