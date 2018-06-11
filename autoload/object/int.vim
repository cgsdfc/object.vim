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
      \ '2':  '\C\v^(0[bB])?[01]+$',
      \ '8':  '\C\v^0?[0-7]+$',
      \ '10': '\C\v^\d+$',
      \ '16': '\C\v^(0[xX])?[0-9a-fA-F]+$',
      \}

let s:digits = {
      \ '2': '01',
      \ '8': '01234567',
      \ '10': '0123456789',
      \ '16': '0123456789abcdef',
      \}

let s:prefix = {
      \ '2': '0b',
      \ '8': '0',
      \ '10': '',
      \ '16': '0x',
      \}

function! object#int#ensure_literal(nargs, args)
  let lit = maktaba#ensure#IsString(a:args[0])
  let base = a:nargs == 2 ? maktaba#ensure#IsNumber(a:args[1]): 10

  if !has_key(s:valid_literals, base)
    throw object#ValueError('int() base must be one of 2, 8, 10, 16, not %d', base)
  endif
  if lit =~# s:valid_literals[a:base]
    return [lit, base]
  endif

  throw object#ValueError('invalid literal for int() with base %d: %s',
        \ a:base, string(a:lit))
endfunction

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

function! object#int#convert(int, base)
  let int = maktaba#ensure#IsNumber(a:int)
  let sign = int < 0 ? '-' : ''
  let digits = []
  while int != 0
    call add(digits, s:digits[a:base][int % a:base])
    let int = int / a:base
  endwhile
  return printf('%s%s%s', sign, s:prefix[a:base],
        \ join(reverse(digits), ''))
endfunction

function! object#int#bin(int)
  return object#int#convert(a:int, 2)
endfunction

function! object#int#hex(int)
  return object#int#convert(a:int, 16)
endfunction

function! object#int#oct(int)
  return object#int#convert(a:int, 8)
endfunction

function! object#int#abs(int)
endfunction

function! object#int#_int(...)
  return object#new_(s:int, a:000)
endfunction

function! object#int#int_()
  return s:int
endfunction

function! s:int.__init__(...)
  let self.real = call('object#int', a:000)
  let self.imag = 0
  let self.denominator = 1
  let self.numerator = self.real
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


