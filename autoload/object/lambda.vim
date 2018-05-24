""
" @section lambda, lambda
" Create inline function in one line of code. It is an
" enhanced version of |maktaba#function#FromExpr()|.
"
" Features:
"   * lambda() returns a |Funcref| rather than a |Dict|, which can be used
"     directly in situation such as |sort()|.
"   * The created lambda uses named arguments rather than numbered
"     arguments like ``a:1``, improving readability.
"   * Provide interface to the underlying lambda object.
"   * lambda can create closure if one want to.
"
" Limitations:
"   * Only one dictionary can be captured as closure at most, which means you
"   cannot access both ``s:`` and ``l:`` from the lambda at once. But there is
"   a simple workaround for this:
"   >
"     :let both_s_and_l = { 's': s:, 'l': l: }
"     :echo object#lambda('x', 'x > 1 ? c.s.var : l.s.var')(1)
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
    > [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
"
"   :echo object#map('aaa', object#lambda('s', 'toupper(s)'))
"   'AAA'
"
"   " Note ``object#lambda_()`` returns |Dict| so no Capital Letter is needed.
"   :let f = object#lambda_('x y', 'x + y')
"   :echo object#repr(f)
"   <'lambda' object>
"   :echo f.__call__(1, 2)
"   3
" <

""
" @dict lambda


let s:lambda = object#class('lambda')
let s:lambda.__init__ = function('object#lambda#__init__')
let s:lambda.__call__ = function('object#lambda#__call__')

""
" @dict lambda

""
" @dict lambda
" Initialize the @dict(lambda) object from a |String| of
" names to be used as the names of the function arguments
" and the expression to evaluated.
"
" If a [closure] is given, it can be accessed in form of
" ``c.var`` in the {code} argument. The letter ``c`` is chosen
" because it is the first letter for "capture", "capital" and
" "closure", all of which is to do with accessing variables outside
" the local scope. What's more, the ``c.var`` syntax minics the ``a:var``,
" ``s:var`` convensions of Vim, which makes it easier to remember.
" After all, it is short and meaningful so let's use it!
"
" @throws ValueError if {names} is not a |name specification|.
" @throws WrongType if {code} or {names} is not a |String| or
" [closure] is not a |Dict|.
function! object#lambda#__init__(names, code, ...) dict
  call object#util#ensure_argc(1, a:0)
  let self.code = maktaba#ensure#IsString(a:code)
  let self.argv = object#lambda#make_names(a:names)
  let self.argc = len(self.argv)
  if a:0 == 1
    let self.closure = maktaba#ensure#IsDict(a:1)
  endif
endfunction

""
" Evaluate the lambda expression by applying [arguments].
"
" @throws TypeError if the actual arguments do not match the
" formal arguments declared via {names}.
function! object#lambda#__call__(...) dict
  return call('object#lambda#eval', [self] + a:000)
endfunction

function! object#lambda#make_names(names)
  let names = maktaba#ensure#IsString(a:names)
  return map(split(names), 'object#util#ensure_identifier(v:val)')
endfunction

" Evaluate the {__lambda} object.
function! object#lambda#eval(__lambda, ...)
  if a:0 ==# a:__lambda.argc
    if has_key(a:__lambda, 'closure')
      let c = a:__lambda.closure
    endif
    let __i = 0
    while __i < a:__lambda.argc
      let {a:__lambda.argv[__i]} = a:000[__i]
      let __i += 1
    endwhile
    return eval(a:__lambda.code)
  endif
  throw object#TypeError(
        \'lambda takes exactly %d arguments (%d given)',
        \ a:__lambda.argc, a:0)
endfunction

""
" Create a one-line |Funcref| that takes {names} as
" arguments and returns the result of evaluation of
" {code}.
"
" If a [closure] argument is given, the variables {var}
" living inside [closure] are available as ``c.var`` from
" the lambda expression.
"
function! object#lambda#lambda(...)
  let lambda = object#new_(s:lambda, a:000)
  return lambda.__call__
endfunction

""
" Create a lambda object that cannot be directly called
" but has a ``__call__`` method, which does the same thing
" as what is returned by ``object#lambda()``.
function! object#lambda#lambda_(...)
  return object#new_(s:lambda, a:000)
endfunction
