let s:HAS_BINARY_SPECIFIER = has('patch-7.4.2221')
let s:HAS_SHA256 = exists('*sha256')

function! object#Lib#config#Get() abort "{{{1
  return s:
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
