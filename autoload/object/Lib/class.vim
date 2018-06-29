let s:builtins = object#Lib#builtins#GetModuleDict()
let s:object = s:builtins.object
let s:None = s:builtins.None
let s:type = s:builtins.type

let s:implicit_classmethods = [ "{{{1
      \ '__subclasscheck__',
      \ '__instancecheck__',
      \ '__subclasshook__',
      \ '__init_subclass__',
      \ '__subclasses__',
      \]

" Attros that are not carried to instance or subclass.
let s:new_ignored = [ "{{{1
      \ '__class__',
      \ '__base__',
      \ '__name__',
      \ '__bases__',
      \ '__mro__',
      \ '__super__',
      \ '__self__',
      \ '__final__',
      \ '__classmethods__',
      \ '__staticmethods__',
      \]

function! s:TransformAttro(type, key, val) "{{{1
  if !object#Lib#value#IsFuncref(a:val)
    return a:val
  endif
  if index(s:implicit_classmethods, a:key) >= 0 ||
        \ has_key(a:type.__classmethods__, a:key)
    return function('s:CallClassmethod', a:val)
  endif
  return a:val
endfunction

function! s:CallClassmethod(classmethod, ...) dict "{{{1
  return call(a:classmethod, a:000, self.__class__)
endfunction

function! object#Lib#class#ResolveAttro(type) "{{{1
  let attrs = {}
  for parent in a:type.__mro__
    call extend(attrs, map(filter(copy(parent),
          \ 'index(s:new_ignored, v:key)<0)'),
          \ 's:TransformAttro(a:type, v:key, v:val)'),
          \ 'keep')
  endfor
  return attrs
endfunction

function! object#Lib#class#Object__new__(type) abort " {{{1
  " Implement object.__new__().
  let obj = {}
  let obj.__class__ = a:type
  if !has_key(a:type, '__self__')
    let a:type.__self__ = object#Lib#class#ResolveAttro(a:type)
  endif
  call extend(obj, a:type.__self__)
  return obj
endfunction

function! object#Lib#class#Object_New_(type, args) abort "{{{1
  " Create an object of type.
  let type = object#Lib#value#CheckType(a:type)
  let obj = object#Lib#func#CallFuncref_(type.__new__, [type] + a:args)
  if obj.__class__ is type
    if 0 isnot object#Lib#func#CallFuncref_(a:obj.__init__, a:args)
      call object#TypeError("__init__() should return 0, not '%s'",
            \ object#Lib#value#TypeName(v))
    endif
  endif
  return obj
endfunction

function! object#Lib#class#Object_New(type, ...) abort "{{{1
  return object#Lib#class#Object_New_(a:type, a:000)
endfunction

function! object#Lib#class#SimpleType_New(name, ...) abort "{{{1
  let base = a:0 ? a:1 : s:object
  let type = {
        \ '__name__': a:name,
        \ '__class__': s:type,
        \ '__base__': base,
        \ '__bases__': [base],
        \}
  let type.__mro__ = [cls] + base.__mro__
  return type
endfunction

function! s:builtins.class(name, ...) "{{{1
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

function! s:builtins.new(type, ...)
  return object#Lib#class#Object_New_(a:type, a:000)
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
