" TODO: let bin() e.g. hook into __index__().

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
function! object#number#int#ensure_literal(nargs, args)
  let lit = object#builtin#CheckString(a:args[0])
  let base = a:nargs == 2 ? object#builtin#CheckNumber(a:args[1]): 10

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
function! object#number#int#int(...)
  call object#builtin#TakeAtMostOptional('int', 2, a:0)
  if !a:0
    return 0
  endif
  if object#builtin#IsString(a:1)
    return call('str2nr', object#number#int#ensure_literal(a:0, a:000))
  endif
  if a:0 != 1
    throw object#TypeError('int() cannot convert %s with explicit base %d',
          \ object#types#name(a:1), object#builtin#CheckNumber(a:2))
  endif
  if object#builtin#IsNumeric(a:1)
    return float2nr(a:1)
  endif
  if object#hasattr(a:1, '__int__')
    return object#builtin#CheckNumber(object#protocols#call(a:1.__int__))
  endif
  throw object#TypeError('int() argument must be a string or a numeric, not %s',
        \ object#types#name(a:1))
endfunction

" Replacement when '%b' is missing.
function! object#number#int#convert_binary(int)
  let int = object#builtin#CheckNumber(a:int)
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

function! object#number#int#convert_printf(int, base)
  let int = object#builtin#CheckNumber(a:int)
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
function! object#number#int#bin(int)
  return object#util#has_bin_specifier() ?
        \ object#number#int#convert_printf(a:int, 2):
        \ object#number#int#convert_binary(a:int)
endfunction

""
" @function hex(...)
" Return |String| representation for |Number| in base 16.
" >
"   hex(11) -> '0xb'
"   hex(-11) -> '-0xb'
" <
function! object#number#int#hex(int)
  return object#number#int#convert_printf(a:int, 16)
endfunction

""
" @function oct(...)
" Return |String| representation for |Number| in base 8.
" >
"   oct(8) -> '010'
"   oct(-8) -> '-010'
" <
function! object#number#int#oct(int)
  return object#number#int#convert_printf(a:int, 8)
endfunction

""
" @function abs(...)
" Return the absolute value of an object.
" >
"   abs(Number or Float) -> abs(num)
"   abs(obj) -> obj.__abs__()
" <
function! object#number#int#abs(num)
  if object#builtin#IsNumeric(a:num)
    return abs(a:num)
  endif
  if object#hasattr(a:num, '__abs__')
    return object#builtin#CheckNumeric(object#protocols#call(a:num.__abs__))
  endif
  throw object#TypeError('bad operand type for abs(): %s', object#types#name(a:num))
endfunction

""
" @function _int(...)
" Create an int object.
function! object#number#int#_int(...)
  return object#new_(s:int, a:000)
endfunction

""
" @function int_(...)
" Return the int type.
function! object#number#int#int_()
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
