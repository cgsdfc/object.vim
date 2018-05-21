""
" @dict file
" A simple interface to the |readfile()| and |writefile()| functions.
"
" Features:
"   * Lazy reading and writing.
"   * Line-oriented readline(), writeline() available.
"   * Mode string syntax like 'a', 'w' or '+', 'b'.
"
" Limitations:
"   * The file is always buffered.
"   * The content of the file object is insensitive to external changes to the
"     underlying file.
"   * The file is unseekable. All reading or writing happens essentially at the
"     current line number.
"   * No context manager available. Must call f.close() explicitly.
"

let s:private_attrs = '\v\C(_read|_written)'

" The pattern of a mode string is beginning with 'r', 'a' or 'w' and followed
" by zero or more arbitrary characters.
let s:mode_pattern = '\v\C[raw].*'

" The pattern for writable mode is a mode_pattern containing 'a', 'w' or 'r+'.
let s:writable = '\v\C([aw]|r.*\+)'

" The pattern for readable mode is a mode_pattern that contains 'r', w+ or a+.
let s:readable = '\v\C(r|[aw].*\+)'

let s:file = object#class('file')
let s:file.read = function('object#file#read')
let s:file.readline = function('object#file#readline')
let s:file.readlines = function('object#file#readlines')
let s:file.write = function('object#file#write')
let s:file.writeline = function('object#file#writeline')
let s:file.writelines = function('object#file#writelines')
let s:file.flush = function('object#file#flush')
let s:file.close = function('object#file#close')

let s:file.__init__ = function('object#file#__init__')
let s:file.__repr__ = function('object#file#__repr__')
let s:file.__bool__ = function('object#file#__bool__')
let s:file.__iter__ = function('object#file#__iter__')
let s:file.__dir__ = function('object#file#__dir__')
let s:file.__getattr__ = function('object#file#__getattr__')
let s:file.__setattr__ = function('object#file#__setattr__')

""
" Open a file. The {mode} can be 'r', 'w' or 'a' for reading (default),
" writing or appending. The file will be created if it doesn't exist
" when opened for writing or appending; it will be truncated when
" opened for writing. Add a 'b' to the {mode} for binary files.
" Add a '+' to the {mode} to allow simultaneous reading and writing.
"
function! object#file#open(name, ...)
  let argc = object#util#ensure_argc(1, a:0)
  let mode = argc > 0 ? a:1 : 'r'
  return object#new(s:file, a:name, mode)
endfunction
""
" @dict file
" Read the the whole of the file, return it as a string.
" Lines are joint with a NL character.
"
function! object#file#read() dict
  return join(self.readlines(), "\n")
endfunction

""
" @dict file
" Return the next line from the file.
" Return an empty string at EOF.
" Note: Newlines are not retained.
"
function! object#file#readline() dict
  call s:lazy_readfile(self)
  try
    return object#next(self._read)
  catch /StopIteration/
    return ''
  endtry
endfunction

""
" @dict file
" Return a list of strings, each a line from the file.
" Note: Newlines are not retained.
"
function! object#file#readlines() dict
  call s:lazy_readfile(self)
  return object#list(self._read)
endfunction

""
" @dict file
" Write a {str} to the file.
" {str} is appended to the last line of file.
"
function! object#file#write(str) dict
  call s:write_mode(self)
  let str = maktaba#ensure#IsString(a:str)
  if !has_key(self, '_written')
    let self._buffer = [str]
    return
  endif
  let self._written[-1] .= str
endfunction

""
" @dict file
" Write a {line} to the file.
"
function! object#file#writeline(line) dict
  call s:write_mode(self)
  let line = maktaba#ensure#IsString(a:line)
  if !has_key(self, '_written')
    let self._written = []
  endif
  call add(self._written, line)
endfunction

""
" @dict file
" Write a sequence of strings to the file.
" @throws WrongType if {iter} returns non-string.
"
function! object#file#writelines(iter) dict
  call s:write_mode(self)
  let iter = object#iter(a:iter)
  if !has_key(self, '_written')
    let self._written = []
  endif
  try
    while 1
      call add(self._written, maktaba#ensure#IsString(object#next(iter)))
    endwhile
  catch /StopIteration/
    return
  endtry
endfunction

""
" @dict file
" Flush the written data.
" @throws IOError if |writefile()| fails.
"
function! object#file#flush() dict
  if self.mode !~# s:writable || !has_key(self, '_written')
    return
  endif
  try
    writefile(self._written, self.name, s:write_flags(self.mode))
  catch
    throw object#IOError('cannot create file %s', string(self.name))
  endtry
endfunction

""
" @dict file
" Close the file and flush it. Any file operation fails after
" it is closed. Calling close() for multiple times does not causes
" an error.
"
function! object#file#close() dict
  if self.closed
    return
  endif
  let self.closed = 1
  call self.flush()
  if has_key(self._read)
    unlet self._buffer
  endif
  if has_key(self._written)
    unlet self._written
  endif
endfunction


""
" Return the file class object.
"
function! object#file#file_()
  return s:file
endfunction

""
" @dict file
" We cannot stop people doing let file.closed = 1, but with object#setattr(),
" stupid things can be prevented.
" @throws AttributeError if anyone attempts to setattr for a file object.
"
function! object#file#__setattr__(name, val) dict
  throw object#AttributeError('%s object attribute %s is readonly',
        \ object#types#name(self), string(a:name))
endfunction

""
" @dict file
" Hide the private attributes from dir()
"
function! object#file#__dir__() dict
  return filter(keys(self), 'v:val !~# s:private_attrs')
endfunction

""
" @dict file
" Hide the private attributes from getattr().
"
function! object#file#__getattr__(name) dict
  if !has_key(self, a:name) || a:name =~# s:private_attrs
    throw object#AttributeError('%s object has no attribute %s',
          \ object#types#name(self), string(a:name))
  endif
  return self[a:name]
endfunction

""
" @dict file
" __bool__(file) <==> file is not closed.
"
function! object#file#__bool__() dict
  return !self.closed
endfunction

""
" @dict file
" __iter__(file) <==> each line of file.
"
function! object#file#__iter__() dict
  call s:lazy_readfile(self)
  return self._read
endfunction

""
" @dict file
" Initialize a file object with {name} and {mode}.
" @throws WrongType if {mode} is not a String.
" @throws ValueError is {mode} string is invalid.
" @throws IOError if the file is not readable or writable.
"
function! object#file#__init__(name, mode) dict
  let name = maktaba#ensure#IsString(a:name)
  let mode = maktaba#ensure#IsString(a:mode)
  if empty(mode)
    throw object#ValueError('empty mode string')
  endif
  if mode !~# s:mode_pattern
    let msg = "mode string must begin with one of 'r', 'w' or 'a', not %s"
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

""
" @dict file
" __repr__(file) <==> filename and mode.
"
function! object#file#__repr__() dict
  return printf('<open file %s, mode %s>', string(self.name), string(self.mode))
endfunction

"
" a stands for append.
" b stands for binary.
"
function! s:write_flags(mode)
  return join(map(['a', 'b'], 'stridx(a:mode, v:val)>0?v:val:""'), '')
endfunction

"
" Extract flags to |readfile()| from mode string.
"
function! s:read_flags(mode)
  return stridx(mode, 'b')>0?'b':''
endfunction

"
" Ensure that {file} is opened for reading.
"
function! s:read_mode(file)
  call s:ensure_opened(a:file)
  if a:file.mode =~# s:readable
    return
  endif
  throw object#IOError('File not open for reading')
endfunction

"
" Ensure that {file} is opened for writing.
"
function! s:write_mode(file)
  call s:ensure_opened(a:file)
  if a:file.mode =~# s:writable
    return
  endif
  throw object#IOError('File not open for writing')
endfunction

"
" Lazily read all the lines from {file}.
"
function! s:lazy_readfile(file)
  call s:read_mode(self)
  if has_key(a:file, '_read')
    return
  endif
  try
    let lines = readfile(a:file.name, s:read_flags(a:file.mode))
    let a:file._read = object#iter(lines)
  catch
    throw object#IOError('cannot read file %s', string(a:file.name))
  endtry
endfunction

"
" Ensure that {file} is not closed.
" @throws IOError if it is closed.
"
function! s:ensure_opened(file)
  if !a:file.closed
    return
  endif
  throw object#IOError('I/O operation on cloesd file')
endfunction

"
" Return patterns for valid mode string, readable and writable mode string.
" Append counts as writable.
"
function! object#file#patterns()
  return [s:mode_pattern, s:readable, s:writable]
endfunction

