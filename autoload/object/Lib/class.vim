let s:builtins = object#Lib#builtins#GetModuleDict()
let s:object = s:builtins.object
let s:None = s:builtins.None
let s:type = s:builtins.type

" Seal away the dictionary of staticmethod.
" Ban `self` from being modified.
let s:STATIC_DICT = {}
lockvar s:STATIC_DICT

let s:implicit_staticmethods = [
      \ '__new__',
      \]

let s:implicit_classmethods = [
      \ '__subclasscheck__',
      \ '__instancecheck__',
      \ '__subclasshook__',
      \ '__init_subclass__',
      \ '__subclasses__',
      \]

" Attros that are not carried to instance or subclass.
let s:ignored_attros = [
      \ '__class__',
      \ '__name__',
      \ '__base__',
      \ '__bases__',
      \ '__mro__',
      \ '__super__',
      \ '__final__',
      \ '__classmethods__',
      \ '__staticmethods__',
      \]


function! s:CallStaticMethod(staticmethod, ...) "{{{1
  return call(a:staticmethod, a:000, s:STATIC_DICT)
endfunction

function! s:CallClassMethod(classmethod, ...) dict "{{{1
  " Forward call to self.__class__.
  return call(a:classmethod, a:000, self.__class__)
endfunction

function! s:IsStaticMethod(type, key, val)
  return index(s:implicit_staticmethods, a:key) >= 0 ||
        \ has_key(a:type.__staticmethods__, a:key) && object#Lib#value#IsFuncref(a:val)
endfunction

function! s:IsClassMethod(type, key, val)
  return index(s:implicit_classmethods, a:key) >= 0 ||
        \ has_key(a:type.__classmethods__, a:key) && object#Lib#value#IsFuncref(a:val)
endfunction

function! s:MapInstanceAttros(type, key, val) "{{{1
  if s:IsClassMethod(a:type, a:key, a:val)
    return function('s:CallClassMethod', [a:val])
  endif
  if s:IsStaticMethod(a:type, a:key, a:val)
    return function('s:CallStaticMethod', [a:val])
  endif
  return a:val
endfunction

function! s:CheckType(X) abort "{{{1
  if object#Lib#type#IsType(a:X)
    return a:X
  endif
  call object#TypeError("%s in not a type object",
        \ object#Lib#value#TypeName(a:X))
endfunction


function! object#Lib#class#MROAttros(mro) "{{{1
  " Return initial attros of `type`.
  let attros = {
        \ '__classmethods__': {},
        \ '__staticmethods__': {},
        \}
  for parent in a:mro
    call extend(a:attros.__classmethods__, parent.__classmethods__, 'keep')
    call extend(a:attros.__staticmethods__, parent.__staticmethods__, 'keep')
    call extend(attros, filter(copy(parent),
          \ 'index(s:ignored_attros, v:key)<0)'), 'keep')
  endfor
  return attros
endfunction

function! object#Lib#class#InstanceAttros(type) abort "{{{1
  " Return attros of `type` that can be put into its instances.
  return map(filter(copy(a:type), 'index(s:ignored_attros, v:key)<0'),
        \ 's:MapInstanceAttros(a:type, v:key, v:val)')
endfunction

function! object#Lib#class#TypeAttros(type) abort "{{{1
  return filter(copy(a:type), 'index(s:ignored_attros, v:key)<0')
endfunction

function! object#Lib#class#Object__new__(type) abort " {{{1
  " Implement object.__new__().
  " The signature of `__new__()` is normally `__new__(cls, ...)`
  " but since only `type` is concerned here, we omitted `...`.
  let obj = object#Lib#class#InstanceAttros(a:type)
  let obj.__class__ = a:type
  return obj
endfunction

function! object#Lib#class#Object_New_(type, args) abort "{{{1
  " `type(*args)` => object of type.
  let type = s:CheckType(a:type)
  let obj = object#Lib#func#CallFuncref_(type.__new__, [a:type] + a:args)
  if obj.__class__ is a:type
    let v = object#Lib#func#CallFuncref_(a:obj.__init__, a:args)
    if v isnot 0
      call object#TypeError("__init__() should return 0, not '%s'",
            \ object#Lib#value#TypeName(v))
    endif
  endif
  return obj
endfunction

function! object#Lib#class#Object_New(type, ...) abort "{{{1
  return object#Lib#class#Object_New_(a:type, a:000)
endfunction

function! object#Lib#class#GetIgnoredAttros() abort "{{{1
  return s:ignored_attros
endfunction

function! object#Lib#class#FastType_New(name, ...) abort "{{{1
  " Create a new type as fast as possible taking advantages that
  " the type has single inheritance and user should make sure they
  " supply correct arguments (NO CHECKING).
  let base = a:0 ? a:1 : s:object
  let type = object#Lib#class#TypeAttros(base.__mro__)
  let type.__name__ = a:name
  let type.__class__ = s:type
  let type.__base__ = base
  let type.__bases__ = [base]
  let type.__mro__ = [type] + base.__mro__
  return type
endfunction

function! s:builtins.class(name, ...) "{{{1
  " Create a new class.
  " class(name,[base]) -> a new class
  call object#Lib#value#TakeAtMostOptional('class', 1, a:0)
  let name = object#Lib#value#CheckString('class', 1, a:name)
  if a:0 == 0
    let bases = [s:object]
  elseif object#Lib#value#IsList(a:1)
    let bases = a:1
  else
    let bases = [a:1]
  endif
  return object#Lib#type#Type_New(name, bases, {})
endfunction

function! s:builtins.new(type, ...) "{{{1
  " Create a new object.
  " new(type, *args) ->  a new object.
  return object#Lib#class#Object_New_(a:type, a:000)
endfunction

function! s:builtins.classmethod(type, name)
  call s:CheckType(a:type)
  call object#Lib#value#CheckString2(a:name)
  let a:type.__classmethods__[a:name] = 1
endfunction

function! s:builtins.staticmethod(type, name)
  call s:CheckType(a:type)
  call object#Lib#value#CheckString2(a:name)
  let a:type.__staticmethods__[a:name] = 1
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
