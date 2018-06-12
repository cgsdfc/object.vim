" TODO: use has('num64') or 1/0 0/0 tricks.

let s:int = object#class('int')
if str2nr('9223372036854775807') > 0
  let s:int.INT_MAX = 9223372036854775807
  let s:int.INT_WIDTH = 64
else
  let s:int.INT_MAX = 2147483647
  let s:int.INT_WIDTH = 32
endif
let s:int.INT_MIN = -s:int.INT_MAX - 1

let s:valid_literals = {
      \ '2':  '\C\v^[+-]?(0[bB])?[01]+$',
      \ '8':  '\C\v^[+-]?0?[0-7]+$',
      \ '10': '\C\v^[+-]?\d+$',
      \ '16': '\C\v^[+-]?(0[xX])?[0-9a-fA-F]+$',
      \}

let s:digits = {
      \ '2': '01',
      \ '8': '01234567',
      \ '10': '0123456789',
      \ '16': '0123456789abcdef',
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
    return call('str2nr',object#int#ensure_literal(a:0, a:000))
  endif
  if a:0 != 1
    throw object#TypeError('int() cannot convert %s with explicit base %d',
          \ object#types#names(a:1), maktaba#ensure#IsNumber(a:2))
  endif
  if maktaba#value#IsNumeric(a:1)
    return float2nr(a:1)
  endif
  if object#hasattr(a:1, '__int__')
    return maktaba#ensure#IsNumber(object#protocols#call(a:1.__int__))
  endif
  throw object#TypeError('int() argument must be a string or a number, not %s',
        \ object#types(a:1))
endfunction

" TODO: use %b for higher version, fail back on home-brew one.
" That means the convert_homebrew can be specific to bin, which may be
" faster.
function! object#int#convert_homebrew(int, base)
  let int = maktaba#ensure#IsNumber(a:int)
  let sign = int < 0 ? '-' : ''
  let int = abs(int)
  let digits = []
  while int != 0
    call add(digits, s:digits[a:base][int % a:base])
    let int = int / a:base
  endwhile
  return printf('%s%s%s', sign, s:prefixes[a:base],
        \ join(reverse(digits), ''))
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
        \ object#int#convert_homebrew(a:int, 2):object#int#convert_printf(a:int, 2)
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


