" TODO: let bin() e.g. hook into __index__().

let s:config = object#Lib#config#Get()

let s:number_info = {
      \ 'INT_MAX': 1/0,
      \ 'INT_MIN': 0/0,
      \ 'INT_HEX_WIDTH': len(printf('%x', 1/0)),
      \}

function! object#Lib#number#NumberInfo() abort "{{{1
  " Return a dictionary where limits and width of Number are defined.
  return s:number_info
endfunction

" Regex Explain:
" Leading and trailing space are allowed.
" There must be no space among the optional prefix, digits
" and optional sign.
" Empty string is not allowed. There must be at least one digit.
" Python Differences:
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

function! object#Lib#number#CheckIntegerLiteral(args) abort "{{{1
  " Ensure that the given base and literal under that base are valid.
  let lit = object#Lib#value#CheckString2(a:args[0])
  let base = len(a:args) == 2 ? object#Lib#value#CheckNumber2(a:args[1]): 10
  if !has_key(s:valid_literals, base)
    call object#ValueError('int() base must be one of 2, 8, 10, 16, not %d', base)
  endif
  if lit !~# s:valid_literals[base]
    call object#ValueError("invalid literal for int() with base %d: '%s'",
          \ base, lit)
  endif
  return [lit, base]
endfunction

function! object#Lib#number#int(...) abort "{{{1
  " Convert [args] to a |Number|, i.e., an int.
  " >
  "   int() -> 0
  "   int(Number) -> returned as it
  "   int(Float) -> truncated towards zero as float2nr() does
  "   int(String, base=10) -> convert to Number as str2nr() does
  " <
  " Valid bases are 2, 8, 10, 16 as accepted by |str2nr()|.
  call object#Lib#value#TakeAtMostOptional('int', 2, a:0)
  if !a:0
    return 0
  endif
  if object#Lib#value#IsString(a:1)
    return call('str2nr', object#Lib#number#CheckIntegerLiteral(a:000))
  endif
  let base = object#Lib#value#CheckNumber2(a:2)
  if a:0 != 1
    call object#TypeError('int() cannot convert %s with explicit base %d',
          \ object#Lib#value#TypeName(a:1), base)
  endif
  if object#Lib#value#IsNumeric(a:1)
    return float2nr(a:1)
  endif
  if !object#Lib#proto#HasProtocol(a:1, '__int__')
    call object#TypeError('int() argument must be a string or a numeric, not %s',
          \ object#Lib#value#TypeName(a:1))
  endif
  return object#Lib#value#CheckNumber2(object#Lib#func#CallFuncref(a:1.__int__))
endfunction

function! s:Binary2String(int) abort "{{{1
  " Implement bin() when '%b' is missing from Vim.
  let int = object#Lib#value#CheckNumber2(a:int)
  if int is 0
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

function! s:Integer2String(int, base) abort "{{{1
  let int = object#Lib#value#CheckNumber(a:int)
  let sign = int < 0 ? '-' : ''
  let fmt = '%s%s'.s:specifiers[a:base]
  return printf(fmt, sign, s:prefixes[a:base], abs(int))
endfunction

function! object#Lib#number#bin(int) abort "{{{1
  " Return |String| representation for |Number| in base 2.
  " >
  "   bin(3) -> '0b11'
  "   bin(-3) -> '-0b11'
  " <
  if s:config.HAS_BINARY_SPECIFIER
    return s:Integer2String(a:int, 2):
  else
    return s:Binary2String(a:int)
endfunction

function! object#Lib#number#hex(int) abort "{{{1
  " Return |String| representation for |Number| in base 16.
  " >
  "   hex(11) -> '0xb'
  "   hex(-11) -> '-0xb'
  " <
  return s:Integer2String(a:int, 16)
endfunction

function! object#Lib#number#oct(int) abort "{{{1
  " Return |String| representation for |Number| in base 8.
  " >
  "   oct(8) -> '010'
  "   oct(-8) -> '-010'
  " <
  return s:Integer2String(a:int, 8)
endfunction

function! object#Lib#number#abs(num) abort "{{{1
  " Return the absolute value of an object.
  " >
  "   abs(Number or Float) -> abs(num)
  "   abs(obj) -> obj.__abs__()
  " <
  if object#Lib#value#IsNumeric(a:num)
    return abs(a:num)
  endif
  if object#Lib#proto#HasProtocol(a:num, '__abs__')
    return object#Lib#func#CallFuncref(a:num.__abs__)
  endif
  call object#TypeError("bad operand type for abs(): '%s'",
        \  object#Lib#value#TypeName(a:num))
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
