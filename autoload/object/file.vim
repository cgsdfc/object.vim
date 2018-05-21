""
" @dict(file)
"
"
" mode string must begin with one of 'r', 'w', 'a' or 'U', not '+w'
" empty mode string
"

" The pattern of a mode string is beginning with 'r', 'a' or 'w' and followed
" by zero or more arbitrary characters.

let s:mode_pattern = '\v\C[raw].*'
" The pattern for writable mode is a mode_pattern containing 'a', 'w' or 'r+'.
let s:writable = '\v\C(a|w|r.*\+|\+.*r)'
" The pattern for readable mode is a mode_pattern that contains 'r' or
" ('a'|'w') with '+'
let s:readable = '\v\C(r|(a|w).*\+|\+.*(a|w))'

let s:file = object#class('file')
let s:file.flush = function('object#file#flush')
let s:file.close = function('object#file#close')
let s:file.readline = function('object#file#readline')
let s:file.readlines = function('object#file#readlines')
let s:file.writelines = function('object#file#writelines')
let s:file.write = function('object#file#write')
let s:file.read = function('object#file#read')
let s:file.__init__ = function('object#file#init')
let s:file.__repr__ = function('object#file#repr')
let s:file.__bool__ = function('object#file#bool')
let s:file.__iter__ = function('object#file#iter')

function! object#file#file_()
  return s:file
endfunction

function! object#file#patterns()
  return [s:mode_pattern, s:readable, s:writable]
endfunction

function! object#file#open(name, ...)
  let argc = object#util#ensure_argc(1, a:0)
  let mode = argc > 0 ? a:1 : 'r'
  return object#new(s:file, a:name, mode)
endfunction

function! object#file#bool() dict
  return !self.closed
endfunction

function! object#file#iter() dict
  call object#file#lazy_readfile(self)
  return self._buffer
endfunction

""
" file(name[,mode])
"
function! object#file#init(name, mode) dict
  let name = maktaba#ensure#IsString(a:name)
  let mode = maktaba#ensure#IsString(a:mode)
  if empty(mode)
    throw object#ValueError('empty mode string')
  endif
  if mode !~# s:mode_pattern
    let msg = "mode string must begin with one of 'r', 'w', or 'a', not %s"
    throw object#ValueError(msg, string(mode))
  endif

  if mode =~# s:readable && !filereadable(name)
    throw object#IOError('file not readable')
  endif

  if mode =~# s:writable && !filewritable(name)
    throw object#IOError('file not writable')
  endif

  let self.name = name
  let self.mode = mode
  let self.closed = 0
endfunction

function! object#file#repr() dict
  return printf('<open file %s, mode %s>', string(self.name), string(self.mode))
endfunction

""
" @dict(file)
"
function! object#file#close() dict
  if self.closed
    return
  endif
  let self.closed = 1
  call self.flush()
  if has_key(self._buffer)
    unlet self._buffer
  endif
endfunction

" a stands for append.
" b stands for binary.
function! s:write_flags(mode)
  return join(map(['a', 'b'], 'stridx(a:mode, v:val)>0?a:val:""'), '')
endfunction

""
" @dict(file)
"
function! object#file#flush() dict
  if self.mode !~# s:writable || !has_key(self, '_buffer')
    return
  endif
  try
    writefile(self._buffer, self.name, s:write_flags(self.mode))
  catch
    throw object#IOError('cannot create file %s', string(self.name))
  endtry
endfunction

function! s:read_flags(mode)
  return stridx(a:file.mode, 'b')>0?'b':''
endfunction

function! object#file#lazy_readfile(file)
  call s:read_mode(self)
  if has_key(a:file, '_buffer')
    return
  endif
  try
    let lines = readfile(a:file.name, s:read_flags(a:file.mode))
    let a:file._buffer = object#iter(lines)
  catch
    throw object#IOError('cannot read file %s', string(a:file.name))
  endtry
endfunction

function! s:write_mode(file)
  if a:file.mode =~# s:writable
    return
  endif
  throw object#IOError('File not open for writing')
endfunction

function! s:read_mode(file)
  if a:file.mode =~# s:readable
    return
  endif
  throw object#IOError('File not open for reading')
endfunction

function! object#file#readline() dict
  call object#file#lazy_readfile(self)
  try
    return object#next(self._buffer)
  catch /StopIteration/
    return ''
  endtry
endfunction

function! object#file#readlines() dict
  call object#file#lazy_readfile(self)
  return object#list(self._buffer)
endfunction

function! object#file#read(...) dict
  call object#util#ensure_argc(1, a:0)
  let max = a:0 ? maktaba#ensure#IsNumber(a:1) : -1
  return join(self.readlines(), '\n')[:max]
endfunction

function! object#file#write(str) dict
  call s:write_mode(self)
  let str = maktaba#ensure#IsString(a:str)
  if !has_key(self, '_buffer')
    let self._buffer = []
  endif
  call add(self._buffer, str)
endfunction

function! object#file#writelines(iter) dict
  call s:write_mode(self)
  let lines = object#list(a:iter)
  if !has_key(self, '_buffer')
    let self._buffer = lines
    return
  endif
  call extend(self._buffer, lines)
endfunction
