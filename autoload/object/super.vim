""
" @section Super, super
" `super()` is a way for a class to call methods of their parents and siblings while
" overriding them. In this section you will learn how to use the two forms of
" `super()` provided by object.vim.
"
" @subsection usage
" Most typically, you can initialize base class via `super()`:
" >
"   let s:Shape = object#class('Shape')
"   function! s:Shape.__init__(kwdict)
"     let self.shapename = get(a:kwdict, 'shapename')
"     call object#super(s:Shape, self).__init__(a:kwdict)
"   endfunction
"
"   let s:ColoredShape = object#class('ColoredShape', s:Shape)
"   function! s:ColoredShape.__init__(kwdict)
"     let self.color = get(a:kwdict, 'color')
"     call object#super(s:ColoredShape, self).__init__(a:kwdict)
"   endfunction
"
"   let c = object#new(s:ColoredShape, {'color':'red', 'shapename':'circle'})
" <
" What `super()` does is locating the next type in the MRO and
" returns an object that has all the methods of this type bound to the
" invoking object. The proxy object is further cached in the invoking object,
" which makes following access to it faster.
"
" @subsection use-cases-of-two-supers
" Currently two ways to call methods of parents and siblings are provided
" and let's talk about the cases when you may use one of them.
" >
"   super(type, obj)
" <
" It creates a proxy object delegating almost all the
" method calls to parents and siblings. The super objects are cached in the
" the invoking object, i.e., `__self__` so later calls to `super()` with
" specific `type` and `obj` effectively retrieves the cached objects. That
" means if you use lots of methods from parents in a class, you can use
" `super()` to speed up. However, since the nature of static method
" resolution, the number of methods of one super object grows linearly to
" the size of the MRO. Since all the classes in the MRO except the first one
" may result in a distinct super object, the total number of methods of those super
" objects is ordered by O(len(MRO)^2), which is always the case when
" cooperative inheritance is in used. Therefore, if you have a somehow
" deep class hierarchy, be careful with the space overhead with the
" instances of those leaf classes, especially when each of your classes has a
" non-trivial number of methods.
" In short, use `super()` if you densely call different methods of parents
" and siblings while the depth of your class hierarchy is modest.
" >
"   super_(type, obj, name)
" <
" It searches the MRO started from the next of `type` and returns the
" first method matching `name`. There isn't any caching behind the sense so
" `__super__` is not created. However, when cooperative inheritance is used,
" a sinle chained call to `super_()` results in O(len(MRO)^2) time to resolve
" all the methods along the way. Therefore, if you make sparse calls to
" the methods of parents and you want to minimize the space of your instances, you may use
" `super_()` since the time won't be a problem. However, in present of a
" long MRO and frequent calls to `super_()`, you may prefer `super()`.
"
" You are recommended to use `super()` at first and only when "Out Of Memory"
" arises should you turn some `super()` to `super_()` because not only the
" syntax of `super()` looks more nature (more like Python), but the attributes of super objects
" aid inspection. Mixing both of them in
" one single class is not recommended, since both of their benefits may be
" lost (you asked for a cache but you didn't use it).
" However, you can mix them in different classes of one hierarchy,
" especially using `super_()` in those leaf classes whose MRO is long.
"
" @subsection caching-super
" To save time, `super()` caches the super objects of each `type` in each
" `obj` with a special attribute `__super__`. Unlike other special
" attribute like `__mro__`, the structure of this one is kept private, which
" means you should not count on it. In the future, inspection of it may
" be provided.
"
" The current `__super__` keeps a dictionary of all the created super objects
" hashed with the name of their `__thisclass__`. Since different classes can
" have the same name, conflicts are handled by having a list of super objects
" for each name. When the `type` and `obj` have been validated, `super()`
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
      \})

""
" Return a super object bound to {obj} that delegates method calls to the parents and
" siblings of {type}.
"
" @throws TypeError if object#isinstance({obj}, {type}) is false.
" @throws TypeError if {type} is at the end of the MRO of {obj}.
function! object#super#super(type, obj)
  " TODO: if we have __new__()
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

  let [idx, N, mro] = object#super#find_super(type, obj)
  let super = object#new(s:super, type, obj, idx, N, mro)
  call add(obj.__super__[type.__name__], super)

  return super
endfunction

"
" Find the super based on find_class().
" Check for various failures.
function! object#super#find_super(type, obj)
  let idx = object#class#find_class(a:type, a:obj.__class__)
  if idx < 0
    throw object#TypeError('isinstance(type, obj) required')
  endif

  let idx += 1
  let mro = a:obj.__class__.__mro__
  let N = len(mro)
  if N == idx
    throw object#TypeError('%s object has no superclass', object#types#name(a:obj))
  endif
  return [idx, N, mro]
endfunction

function! object#super#__init__(type, obj, start, end, mro) dict
  let self.__self__ = a:obj
  let self.__self_class__ = a:obj.__class__
  let self.__thisclass__ = a:type
  let i = a:start

  while i < a:end
    let methods = object#class#methods(a:mro[i])
    let rebind = map(methods, 'function("object#super#call", [v:val], self)')
    " Force out the methods of super derived from object.
    " If we don't do that, methods like __init__(), __repr__() can't be
    " forwarded.
    call extend(self, rebind, i == a:start ? 'force' : 'keep')
    let i += 1
  endwhile
endfunction

"
" High ordered function that take a Funcref X and apply args to it
" with dict bound to __self__.
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
function! object#super#super_(type, obj, name)
  let type = object#class#ensure_class(a:type)
  let obj = object#class#ensure_object(a:obj)
  let name = object#util#ensure_identifier(a:name)

  let [idx, N, mro] = object#super#find_super(type, obj)

  while idx < N
    if has_key(mro[idx], name) && maktaba#value#IsFuncref(mro[idx][name])
      return function(mro[idx][name], obj)
    endif
    let idx += 1
  endwhile

  throw object#AttributeError('cannot resolve attribute %s', string(name))
endfunction
