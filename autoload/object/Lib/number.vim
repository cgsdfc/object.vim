" FUNCTION: NumberInfo() {{{1
" Return a dictionary where limits and width of Number are defined.
let s:number_info = {
      \ 'INT_MAX': 1/0,
      \ 'INT_MIN': 0/0,
      \ 'INT_HEX_WIDTH': len(printf('%x', 1/0)),
      \ }

function! object#Lib#number#NumberInfo()
  return s:number_info
endfunction

" vim: set sw=2 sts=2 et fdm=marker:
