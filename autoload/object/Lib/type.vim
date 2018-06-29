let s:builtins = object#Lib#builtins#GetModuleDict()

let s:builtin_typemap = [
      \ s:builtins.int,
      \ s:builtins.str,
      \ s:builtins.function,
      \ s:builtins.list,
      \ s:builtins.dict,
      \ s:builtins.float,
      \ s:builtins.bool,
      \ s:builtins.None.__class__,
      \ s:builtins.NotImplemented,
      \ s:builtins.NotImplemented,
      \]

endfunction
function! object#Lib#value#IsType(X) abort "{{{1
  " Whether X is a type
  return object#Lib#value#IsObj(a:X) &&
        \ object#Lib#type#Type__instancecheck__(s:builtins.type, a:X)
endfunction

function! object#Lib#type#IsInMRO(cls, type)
  return object#Lib#seqn#Any(a:type.__mro__, 'a:cls is v:val')
endfunction

function! object#Lib#type#Type__instancecheck__(type, obj) abort "{{{1
  " type.__instancecheck__()
  " By default checks the __mro__.
  return object#Lib#type#IsInMRO(a:obj.__class__, a:type)
endfunction

function! object#Lib#type#Type__subclasscheck__(type, subclass) abort "{{{1
  " type.__subclasscheck__()
  return object#Lib#type#IsInMRO(a:subclass, a:type)
endfunction

function! s:builtins.isinstance(obj, classinfo) "{{{1
  if !object#Lib#type#IsType(a:classinfo)
    call object#TypeError("isinstance() arg 2 must be a type")
  endif
  return object#Lib#func#CallFuncref(a:classinfo.__instancecheck__, a:obj)
endfunction

function! s:builtins.issubclass(cls, classinfo) "{{{1
  if !object#Lib#type#IsType(a:cls)
    call object#TypeError("issubclass() arg 1 must be a class")
  endif
  if !object#Lib#type#IsType(a:classinfo)
    call object#TypeError("issubclass() arg 2 must be a class")
  endif
  return object#Lib#func#CallFuncref(a:classinfo.__subclasscheck__, a:cls)
endfunction

function! object#Lib#type#CheckBases(bases) abort "{{{1
  let seen = {}
  for B in a:bases
    if !object#Lib#value#IsType(B)
      call object#TypeError("base class should be type, not %s",
            \ object#Lib#value#TypeName(B))
    endif
    if has_key(B, '__final__') && B.__final__ == 1
      call object#TypeError("type '%s' is not an acceptable base type",
            \ B.__name__)
    endif
    if has_key(seen, B.__name__)
      call object#TypeError("duplicate base class %s", B.__name__)
    endif
    let seen[B.__name__] = 1
  endfor
  return a:bases
endfunction

function! object#Lib#type#Object_mro() dict abort "{{{1
  " Implement classmethod object.mro()
  if len(self.__bases__) == 1
    return [self] + self.__base__.__mro__
  endif
  let candidates = [copy(self.__bases__)]
  let candidates += map(copy(self.__bases__), 'copy(v:val.__mro__)')
  let MRO = [self]
  while 1
    call filter(candidates, '!empty(v:val)')
    if empty(candidate)
      return MRO
    endif
    for seqn in candidates
      let next = seqn[0]
      if !object#Lib#seqn#Any(candidates,
            \ 's:InTail(next, v:val)')
        break
      endif
      let next = 0
    endfor
    if next is 0
      call object#TypeError(
            \ "Cannot create a consistent method resolution order\n(MRO) for bases %s, %s",
            \ MRO[-1].__name__, next.__name__)
    endif
    call add(MRO, next)
    for seqn in candidates
      if seqn[0] is next
        unlet seqn[0]
      endif
    endfor
  endwhile
endfunction

function! object#Lib#type#Type_New(name, bases, dict) abort "{{{1
  " Create a new type
  let base = object#Lib#type#CheckBases(a:bases)
  let metaclass = s:type
  for parent in a:bases
    if has_key(parent, '__metaclass__')
      let metaclass = parent.__metaclass__
      break
    endif
  endfor
  return object#Lib#type#Object_New(metaclass, name, bases, dict)
endfunction

function! object#Lib#type#CheckMRO(mro) abort "{{{1
  if object#Lib#value#IsList(a:mro)
    return a:mro
  endif
  call object#TypeError('mro() should return a list, not %s',
        \ object#Lib#value#TypeName(a:mor))
endfunction

function! object#Lib#type#Type__new__(metaclass, name, bases, dict) abort "{{{1
  " Implement type.__new__()
  let type = object#Lib#class#Object__new__(metaclass)
  let type.__name__ = a:name
  let type.__bases__ = copy(a:bases)
  let type.__base__ = a:bases[0]
  let type.__classmethods__ = {}
  let type.__staticmethods__ = {}
  let type.__mro__ = object#Lib#type#CheckMRO(object#Lib#func#CallFuncref(type.mro))
  call extend(type, dict, 'force')
  return type
endfunction

function! object#Lib#type#GetType(obj)
  if object#Lib#value#IsObj(a:obj)
    return a:obj.__class__
  endif
  return s:builtin_typemap[type(a:obj)]
endfunction

function! s:builtins.type(...) "{{{1
  if a:0 != 1 && a:0 != 3
    call object#TypeError("type() takes 1 or 3 arguments")
  endif
  if a:0 == 1
    return object#Lib#type#GetType(a:1)
  endif
  return call('object#Lib#type#Type__new__', a:000)
endfunction
" vim: set sw=2 sts=2 et fdm=marker:
