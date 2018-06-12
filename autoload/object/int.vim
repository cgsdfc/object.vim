""
" @section Int, int
" The `int()` converter and the wrapper type `int`.
"
" @subsection checked-conversion-to-int
" The built-in `str2nr()` does no checking to the string to be
" converted while with simple regex it can be achieved.
" `int()` ensures that the base and the string literal are valid
" and it can handle |Float| much like |float2nr()| does. When called
" with no argument, it returns the constant `0`, which can be useful
" to supply default value. It also hooks into `__int__()`. Very nice.
" See some examples:
" >
"   >>> object#int()
"   0
"   >>> object#int(1.2)
"   1
"   >>> object#int('0b101', 2)
"   5
"   >>> object#int('1234')
"   1234
"   >>> object#int('0xg', 16)
"   ValueError: invalid literal for int() with base 16: '0xg'
" <
"
" @subsection handy-formatter-of-various-bases
" You can use `bin()`, `oct()` and `hex()` to get a |String| representations
" of various bases from an integer.
" What was return can be parsed back to
" an `int` with `int()`. Different from `printf()` with specifiers, these
" do not pull out the 2-complementary digits when the argument is negative.
" Rather, they prefix it with a negative sign:
" >
"   >>> object#bin(-1)
"   -0b1
"   >>> printf('%b', -1)
"   11111111111111111111111111111111
"   >>> object#hex(-1)
"   -0x1
"   >>> printf('%x', -1)
"   ffffffff
" <
"
" @subsection wrapper-type-int
" A wrapper type `int` is defined for the cases when object-oriented
" interface is handy. `int` can be extended just as any other built-in
" type can. Just rememebr keeping it at the very end of your base list since
" for efficiency, `__init__()` of it does not call `super()`.
"
" Data descriptor for `int`:
" - `INT_MAX`: maximum value of |Number|.
" - `INT_MIN`: minimum value of |Number|.
" - `INT_WIDTH`: bit-width of |Number|.
" Here are some examples:
" >
"   >>> let i = object#_int(1)
"   >>> i
"   1
"   >>> i.numerator
"   1
"   >>> i.real
"   1
"   >>> i.imag
"   0
"   >>> object#hash(i)
"   1
"   >>> object#abs(i)
"   1
"   >>> object#int_()
"   <type 'int'>
" <

let s:int = object#class('int')
" These silly zero-dividends work.
let s:int.INT_MAX = 1/0
let s:int.INT_MIN = 0/0
let s:int.INT_WIDTH = 4 * len(printf('%x', s:int.INT_MAX))

" Regex Explain:
" Leading and trailing space are allowed.
" There must be no space among the optional prefix, digits
" and optional sign.
" Empty string is not allowed. There must be at least one digit.
" Python Difference:
" Python allows space between sign and digits (possibly prefix).
" However, |str2nr()| does not recognize such literals and turns
" them to zero. Thus it is forbidden.
let s:valid_literals = {
      \ '2':  '\C\v^\s*[+-]?(0[bB])?[01]+\s*$',
      \ '8':  '\C\v^\s*[+-]?0?[0-7]+\s*$',
      \ '10': '\C\v^\s*[+-]?\d+\s*$',
      \ '16': '\C\v^\s*[+-]?(0[xX])?[0-9a-fA-F]+\s*$',
      \}

let s:prefixes = {
      \ '2': '0b',
      \ '8': '0',
      \ '10': '',
      \ '16': '0x',
      \}

let s:specifiers = {
      \ '2': '%b',
      \ '8': '%o',
      \ '10': '%d',
      \ '16': '%x',
      \}

" Ensure that the given base and literal under that base are valid.
function! object#int#ensure_literal(nargs, args)
  let lit = maktaba#ensure#IsString(a:args[0])
  let base = a:nargs == 2 ? maktaba#ensure#IsNumber(a:args[1]): 10

  if !has_key(s:valid_literals, base)
    throw object#ValueError('int() base must be one of 2, 8, 10, 16, not %d', base)
  endif
  if lit =~# s:valid_literals[base]
    return [lit, base]
  endif

  throw object#ValueError('invalid literal for int() with base %d: %s',
        \ base, string(lit))
endfunction

""
" @function int(...)
" Convert [args] to a |Number|, i.e., an int.
" >
"   int() -> 0
"   int(Number) -> returned as it
"   int(Float) -> truncated towards zero as float2nr() does
"   int(String, base=10) -> convert to Number as str2nr() does
" <
" Valid bases are 2, 8, 10, 16 as accepted by |str2nr()|.
function! object#int#int(...)
  call object#util#ensure_argc(2, a:0)
  if !a:0
    return 0
  endif
  if maktaba#value#IsString(a:1)
    return call('str2nr', object#int#ensure_literal(a:0, a:000))
  endif
  if a:0 != 1
    throw object#TypeError('int() cannot convert %s with explicit base %d',
          \ object#types#name(a:1), maktaba#ensure#IsNumber(a:2))
  endif
  if maktaba#value#IsNumeric(a:1)
    return float2nr(a:1)
  endif
  if object#hasattr(a:1, '__int__')
    return maktaba#ensure#IsNumber(object#protocols#call(a:1.__int__))
  endif
  throw object#TypeError('int() argument must be a string or a numeric, not %s',
        \ object#types#name(a:1))
endfunction

" Replacement when '%b' is missing.
function! object#int#convert_binary(int)
  let int = maktaba#ensure#IsNumber(a:int)
  if int is# 0
    return '0b0'
  endif
  let sign = int < 0 ? '-' : ''
  let digits = []
  while int != 0
    call add(digits, and(int, 1))
    let int = int / 2
  endwhile
  return printf('%s0b%s', sign, join(reverse(digits), ''))
endfunction

function! object#int#convert_printf(int, base)
  let int = maktaba#ensure#IsNumber(a:int)
  let sign = int < 0 ? '-' : ''
  let fmt = '%s%s'.s:specifiers[a:base]
  return printf(fmt, sign, s:prefixes[a:base], abs(int))
endfunction

""
" @function bin(...)
" Return |String| representation for |Number| in base 2.
" >
"   bin(3) -> '0b11'
"   bin(-3) -> '-0b11'
" <
function! object#int#bin(int)
  return object#util#has_bin_specifier() ?
        \ object#int#convert_printf(a:int, 2):
        \ object#int#convert_binary(a:int)
endfunction

""
" @function hex(...)
" Return |String| representation for |Number| in base 16.
" >
"   hex(11) -> '0xb'
"   hex(-11) -> '-0xb'
" <
function! object#int#hex(int)
  return object#int#convert_printf(a:int, 16)
endfunction

""
" @function oct(...)
" Return |String| representation for |Number| in base 8.
" >
"   oct(8) -> '010'
"   oct(-8) -> '-010'
" <
function! object#int#oct(int)
  return object#int#convert_printf(a:int, 8)
endfunction

""
" @function abs(...)
" Return the absolute value of an object.
" >
"   abs(Number or Float) -> abs(num)
"   abs(obj) -> obj.__abs__()
" <
function! object#int#abs(num)
  if maktaba#value#IsNumeric(a:num)
    return abs(a:num)
  endif
  if object#hasattr(a:num, '__abs__')
    return maktaba#ensure#IsNumeric(object#protocols#call(a:num.__abs__))
  endif
  throw object#TypeError('bad operand type for abs(): %s', object#types#name(a:num))
endfunction

""
" @function _int(...)
" Create an int object.
function! object#int#_int(...)
  return object#new_(s:int, a:000)
endfunction

""
" @function int_(...)
" Return the int type.
function! object#int#int_()
  return s:int
endfunction

function! s:int.__init__(...)
  let self.real = call('object#int', a:000)
  let self.imag = 0
  let self.denominator = 1
  let self.numerator = self.real
endfunction

function! s:int.__abs__()
  return abs(self.real)
endfunction

function! s:int.__int__()
  return self.real
endfunction

function! s:int.__repr__()
  return object#repr(self.real)
endfunction

function! s:int.__str__()
  return object#str(self.real)
endfunction

function! s:int.__hash__()
  return object#hash(self.real)
endfunction

function! s:int.__bool__()
  return object#bool(self.real)
endfunction
