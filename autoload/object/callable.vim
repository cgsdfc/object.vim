function! object#callable#repr(X)
  " TODO: When obj is a Funcref, we can detect its dict
  " to find whether it is a bound-method, unbound-method
  " or plain function. The string(obj.__init__) is too ugly
  " to accept.
  return ''
endfunction
