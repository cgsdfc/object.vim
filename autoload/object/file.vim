""
" @section File, file
" A simple interface to the |readfile()| and |writefile()| functions.
" Features:
"   * Lazy reading and writing.
"   * Line-oriented I/O.
"   * Handle errors with IOError.
"   * Mode string syntax like 'a', 'w' or '+', 'b'.
"
" Limitations:
"   * The file is always buffered.
"   * The content of the file object is not synchronized with external changes to the
"     underlying file.
"   * The file is unseekable. All reading or writing happens essentially at the
"     current line number.
"   * No context manager available. Must call f.close() explicitly or you may
"     lost written data.
"
" Note:
"   * Unlike the counterparts from Python, readlines() always strips tailing newlines and
"   * writelines() always adds tailing newlines.
"
" Examples:
" >
"   Your file is
"   1
"   2
"   3
"   :echo f.readlines()
"   ['1', '2', '3']
"
"   :call f.writelines(range(3))
"   :call f.close()
"   Your file becomes
"   1
"   2
"   3
" <
" This is rooted at the nature of |readfile()| and |writefile()|.

let s:readable =    '\V\C\^\(r\[aw+]\?\|\[aw]\[r+]\)b\?\$'
let s:writable =    '\V\C\^\(\[aw]\[r+]\?\|r\[aw+]\)b\?\$'
let s:valid_mode =  '\V\C\^\(r\[aw+]\?\|\[aw]\[r+]\|\[aw]\[r+]\?\|r\[aw+]\)b\?\$'

let s:closed_exception = 'I/O operation on closed file'

""
" @dict file
" A file object for line-oriented I/O.

let s:file = object#class('file')

""
" @function open(...)
" Open a file.
" >
"   open(filename) -> open for reading.
"   open(filename, mode) -> open for mode.
" <
" The [mode] can be 'r', 'w' or 'a' for reading (default), writing or appending,
" respectively.
" The file will be created if it doesn't exist when opened for writing or appending.
" It will be truncated when opened for writing.
" Add a 'b' to the [mode] for binary files. See |readfile()| and |writefile()|.
" Add a '+' to the [mode] to allow simultaneous reading and writing.
function! object#file#open(name, ...)
  call object#util#ensure_argc(1, a:0)
  let mode = a:0 ? a:1 : 'r'
  return object#new(s:file, a:name, mode)
endfunction

""
" @dict file
" Initialize a file object with {name} and {mode}.
" @throws WrongType if {mode} is not a String.
" @throws ValueError is {mode} string is invalid.
" @throws IOError if the file is not readable or writable.
function! s:file.__init__(name, mode)
  let name = maktaba#ensure#IsString(a:name)
  let mode = maktaba#ensure#IsString(a:mode)
  if mode !~# s:valid_mode
    throw object#ValueError('invalid mode ''%s''', mode)
  endif

  if mode =~# s:readable
    if !filereadable(name)
      throw object#IOError('file not readable: ''%s''', name)
    endif
    let self._rflags = object#file#read_flags(mode)
  endif

  if mode =~# s:writable
    if maktaba#path#Exists(name) && !filewritable(name)
      throw object#IOError('file not writable: ''%s''', name)
    endif
    let self._wflags = object#file#write_flags(mode)
    let self._wbuf = []
  endif

  let self.name = name
  let self.mode = mode
  let self.closed = 0
endfunction

""
" Return the file class object.
function! object#file#file_()
  return s:file
endfunction

""
" @dict file
" __bool__(file) <==> file is not closed.
function! s:file.__bool__()
  return !self.closed
endfunction

""
" @dict file
" __iter__(file) <==> each line of file.
function! s:file.__iter__()
  call self._check_readable()
  return self._rbuf
endfunction

""
" @dict file
" __repr__(file) <==> repr(file)
function! s:file.__repr__()
  return printf('<%s file ''%s'', mode ''%s''>',
        \ self.closed ? 'closed' : 'open', self.name, self.mode)
endfunction

""
" @dict file
" __str__(file) <==> str(file)
function! s:file.__str__()
  return self.__repr__()
endfunction

function! s:file.__hash__()
  " Note: Python2 open/closed file hash the same.
  " However, mode does matter.
  return object#hash(printf('%s%s', self.name, self.mode))
endfunction

""
" @dict file
" Read the the whole of the file, return it as a string.
" Lines are joint with a NL character.
function! s:file.read()
  return join(self.readlines(), "\n")
endfunction

""
" @dict file
" Return the next line from the file.
" Return an empty string at EOF.
"
" Note: Newlines are stripped.
function! s:file.readline()
  call self._check_readable()
  try
    return object#next(self._rbuf)
  catch /StopIteration/
    return ''
  endtry
endfunction

""
" @dict file
" Return a list of strings, each a line from the file.
"
" Note: Newlines are stripped.
function! s:file.readlines()
  call self._check_readable()
  return object#list(self._rbuf)
endfunction

""
" @dict file
" Write a {str} to the file.
" {str} is appended to the last line of file.
"
" Note: If {str} becomes the first line of the file, a newline will be added
" right after this line as if it is done with writeline().
function! s:file.write(str)
  call self._check_writable()
  let str = maktaba#ensure#IsString(a:str)
  if empty(self._wbuf)
    call add(self._wbuf, str)
  else
    let self._wbuf[-1] .= str
  endif
endfunction

""
" @dict file
" Write a {line} to the file.
function! s:file.writeline(line)
  call self._check_writable()
  call add(self._wbuf, maktaba#ensure#IsString(a:line))
endfunction

""
" @dict file
" Write a sequence of strings to the file.
" @throws WrongType if {iter} returns non-string.
function! s:file.writelines(iter)
  call self._check_writable()
  let iter = object#iter(a:iter)
  try
    while 1
      call add(self._wbuf, maktaba#ensure#IsString(object#next(iter)))
    endwhile
  catch /StopIteration/
    return
  endtry
endfunction

""
" @dict file
" Flush the written data.
" @throws IOError if |writefile()| fails.
function! s:file.flush()
  if self.closed
    throw object#IOError(s:closed_exception)
  endif
  if self.mode !~# s:writable
    return
  endif
  try
    call writefile(self._wbuf, self.name, self._wflags)
  catch /E482/
    throw object#IOError('cannot create file ''%s''', self.name)
  endtry
endfunction

""
" @dict file
" Close the file and flush it. After that any file operation will fail.
" Calling close() multiple times does not causes errors.
function! s:file.close()
  if self.closed
    return
  endif
  call self.flush()
  if has_key(self, '_rbuf')
    unlet self._rbuf
  endif
  if has_key(self, '_wbuf')
    unlet self._wbuf
  endif
  let self.closed = 1
endfunction

""
" @dict file
" Return whether the file is opened for reading.
function! s:file.readable()
  if self.mode !~# s:readable
    return 0
  endif
  if !self.closed
    return 1
  endif
  throw object#IOError(s:closed_exception)
endfunction

""
" @dict file
" Return whether the file is opened for writing.
function! s:file.writable()
  if self.mode !~# s:writable
    return 0
  endif
  if !self.closed
    return 1
  endif
  throw object#IOError(s:closed_exception)
endfunction

"
" Private Helpers
"
function! object#file#read_flags(mode)
  return matchstr(a:mode, 'b')
endfunction

function! object#file#write_flags(mode)
  return join(map(['a', 'b'], 'stridx(a:mode, v:val)>=0?v:val:""'), '')
endfunction

" Ensure that {file} is opened for writing and it is writable.
function! s:file._check_writable()
  if self.closed
    throw object#IOError(s:closed_exception)
  endif
  if maktaba#path#Exists(self.name) && !filewritable(self.name)
    throw object#IOError('file not writable: ''%s''', self.name)
  endif
  if self.mode !~# s:writable
    throw object#IOError('file not open for writing')
  endif
endfunction

" Ensure that {file} is opened for reading and it is readable.
function! s:file._check_readable()
  if self.closed
    throw object#IOError(s:closed_exception)
  endif
  if self.mode !~# s:readable
    throw object#IOError('file not open for reading')
  endif
  if !filereadable(self.name)
    throw object#IOError('file not readable: ''%s''', self.name)
  endif
  if has_key(self, '_rbuf')
    return
  endif

  try
    let lines = readfile(self.name, self._rflags)
  catch /E484/
    throw object#IOError('cannot open file ''%s''', self.name)
  catch /E485/
    throw object#IOError('cannot read file ''%s''', self.name)
  endtry
  let self._rbuf = object#iter(lines)
endfunction

" Return patterns for valid mode string, readable and writable mode string.
" Append counts as writable.
function! object#file#patterns()
  return [s:valid_mode, s:readable, s:writable]
endfunction
