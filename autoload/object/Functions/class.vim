let s:object_class = object#object_()
let s:type_class = object#type_()
let s:None = object#None()

let s:special_attrs = ['__class__', '__base__', '__name__', '__bases__', '__mro__']
" }}}1

""
" @function class(...)
" Define a class that has a {name} and [bases] and optionally
" insert it into [scope].
" >
"   class(name) -> inherited from object
"   class(name, bases) -> inherited from bases
"   class(name, bases, scope) -> scope[name] = cls
" <
" {name} should be a |String| of valid identifier.
" [bases] should be a class or a |List| of classes.
" If no [bases] are given or [bases] is an empty |List|,
" the new class will subclass `object`.
function! object#class#class(name, ...)
  call object#builtin#TakeAtMostOptional('class', 2, a:0)
  if !object#builtin#IsString(a:name)
    call object#SyntaxError('class name must be string')
  endif
  if a:0 == 2
    let scope = object#builtin#CheckDict('class', 3, a:2)
    if has_key(scope, a:name)
      return
    endif
  endif

  " Figure out the bases list
  " TODO: call __new__ of metaclass of base.
  if !a:0
    let bases = []
  elseif object#builtin#IsDict(a:1)
    let bases = [a:1]
  else
    let bases = a:1
  endif

  let cls = {
        \ '__class__' : s:type_class,
        \}
  call object#class#class_init(cls, a:name, bases)
  if a:0 == 2
    let scope[a:name] = cls
  endif
  return cls
endfunction

""
" @function new(...)
" Create a new instance of {cls}.
" >
"   new(cls[, args]) -> a new instance of cls
" <
function! object#class#new(cls, ...)
  return object#class#new_(a:cls, a:000)
endfunction

""
" @function new_(...)
" Create a new instance of {cls}.
" >
"   new_(cls, args) -> a new instance of cls
" <
function! object#class#new_(cls, args)
  let args = object#builtin#CheckList('new', 2, a:args)
  let cls = object#class#ensure_class(a:cls)
  let obj = {
        \ '__class__': cls,
        \ }
  call extend(obj, object#class#methods(cls))
  call call(obj.__init__, args)
  return obj
endfunction

""
" @function type(...)
" Return the type of an object or create a new type.
" >
"   type(obj) -> the type of obj
"   type(name, bases, dict) -> a new type.
" <
function! object#class#type(...)
  if a:0 == 1
    return object#class#ensure_object(a:1).__class__
  endif
  if a:0 == 3
    return object#new_(s:type_class, a:000)
  endif
  call object#TypeError('type() takes 1 or 3 arguments (%d given)', a:0)
endfunction

""
" @function isinstance(...)
" Return whether {obj} is an instance of {cls}.
" >
"   isinstance(obj, cls) -> if obj is an instance of cls
" <
function! object#class#isinstance(obj, cls)
  return object#class#is_valid_object(a:obj) &&
        \ object#class#is_valid_class(a:cls) &&
        \ object#class#find_class(a:cls, a:obj.__class__) >= 0
endfunction

""
" @function issubclass(...)
" Return whether {cls} is a subclass of {base}.
" >
"   issubclass(cls, base) -> if cls is a subclass of base
" <
function! object#class#issubclass(cls, base)
  return object#class#is_valid_class(a:cls) &&
        \ object#class#is_valid_class(a:base) &&
        \ object#class#find_class(a:base, a:cls) >= 0
endfunction


"
" A valid class is a valid object that has __mro__
"
function! object#class#is_valid_class(x)
  return object#class#is_valid_object(a:x) && has_key(a:x, '__mro__')
endfunction

"
" Every valid object is a |Dict| with a __class__ attribute.
"
function! object#class#is_valid_object(x)
  return object#builtin#IsDict(a:x) && has_key(a:x, '__class__')
endfunction

"
" A method is a |Funcref| attribute.
"
function! object#class#is_method(Key, Val)
  let Key = object#util#ensure_identifier(a:Key)
  return index(s:special_attrs, Key) < 0 && object#builtin#IsFuncref(a:Val)
endfunction

"
" Extract methods from {cls}.
" {cls} will be copied first.
"
function! object#class#methods(cls)
  return filter(copy(a:cls), 'object#class#is_method(v:key, v:val)')
endfunction

" Ensure that {x} is one valid class or a list of
" non-duplicate classes.
function! object#class#ensure_bases(bases)
  call object#builtin#CheckList('ensure_bases', 1, a:bases)
  let bases = a:bases
  let N = len(bases)
  let i = 0
  while i < N-1
    let j = i + 1
    while j < N
      call object#class#ensure_class(bases[i])
      if bases[i] isnot# bases[j]
        let j += 1
        continue
      endif
      call object#TypeError('duplicate base class %s', string(bases[i].__name__))
    endwhile
    let i += 1
  endwhile
  return bases
endfunction

"
" Initialize a class with {name}, {bases} and a {dict} of attributes.
"
function! object#class#type_init(cls, name, bases, dict)
  let dict = object#builtin#CheckDict('type', 4, a:dict)
  call object#class#class_init(a:cls, a:name, a:bases)
  call extend(a:cls, object#class#methods(dict), 'force')
endfunction

"
" Initialize various special attributes of a class.
"
function! object#class#class_init(cls, name, bases)
  let a:cls.__name__ = object#util#ensure_identifier(a:name)
  if empty(a:bases)
    let a:cls.__bases__ = [s:object_class]
  elseif len(a:bases) == 1
    let a:cls.__bases__ = [object#class#ensure_class(a:bases[0])]
  else
    let a:cls.__bases__ = copy(object#class#ensure_bases(a:bases))
  endif
  let a:cls.__base__ = a:cls.__bases__[0]
  if len(a:bases) == 1
    let a:cls.__mro__ = [a:cls] + a:bases[0].__mro__
  else
    let a:cls.__mro__ = object#class#mro(a:cls)
  endif
  for x in a:cls.__mro__
    call extend(a:cls, object#class#methods(x), 'keep')
  endfor
endfunction

" Compute Method Resolution Order for {cls}.
function! object#class#mro(cls)
  let bases = copy(a:cls.__bases__)
  let bases_mro = map(copy(bases), 'copy(v:val.__mro__)')
  let mro = object#class#merge(add(bases_mro, copy(bases)))
  if mro isnot# 0
    " Since cls by no means can appear in bases or bases_mro,
    " it is safe to prepend it to the merged list.
    return insert(mro, a:cls)
  endif
  call object#TypeError(
        \ 'cannot create a consistent method resolution for bases %s',
        \ join(map(bases, 'v:val.__name__'), ', '))
endfunction

"
" Whether {cls} appears at the tail of {list}.
" The tail of a list is all the elements except the first one.
"
function! object#class#in_tail(cls, list, len)
  let i = 1
  while i < a:len
    if a:cls is# a:list[i]
      return 1
    endif
    let i += 1
  endwhile
  return 0
endfunction

"
" Merge the {list} of candidates in a C3 manner.
"
function! object#class#merge(list)
  let res = []
  let list = a:list
  while 1
    let list = filter(list, '!empty(v:val)')
    if empty(list)
      return res
    endif
    for x in list
      let cand = x[0]
      for y in list
        if object#class#in_tail(cand, y, len(y))
          let cand = 0
          break
        endif
      endfor
      if cand isnot# 0
        break
      endif
    endfor
    if cand is# 0
      return cand
    endif
    call add(res, cand)
    for x in list
      if x[0] is# cand
        unlet x[0]
      endif
    endfor
  endwhile
endfunction

function! object#class#ensure_class(x)
  if object#class#is_valid_class(a:x)
    return a:x
  endif
  call object#TypeError('not a valid class')
endfunction

function! object#class#ensure_object(x)
  if object#class#is_valid_object(a:x)
    return a:x
  endif
  call object#TypeError('not a valid object')
endfunction

"
" Find a needle in the __mro__ of haystack.
" Return the index of needle.
" Return -1 if needle is not in haystack
"
function! object#class#find_class(needle, haystack)
  let mro = a:haystack.__mro__
  let i = 0
  let N = len(mro)
  while i < N
    if mro[i] is# a:needle
      return i
    endif
    let i += 1
  endwhile
  return -1
endfunction

" An unchecked version of class() supposed to work faster
" with the large Exception hierarchy.
function! object#class#builtin_class(name, base, scope)
  let bases = [a:base]
  let cls = {
        \ '__name__': a:name,
        \ '__class__': s:type_class,
        \ '__base__': a:base,
        \ '__bases__': bases,
        \}
  let cls.__mro__ = [cls] + a:base.__mro__
  for x in a:base.__mro__
    " TODO: Check for staticmethod/classmethod
    call extend(cls, filter(copy(x), 'object#builtin#IsFuncref(v:val)'), 'keep')
  endfor
  let a:scope[a:name] = cls
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
