""
" @section Super, super
"
" @subsection use-cases-of-two-supers
" Currently two ways to call methods of parents and siblings are provided
" and let's talk about the cases when you may use one of them.
" >
"   super_(type, obj)
" <
" It creates a proxy object delegating almost all the
" method calls to parents and siblings. The super objects are cached in the
" the invoking object, i.e., `__self__` so later calls to `super_()` with
" specific `type` and `obj` effectively retrieves the cached objects. That
" means if you have used a lot of `super()`s in a class, you can use
" `super_()` to speed up. However, since the nature of static method
" resolution, the number of methods of one super object grows linearly to
" the size of the MRO. Since all the classes in the MRO except the first one
" may result in a distinct super object, the total number of methods of those super
" objects is ordered by O(len(MRO)^2), which is always the case when
" cooperative inheritance is in used. Therefore, if you have a somehow
" deep class hierarchy, be careful with the space overhead with the
" instances of those leaf classes, especially when each of your classes has a
" non-trivial number of methods.
" In short, use `super_()` if you densely call different methods of parents
" and siblings while the depth of your class hierarchy is modest.
" >
"   super(type, obj, name)
" <
" It searches the MRO started from the next of `type` and returns the
" first method matching `name`. There isn't any caching behind the sense so
" `__super__` is not created. However, when cooperative inheritance is used,
" a sinle chained call to `super()` results in O(len(MRO)^2) time to resolve
" all the methods along the way. Therefore, if you make sparse calls to
" `super()` and you want to minimize the space of your instances, you may use
" `super()` since the time won't be a problem. However, in present of a
" long MRO and frequent calls to `super()`, you may prefer `super_()`.
"
" You are recommended to use `super_()` at first and only when "Out Of Memory"
" arises should you turn some `super_()` to `super()` because not only the
" syntax of `super_()` looks more nature (more like Python), but the attributes of super objects
" aid inspection. Mixing both of them in
" one single class is not recommended, since both of their benefits may be
" lost (you asked for a cache but you didn't use it).
" However, you can mix them in different classes of one hierarchy,
" especially using `super()` in those leaf classes whose MRO is long.
"
" @subsection caching-super
" To save time, `super_()` caches the super objects of each `type` in each
" `obj` with a special attribute `__super__`. Unlike other special
" attribute like `__mro__`, the structure of this one is kept private, which
" means you should not count on it. In the future, inspection of it may
" be provided.
"
" The current `__super__` keeps a dictionary of all the created super objects
" hashed with the name of their `__thisclass__`. Since different classes can
" have the same name, conflicts are handled by having a list of super objects
" for each name. When the `type` and `obj` have been validated, `super_()`
" consults the cache before going through the MRO. When the cache misses, it
" goes all the way to create a super object and fill in the cache.

""
" @dict super
" An object that forwards method calls to parents or siblings of a type.
"
" Special attributes:
"   * __self__:       the bound object.
"   * __self_class__: type of the bound object.
"   * __thisclass__:  type that got passed to `super_()`.


let s:super = object#type('super', [], {
      \ '__init__': function('object#super#__init__'),
      \ '__repr__': function('object#super#__repr__'),
      \})

""
" Return a super object bound to {obj} that delegates method calls to the parents and
" siblings of {type}.
"
" @throws TypeError if object#isinstance({obj}, {type}) is false.
" @throws TypeError if {type} is at the end of the MRO of {obj}.
function! object#super#super_(type, obj)
  let type = object#class#ensure_class(a:type)
  let obj = object#class#ensure_object(a:obj)

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

  let idx = object#class#find_class(type, obj.__class__)
  if idx < 0
    throw object#TypeError('super_() requires isinstance(type, obj)')
  endif
  if len(obj.__class__.__mro__) - 1 == idx
    throw object#TypeError('%s object has no superclass', object#types#name(obj))
  endif

  let super = object#new(s:super, type, obj, mro[idx+1:])
  call add(obj.__super__[type.__name__], super)
  return super
endfunction

function! object#super#__init__(type, obj, list) dict
  let self.__self__ = a:obj
  let self.__self_class__ = a:obj.__class__
  let self.__thisclass__ = a:type
  unlet self.__init__
  for x in a:list
    let methods = object#class#methods(x)
    let rebind = map(methods, 'function("object#super#call", [v:val], self)')
    call extend(self, rebind, 'keep')
  endfor
endfunction

function! object#super#__repr__() dict
  return printf('<super: %s, %s>', self.__thisclass__.__name__, object#repr(self.__self__))
endfunction

function! object#super#call(X, ...) dict
  return call(a:X, a:000, self.__self__)
endfunction

""
" Retrieve method {name} bound to {obj} from the parent or sibling of {type}.
"
" The MRO of {obj} is visited started from {type} and the first attribute with
" {name} that is a |Funcref|, i.e., the first method, is returned.
"
" @throws TypeError if object#isinstance({obj}, {type}) is false.
" @throws TypeError if {type} is at the end of the MRO of {obj}.
" @throws AttributeError if {name} cannot be resolved.
function! object#super#super(type, obj, name)
  let type = object#class#ensure_class(a:type)
  let obj = object#class#ensure_object(a:obj)
  let name = object#util#ensure_identifier(a:name)

  let idx = object#class#find_class(type, obj.__class__)
  if idx < 0
    throw object#TypeError('super() requires isinstance(type, obj)')
  endif

  let idx += 1
  let mro = obj.__class__.__mro__
  let N = len(mro)
  if idx == N
    throw object#TypeError('%s object has no superclass', object#types#name(obj))
  endif

  while idx < N
    if has_key(mro[idx], name) && maktaba#value#IsFuncref(mro[idx][name])
      return function(mro[idx][name], obj)
    endif
    let idx += 1
  endwhile

  throw object#AttributeError('cannot resolve attribute %s', string(name))
endfunction
