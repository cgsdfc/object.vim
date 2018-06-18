let s:bool = object#class('bool', object#int_())

function! s:bool.__new__(cls, ...)
  let val = call('object#bool', a:000)
  if !exists('s:True')
    let s:True = object#super(s:bool, a:cls).__new__(val) 
    let s:False = object#super(s:bool, a:cls).__new__(!val) 
  endif
  return val? s:True : s:False
endfunction

function! object#bool#_bool(...)
  return object#new_(s:bool, a:000)
endfunction

""
" @function bool(...)
" Convert [args] to a Bool, i.e., 0 or 1.
" >
"   bool() -> False
"   bool(Funcref) -> True
"   bool(List, String or plain Dict) -> not empty
"   bool(Number) -> non-zero
"   bool(Float) -> non-zero
"   bool(v:false, v:null, v:none) -> False
"   bool(v:true) -> True
"   bool(obj) -> obj.__bool__()
" <
function! object#bool#bool(...)
  call object#util#ensure_argc(1, a:0)
  if !a:0
    " bool() <==> false
    return 0
  endif
  let Obj = a:1
  if has('float') && maktaba#value#IsFloat(Obj)
    return Obj !=# 0.0
  endif
  if maktaba#value#IsFuncref(Obj)
    return 1
  endif
  if maktaba#value#IsString(Obj) || maktaba#value#IsList(Obj)
    return !empty(Obj)
  endif
  try
    " If we directly return !!Obj, the exception cannot
    " be caught.
    let x = !!Obj
    return x
  catch/E728/ " Using a Dictionary as a Number
    if object#hasattr(Obj, '__bool__')
      " Thing returned from bool() should be canonical, so as __bool__.
      " Prevent user from mistakenly return something like 1.0
      return maktaba#ensure#IsBool(object#protocols#call(Obj.__bool__))
    endif
    return !empty(Obj)
  catch
    call object#except#not_avail('bool', Obj)
  endtry
endfunction

