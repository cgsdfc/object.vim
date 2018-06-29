let s:builtins = object#Lib#builtins#GetModuleDict()

" An array mapping type codes to builtin types.
" such that `s:builtin_typemap[type(0)]` is builtin type `int`.
" Channel and job are `NotImplemented`.
" let s:builtin_typemap = [
"       \ s:builtins.int,
"       \ s:builtins.str,
"       \ s:builtins.function,
"       \ s:builtins.list,
"       \ s:builtins.dict,
"       \ s:builtins.float,
"       \ s:builtins.bool,
"       \ s:builtins.None.__class__,
"       \ s:builtins.NotImplemented,
"       \ s:builtins.NotImplemented,
"       \]

let s:BAD_MRO_MSG =
      \ "Cannot create a consistent method resolution order\n(MRO) for bases %s, %s"

function! s:IsFinal(X)
  " Helper to tell final class.
  return has_key(a:X, '__final__') && a:X.__final__ is 1
endfunction

function! s:CheckType(func, nr, X) abort "{{{1
  " Check that arg `nr` to `func` is a type
  if object#Lib#type#IsType(a:X)
    return a:X
  endif
  call object#TypeError("%s() arg %d must be a type", a:func, a:nr)
endfunction

function! s:IsInMRO(cls, type) abort "{{{1
  " The foundamental tool for all those checking is performing a
  " linear find on `__mro__`. For example, `a` is an instance of `B`
  " means the class of `a`, `A`  derives from `B`, which implies `A`
  " is an subclass of `B`.
  " When it comes to type object things can get complicated in mind.
  " Consider a trivial case, `int` is an instance of `type`. This is
  " because class of `int` is `type`, which is a subclass of itself.
  " Consider a case involving metaclass, `Meta` derives from `type`
  " and `A` sets `Meta` as its metaclass. The class of `A`, which is
  " now `Meta`, derives from `type` so `A` is an instance of `type`.
  " The class of `Meta` is `type`, so `Meta` is an instance of `type`
  " trivially.
  return object#Lib#seqn#Any(a:type.__mro__, 'a:cls is v:val')
endfunction

function! s:CheckBases(bases) abort "{{{1
  " Check that all the bases is acceptable.
  " - No duplicate.
  " - No final class.
  " - Must be a type.
  let seen = {}
  for B in a:bases
    if !object#Lib#type#IsType(B)
      call object#TypeError("base class must be a type, not %s",
            \ object#Lib#value#TypeName(B))
    endif
    if s:IsFinal(B)
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

function! s:InTail(item, seqn)
  " Helper routine of `Object_mro()`.
  " Whether `item` is in the tail of `seqn`.
  if len(a:seqn) == 1
    return 0
  endif
  return object#Lib#seqn#Any(a:seqn[1:], 'a:item is v:val')
endfunction

function! s:CheckMRO(mro) abort "{{{1
  " Check that a customized `mro()` returns something sane.
  " Honestly I don't know how this part of Python works so just
  " impose minimal requirements here.
  if !object#Lib#value#IsList(a:mro)
    call object#TypeError('mro() should return a list, not %s',
          \ object#Lib#value#TypeName(a:mro))
  endif
  let seen = {}
  for B in a:mro
    if !object#Lib#type#IsType(B) ||
          \ s:IsFinal(B) || has_key(seen, B.__name__)
      call object#TypeError("mro() returned base with unsuitable layout")
    endif
    let seen[B.__name__] = 1
  endfor
  return a:mro
endfunction


function! object#Lib#type#IsType(X) abort "{{{1
  " Whether X is a type.
  " An object is a type iff it is an instance of `type`.
  return object#Lib#value#IsObj(a:X) &&
        \ object#Lib#type#Type__instancecheck__(s:builtins.type, a:X)
endfunction

function! object#Lib#type#Type__instancecheck__(type, obj) abort "{{{1
  " type.__instancecheck__()
  return s:IsInMRO(a:obj.__class__, a:type)
endfunction

function! object#Lib#type#Type__subclasscheck__(type, subclass) abort "{{{1
  " type.__subclasscheck__()
  return s:IsInMRO(a:subclass, a:type)
endfunction

function! object#Lib#type#IsInstance(obj, classinfo) "{{{1
  call s:CheckType('isinstance', 2, a:classinfo)
  return object#Lib#func#CallFuncref(a:classinfo.__instancecheck__, a:obj)
endfunction
let s:builtins.isinstance = function('object#Lib#type#IsInstance')

function! object#Lib#type#IsSubclass(cls, classinfo) abort "{{{1
  call s:CheckType('issubclass', 1, a:cls)
  call s:CheckType('issubclass', 2, a:classinfo)
  return object#Lib#func#CallFuncref(a:classinfo.__subclasscheck__, a:cls)
endfunction
let s:builtins.issubclass = function('object#Lib#type#IsSubclass')

function! object#Lib#type#Object_mro() dict abort "{{{1
  " Implement classmethod object.mro()
  " Compute the Method Resolution Order of `self`.
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
      if !object#Lib#seqn#Any(candidates, 's:InTail(next, v:val)')
        break
      endif
      let next = 0
    endfor
    if next is 0
      call object#TypeError(s:BAD_MRO_MSG, MRO[-1].__name__, next.__name__)
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
  " Create a new type with `name`, `bases` and initial attros from `dict`.
  let name = object#Lib#value#CheckString('type', 1, a:name)
  let bases = s:CheckBases(a:bases)
  let dict = object#Lib#value#CheckDict('type', 3, a:dict)
  let metaclass = s:builtins.type
  for parent in a:bases
    if has_key(parent, '__metaclass__')
      let metaclass = parent.__metaclass__
      break
    endif
  endfor
  return object#Lib#class#Object_New(metaclass, name, bases, dict)
endfunction

function! object#Lib#type#Type__new__(metaclass, name, bases, dict) abort "{{{1
  " Implement type.__new__()
  let type = object#Lib#class#TypeAttros(a:metaclass)
  let mro = object#Lib#func#CallFuncref(type.mro)
  if type.mro isnot function('object#Lib#type#Object_mro')
    call s:CheckMRO(mro)
  endif
  let type.__mro__ = mro
  let type.__class__ = a:metaclass
  let type.__name__ = a:name
  let type.__bases__ = copy(a:bases)
  let type.__base__ = a:bases[0]
  call extend(type, object#Lib#class#MROAttros(mro[1:]))
  call extend(type, a:dict)
  return type
endfunction

function! object#Lib#type#GetType(obj)
  if object#Lib#value#IsObj(a:obj)
    return a:obj.__class__
  endif
  " return s:builtin_typemap[type(a:obj)]
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
