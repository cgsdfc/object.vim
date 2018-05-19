
let s:special_attrs = ['__class__', '__base__', '__name__', '__bases__']

function! object#class#is_valid_class(x)
  return object#hasattr(a:x, '__name__')
endfunction

function! object#class#is_valid_object(x)
  return object#hasattr(a:x, '__class__')
endfunction

function! object#class#is_method(Key, Val)
  return type(a:Val) == type(function('empty')) &&
        \ index(a:Key, s:special_attrs) < 0
endfunction

function! object#class#methods(cls)
  return filter(copy(a:cls), 'object#class#is_method(v:key, v:val)')
endfunction

function! object#class#ensure_bases(x)
  let base = map(a:x, 'object#class#ensure_class(v:val)')
  let N = len(base)
  if N == 1
    return base
  endif
  let i = 0
  while i < N-1
    let j = i + 1
    while j < N
      if base[i] isnot# base[j] | continue | endif
      throw object#TypeError('duplicate base class %s',
            \ object#types#quoted_typename(base[i]))
      let j += 1
    endwhile
    let i += 1
  endwhile
  return base
endfunction

function! object#class#type_init(cls, name, bases, dict)
  let name = maktaba#ensure#IsString('name', a:name)
  let bases = maktaba#ensure#IsList(a:bases)
  let bases = object#class#ensure_bases(a:bases)
  let dict = maktaba#ensure#IsDict(a:dict)

  call object#class#class_init(a:cls, name, bases)
  call extend(a:cls, dict, 'force')
endfunction

""
" Define a class that has a name and optional base class(es).
" >
"   let Widget = object#class('Widget')
"   let Widget = object#class('Widget', [...])
" <
" [bases] should be a |Dict| or a |List| of |Dict| that was defined by |class()|.
" {name} should be a |String| of valid identifier in Vim
" ([_a-zA-Z][_a-zA-Z0-9]*).
" The return value is special |Dict| to which methods can be added to and from
" which instance can be created by |object#new()|.
" Methods can be added by:
" >
"   function! Widget.say_yes()
"   let Widget.say_yes = function('widget#say_yes')
" <
"
" Inheritance is possible. The methods of base classes are added from left to
" right across the [bases] when |class()| is called. The methods defined for
" this class effectively override those from bases.
"
function! object#class#class(name, ...)
  let name = maktab#ensure#IsString(a:name)
  let argc = object#class#ensure_argc(1, a:0)
  if !argc
    " Implicitly subclass object
    let bases = [s:object_class]
  elseif maktab#value#IsList(a:1)
    if empty(a:1)
      throw object#TypeError("'bases' should not be empty")
    endif
    let bases = a:1
  elseif maktab#value#IsDic(a:1)
    " Single base
    let bases = [a:1]
  else
    throw object#TypeError("'bases' should be a class or a List of classes")
  endif

  call object#class#ensure_bases(bases)
  let cls = {
        \ '__class__' : s:type_class,
        \ }
  call object#class#class_init(cls, name, bases)
  return cls
endfunction

""
" @private
function! object#class#class_init(cls, name, bases)
  let cls.__name__ = name
  let cls.__bases__ = bases
  let cls.__base__ = bases[0]

  for x in bases
    let methods = object#class#methods(x)
    call extend(cls, methods, 'keep')
  endfor
endfunction

""
" Create a new instance of {cls} by applying optional [args].
"
function! object#class#new(cls, ...)
  let cls = object#class#ensure_class(a:cls)
  let obj = object#class#rawnew(cls)
  call call(obj.__init__, a:000)
  return obj
endfunction

function! object#class#rawnew(cls)
  let obj = {
        \ '__class__': a:cls,
        \ }
  call extend(obj, object#class#methods(a:cls))
  return obj
endfunction

"
" Find the base class of {obj} that matches {cls}. Return v:none
" if not found.
function! object#class#find_base(obj, cls)
  let bases = a:obj.__class__.__bases__
  for x in bases
    if a:cls is# x
      return x
    endif
  endfor
  return v:none
endfunction

function! object#class#ensure_class(x)
  if object#class#is_valid_class(a:x)
    return a:x
  endif
  throw object#TypeError("not a valid class")
endfunction

function! object#class#ensure_object(x)
  if object#class#is_valid_object(a:x)
    return a:x
  endif
  throw object#TypeError("not a valid object")
endfunction

""
" Return the class of {obj}.
"
function! object#class#type(obj)
  call object#class#ensure_object(a:obj)
  return object#getattr(a:obj, '__class__')
endfunction

""
" Return a partial |Funcref| that binds the dict of {method}
" of the base class {cls} of {obj} to {obj}
" Examples:
" >
"   call object#super(Base, self, '__init__')(...)
" <
"
function! object#class#super(cls, obj, method)
  let cls = object#class#ensure_class(a:cls)
  let obj = object#class#ensure_object(a:obj)
  let method = maktab#ensure#IsString(a:method)

  let cls = object#class#find_base(obj, cls)
  if cls is# v:none
    throw object#ValueError('object has no base class %s',
          \ string(cls.__name__))
  endif

  let method = object#getattr(cls, method)
  " Create a partial so that dict become obj.
  return function(method, obj)
endfunction

"
" Visit the parents of {cls} and itself in a depth-first
" manner until any of them satisfies the {Predicate}.
function! object#class#any_parent(cls, Predicate)
  if a:Predicate(a:cls)
    return 1
  endif
  if a:cls is# s:none_class
    return 0
  endif
  let parents = a:cls.__bases__
  for p in parents
    if object#class#any_parent(p, a:Predicate)
      return 1
    endif
  endfor
  return 0
endfunction

function! object#class#issubclass_pred(base, cls)
  return a:cls is# a:base
endfunction

function! object#class#isinstance_pred(obj, cls)
  return a:obj.__class__ is# a:cls
endfunction

""
" Return whether {obj} is an instance of {cls}.
"
function! object#class#isinstance(obj, cls)
  let cls = object#class#ensure_class(a:cls)
  let obj = object#class#ensure_object(a:obj)
  let Pred = function('object#isinstance_pred', [a:obj])
  return object#class#any_parent(a:cls, Pred)
endfunction

""
" Return wheter {cls} is a subclass of {base}.
"
function! object#class#issubclass(cls, base)
  let cls = object#class#ensure_class(a:cls)
  let base = object#class#ensure_class(a:base)
  let Pred = function('object#class#issubclass_pred', [a:base])
  return object#class#any_parent(a:cls, Pred)
endfunction
