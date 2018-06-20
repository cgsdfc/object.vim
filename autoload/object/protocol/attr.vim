" Attribute getting, setting, testing and listing.

" VARIABLE: Some names ignored by dir(). {{{1
" NOTE: Python3 says some names will be missing, which will be
" different from release to release.
" We only filter some common patterns like __mro__.
let s:dir_ignored = ['__mro__', '__bases__', '__base__', '__name__',]
" }}}1

" FUNCTION: CheckAttrName() {{{1
function! object#protocol#attr#CheckAttrName(func, name)
  if object#builtin#IsString(a:name)
    return a:name
  endif
  call object#TypeError("%s(): attribute name must be string, not '%s'",
        \ a:func, object#builtin#TypeName(a:name))
endfunction
"}}}1

" FUNCTION: getattr() {{{1
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
function! object#protocol#attr#getattr(obj, name, ...)
  call object#builtin#TakeAtMostOptional('getattr', 1, a:0)
  let obj = object#builtin#CheckObj('getattr', 1, a:obj)
  let name = object#protocol#attr#CheckAttrName('getattr', a:name)

  try
    if has_key(obj, '__getattribute__')
      let Val = object#builtin#Call(obj.__getattribute__, name)
    else
      let Val = object#protocol#attr#dict_lookup(obj, name)
    endif
  catch /AttributeError/
    if has_key(obj, '__getattr__')
      try
        let Val = object#builtin#Call(obj.__getattr__, name)
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

function! object#protocol#attr#dict_lookup(obj, key)
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
"}}}1

" FUNCTION: setattr() {{{1
""
" @function setattr(...)
" Set the {name} attribute of {obj} to {val}.
" >
"   setattr(plain dict, name, val) -> let d[name] = val
"   setattr(obj, name, val) -> obj.__setattr__(name, val)
" <
function! object#protocol#attr#setattr(obj, name, val)
  " TODO: __setattr__ for class to validate val.
  " Use metaclass's __setattr__ for a class.
  let obj = object#builtin#CheckObj('setattr', 1, a:obj)
  let name = object#protocol#attr#CheckAttrName('setattr', a:name)

  " NOTE: Currently, special attrs not not lookuped through
  " getattr().
  if has_key(obj, '__setattr__')
    call object#builtin#Call(obj.__setattr__, name, a:val)
  else
    let obj[name] = a:val
  endif
endfunction
"}}}1

" FUNCTION: hasattr() {{{1
""
" @function hasattr(...)
" Test whether {obj} has attribute {name}.
" >
"   hasattr(obj, name) -> getattr(obj, name) succeeds or not.
" <
" @throws WrongType if {name} is not a String.
" @throws WrongType if {obj} is not a Dict.
function! object#protocol#attr#hasattr(obj, name)
  let obj = object#builtin#CheckObj('hasattr', 1, a:obj)
  let name = object#protocol#attr#CheckAttrName('hasattr', a:name)
  try
    call object#getattr(obj, name)
    " NOTE: Only AttributeError is concerned.
  catch 'AttributeError'
    return 0
  endtry
  return 1
endfunction
"}}}1

" FUNCTION: dir() {{{1
""
" @function dir(...)
" Return a |List| of names of all attributes from {obj}. If
" {obj} defines __dir__(), it is called instead.
" >
"   dir(obj) -> list of attribute names.
" <
function! object#protocol#attr#dir(obj)
  let obj = object#builtin#CheckObj('dir', 1, a:obj)
  if has_key(obj, '__dir__')
    let names = object#builtin#Call(obj.__dir__)
    return sort(object#list(names))
  endif

  " TODO: differentiate module, class and object.
  " TODO: When we have classmethod/staticmethod, do something here.
  " TODO: dir() returns keys of current module (#7)
  let dict = copy(obj)
  if has_key(obj, '__mro__')
    call extend(dict, obj.__class__, 'keep')
  endif
  return sort(keys(filter(dict, 'index(s:dir_ignored, v:key)<0')))
endfunction
"}}}1

" vim: set sw=2 sts=2 et fdm=marker:
