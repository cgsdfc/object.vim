""
" @section Lambda, lambda
" Create a function in one line of code. It is an
" enhanced version of |maktaba#function#FromExpr()|.
"
" Features:
"   * `lambda()` returns a |Funcref| rather than a |Dict|, which can be used
"     directly in situation such as |sort()|.
"   * The created lambda uses named arguments rather than numbered
"     arguments like `a:1`, improving readability.
"   * Provide interface to the underlying lambda object via `_lambda()`.
"   * lambda can create closure if one want to.
"   * `for()` function let you execute nearly arbitrary code while iterating.
"
" Limitations:
"   * Only one dictionary can be captured as closure at most, which means you
"   cannot access both `s:` and `l:` from the lambda at once. But there is
"   a simple workaround for this:
"   >
"     :let both_s_and_l = { 's': s:, 'l': l: }
"     :echo object#lambda('x', 'x > 1 ? c.s.var : c.l.var')(1)
"   <
"   * The number of arguments to the lambda is limited by the maximum number
"     allowed by Vim.
"
" Examples:
" >
"   :echo object#lambda('x y', 'x + y')(1, 2)
"   3
"
"   :echo sort(range(10), object#lambda('x y', 'y - x'))
"   [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
"
"   :echo object#map('aaa', object#lambda('s', 'toupper(s)'))
"   'AAA'
"
"   :call object#for('key val', object#enumerate([1, 2]), 'echo key val')
"   0 1
"   1 2
"
"   :let f = object#_lambda('x y', 'x + y')
"   :echo object#repr(f)
"   <'lambda' object>
"   :echo f.__call__(1, 2)
"   3
" <

let s:lambda = object#class('lambda')

""
" @dict lambda
" Initialize the @dict(lambda) object from a |String| of
" names to be used as the names of the function arguments
" and the expression to evaluated.
"
" If a [closure] is given, it can be accessed in form of
" `c.var` in the {code} argument. The letter `c` is chosen
" because it is the first letter for "capture", "capital" and
" "closure", all to do with `function`.
" What's more, the `c.var` syntax minics the `a:var`,
" `s:var` convensions of Vim, which makes it easier to remember.
" After all, it is short and meaningful so let's use it!
"
" @throws ValueError if {names} is not a |name-specification|.
" @throws WrongType if {code} or {names} is not a |String| or
" [closure] is not a |Dict|.
function! s:lambda.__init__(names, code, ...)
  call object#util#ensure_argc(1, a:0)
  let self.__argv__ = object#lambda#make_names(a:names)
  let self.__argc__ = len(self.__argv__)
  let self.__code__ = maktaba#ensure#IsString(a:code)
  if a:0 == 1
    let self.__closure__ = maktaba#ensure#IsDict(a:1)
  endif
endfunction

""
" @dict lambda
" Evaluate the lambda expression by applying [args].
"
" @throws TypeError if the actual arguments do not match the
" formal arguments declared via names.
function! s:lambda.__call__(...)
  return object#lambda#eval(self, a:0, a:000)
endfunction

" Evaluate the {__lambda} object.
function! object#lambda#eval(__lambda, __nargs, __args)
  if a:__nargs ==# a:__lambda.__argc__
    if has_key(a:__lambda, '__closure__')
      let c = a:__lambda.__closure__
    endif

    let __i = 0
    while __i < a:__lambda.__argc__
      let {a:__lambda.__argv__[__i]} = a:__args[__i]
      let __i += 1
    endwhile
    return eval(a:__lambda.__code__)
  endif

  throw object#TypeError(
        \'lambda takes exactly %d arguments (%d given)',
        \ a:__lambda.__argc__, a:__nargs)
endfunction

""
" @function lambda(...)
" Create a one-line |Funcref| that takes [vars] as
" arguments and returns the result of evaluation of [expr].
" >
"   lambda(vars, expr[,closure]) -> Funcref
" <
" If a [closure] argument is given, the variables `var`
" living inside the closure are available as `c.var` from
" the lambda expression.
function! object#lambda#lambda(...)
  return call('object#_lambda', a:000).__call__
endfunction

""
" @function _lambda(...)
" Create a `lambda` object. See @function(lambda).
" >
"   _lambda(vars, expr[,closure]).__call__
" <
function! object#lambda#_lambda(...)
  return object#new_(s:lambda, a:000)
endfunction

""
" @function lambda_(...)
" Return the lambda class.
function! object#lambda#lambda_()
  return s:lambda
endfunction

""
" Execute a |List| of commands while iterating over {iterable}.
" {names} is a space-separated |String|s that contains the variable
" names used as the items in the {iterable}. If a [closure] is given,
" it is available as `c.var` inside the code.
"
" {cmd} is a |String| of Ex command or a |List| of such strings.
" During each iteration, the commands are executed
" in the order that they are specified in the list.
" Examples:
" >
"   call object#for('x', range(10), ['if x > 0', 'echo x', 'endif'])
"   call object#for('f', files, 'call f.close()')
"   call object#for('key val', items(dict), 'echo key val')
" <
function! object#lambda#for(names, iterable, cmds, ...)
  " TODO: use for object
  call object#util#ensure_argc(1, a:0)
  let names = object#lambda#make_names(a:names)
  let iter = object#iter(a:iterable)
  let closure = a:0 ? maktaba#ensure#IsDict(a:1) : {}

  if maktaba#value#IsString(a:cmds)
    let excmds = a:cmds
  else
    let excmds = join(map(
          \ maktaba#ensure#IsList(a:cmds), 'maktaba#ensure#IsString(v:val)'), "\n")
  endif

  try
    while 1
      let Items = object#lambda#make_items(names, object#next(iter))
      call object#lambda#execute_cmds(excmds, Items, closure)
    endwhile
  catch /StopIteration/
    return
  endtry
endfunction

function! object#lambda#ensure_unique(names)
  let seen = {}
  for x in a:names
    if !has_key(seen, x)
      let seen[x] = 1
      continue
    endif
    throw object#ValueError('duplicate name %s', string(x))
  endfor
  return a:names
endfunction

"
" Unpack the {Vals} into {names} and return a 2-lists
" list for each name-value pair.
" If there is only one name, it will take the entire of {Vals}.
" Otherwise, {Vals} must be a |List| and its len should match
" that of the {names}.
"
" @throws WrongType if Vals is not a List but len(names) > 1.
" @throws TypeError if the len of names does not match that of
" Vals.
function! object#lambda#make_items(names, Vals)
  let names_nr = len(a:names)
  if names_nr ==# 1
    return [ [a:names[0], a:Vals] ]
  endif

  let Vals = maktaba#ensure#IsList(a:Vals)
  let Vals_nr = len(Vals)

  if names_nr ==# Vals_nr
    let i = 0
    let result = []
    while i < names_nr
      call add(result, [a:names[i], Vals[i]])
      let i += 1
    endwhile
    return result
  endif

  throw object#TypeError(names_nr > Vals_nr ?
        \ 'more targets than list items':
        \ 'less targets than list items')
endfunction

function! object#lambda#make_names(names)
  let names = maktaba#ensure#IsString(a:names)
  return object#lambda#ensure_unique(map(
        \ split(names), 'object#util#ensure_identifier(v:val)'))
endfunction

"
" Execute {__excmds} with {__items} set as items
" from the iterator.
function! object#lambda#execute_cmds(__excmds, __items, __closure)
  let c = a:__closure
  for __i in a:__items
    let {__i[0]} = __i[1]
  endfor
  execute a:__excmds
endfunction
