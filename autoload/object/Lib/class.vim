let s:builtins = object#Lib#builtins#GetModuleDict()
let s:object = s:builtins.object
let s:None = s:builtins.None
let s:type = s:builtins.type

let s:new_ignored = [
      \ '__class__',
      \ '__base__',
      \ '__name__',
      \ '__bases__',
      \ '__mro__',
      \ '__super__',
      \ '__self__',
      \ '__classmethods__',
      \ '__staticmethods__',
      \]

function! s:TransformAttro(type, key, val) "{{{1
  if !object#Lib#value#IsFuncref(a:val)
    return a:val
  endif
  if has_key(a:type.__classmethods__, a:key)
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

function! object#Lib#class#Object_New(type, ...)
  return object#Lib#class#Object_New_(a:type, a:000)
endfunction

function! object#Lib#class#SimpleType_New(name, ...)
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

function! object#Lib#class#Type_New(name, bases, dict) abort "{{{1
  " Create a new type
  let metaclass = s:type
  for parent in a:bases
    if has_key(parent, '__metaclass__')
      let metaclass = parent.__metaclass__
      break
    endif
  endfor
  return object#Lib#class#Object_New(metaclass, name, bases, dict)
endfunction

function! object#Lib#class#Type__new__(metaclass, name, bases, dict)
  " Implement type.__new__()
  let type = object#Lib#class#Object__new__(metaclass)
  let type.__name__ = a:name
  let type.__bases__ = copy(a:bases)
  let type.__base__ = a:bases[0]
  let type.__classmethods__ = {}
  let type.__staticmethods__ = {}
  let type.__mro__ = object#Lib#class#CheckMRO(object#Lib#func#CallFuncref(type.mro))
  return type
endfunction

function! object#Lib#class#Object_mro() dict abort "{{{1
  " Implement object.mro()


endfunction

  " if !object#Lib#value#IsString(a:name)
  "   call object#TypeError('class name must be a string')
  " endif
" vim: set sw=2 sts=2 et fdm=marker:
