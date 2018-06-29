let s:super = object#class('super')

function! s:super.__new__(type, obj)
  " @function super(...)
  " Return a super object bound to {obj} that delegates method calls to the parents and
  " siblings of {type}.
  " >
  "   super(type, obj) -> bound super object
  " <
  " @throws TypeError if object#isinstance({obj}, {type}) is false.
  " @throws TypeError if {type} is at the end of the MRO of {obj}.

  " TODO: if we have __new__()
  let type = object#Lib#vaule#CheckType(a:type)
  let obj = object#Lib#value#CheckObj(a:obj)

  if !has_key(obj, '__super__')
    let obj.__super__ = {}
  endif
  if has_key(obj.__super__, type.__name__)
    for cache in obj.__super__[type.__name__]
      if cache.__thisclass__ is# type
        return cache
      endif
    endfor
  else
    let obj.__super__[type.__name__] = []
  endif

  let [idx, N, mro] = object#class#super#find_super(type, obj)
  let super = object#new(s:super, type, obj, idx, N, mro)
  call add(obj.__super__[type.__name__], super)

  return super
endfunction

function! object#class#super#find_super(type, obj)
  " Find the super based on find_class().
  " Check for various failures.
  let idx = object#class#find_class(a:type, a:obj.__class__)
  if idx < 0
    call object#TypeError('isinstance(type, obj) required')
  endif

  let idx += 1
  let mro = a:obj.__class__.__mro__
  let N = len(mro)
  if N == idx
    call object#TypeError('%s object has no superclass', object#types#name(a:obj))
  endif
  return [idx, N, mro]
endfunction

function! s:super.__init__(type, obj, start, end, mro)
  let self.__self__ = a:obj
  let self.__self_class__ = a:obj.__class__
  let self.__thisclass__ = a:type
  let i = a:start

  while i < a:end
    let methods = object#class#methods(a:mro[i])
    let rebind = map(methods, 'function("object#class#super#call", [v:val], self)')
    " Force out the methods of super derived from object.
    " If we don't do that, methods like __init__(), __repr__() can't be
    " forwarded.
    call extend(self, rebind, i == a:start ? 'force' : 'keep')
    let i += 1
  endwhile
endfunction

function! object#class#super#call(X, ...) dict
  " High ordered function that take a Funcref X and apply args to it
  " with dict bound to __self__.
  return call(a:X, a:000, self.__self__)
endfunction

function! object#class#super#super_(type, obj, name)
  " @function super_(...)
  " Retrieve method {name} bound to {obj} from the parent or sibling of {type}.
  " >
  "   super_(type, obj, name) -> Funcref
  " <
  " The MRO of {obj} is visited started from {type} and the first attribute with
  " {name} that is a |Funcref|, i.e., the first method, is returned.
  "
  " @throws TypeError if object#isinstance({obj}, {type}) is false.
  " @throws TypeError if {type} is at the end of the MRO of {obj}.
  " @throws AttributeError if {name} cannot be resolved.
  let type = object#class#ensure_class(a:type)
  let obj = object#class#ensure_object(a:obj)
  let name = object#util#ensure_identifier(a:name)

  let [idx, N, mro] = object#class#super#find_super(type, obj)

  while idx < N
    if has_key(mro[idx], name) && maktaba#value#IsFuncref(mro[idx][name])
      return function(mro[idx][name], obj)
    endif
    let idx += 1
  endwhile

  call object#AttributeError('cannot resolve attribute %s', string(name))
endfunction
