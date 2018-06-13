""
" @section File, file
" A simple interface to the |readfile()| and |writefile()| functions.
" Features:
"   * Lazy reading and writing.
"   * Line-oriented I/O.
"   * Handle errors with IOError.
"   * Mode string syntax like 'a', 'w' or '+', 'b'.
"
" file.read()                                                      *file.read()*
"   Read the the whole of the file, return it as a string. Lines are joint with
"   a NL character.
"
" file.readline()                                              *file.readline()*
"   Return the next line from the file. Return an empty string at EOF.
"
"   Note: Newlines are stripped.
"
" file.readlines()                                            *file.readlines()*
"   Return a list of strings, each a line from the file.
"
"   Note: Newlines are stripped.
"
" file.write({str})                                               *file.write()*
"   Write a {str} to the file. {str} is appended to the last line of file.
"
"   Note: If {str} becomes the first line of the file, a newline will be added
"   right after this line as if it is done with writeline().
"
" file.writeline({line})                                      *file.writeline()*
"   Write a {line} to the file.
"
" file.writelines({iter})                                    *file.writelines()*
"   Write a sequence of strings to the file.
"   Throws ERROR(WrongType) if {iter} returns non-string.
"
" file.flush()                                                    *file.flush()*
"   Flush the written data.
"   Throws ERROR(IOError) if |writefile()| fails.
"
" file.close()                                                    *file.close()*
"   Close the file and flush it. After that any file operation will fail.
"   Calling close() multiple times does not causes errors.
"
" file.readable()                                              *file.readable()*
"   Return whether the file is opened for reading.
"
" file.writable()                                              *file.writable()*
"   Return whether the file is opened for writing.
"
" file.__bool__()                                              *file.__bool__()*
"   __bool__(file) <==> file is not closed.
"
" file.__iter__()                                              *file.__iter__()*
"   __iter__(file) <==> each line of file.
"
" file.__init__({name}, {mode})                                *file.__init__()*
"   Initialize a file object with {name} and {mode}.
"   Throws ERROR(WrongType) if {mode} is not a String.
"   Throws ERROR(ValueError) is {mode} string is invalid.
"   Throws ERROR(IOError) if the file is not readable or writable.
"
" file.__repr__()                                              *file.__repr__()*
"   __repr__(file) <==> repr(file)
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

" The pattern of a mode string is beginning with 'r', 'a' or 'w' and followed
" by zero or more arbitrary characters.
let s:mode_pattern = '\v\C^[raw].*$'

" The pattern for writable mode is a mode_pattern containing 'a', 'w' or 'r+'.
let s:writable = '\v\C([aw]|r.*\+)'

" The pattern for readable mode is a mode_pattern that contains 'r', w+ or a+.
let s:readable = '\v\C(r|[aw].*\+)'

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
  if empty(mode)
    throw object#ValueError('empty mode string')
  endif
  if mode !~# s:mode_pattern
    let msg = "mode string must begin with one of 'r', 'w' or 'a', not %s"
    throw object#ValueError(msg, string(mode))
  endif

  if mode =~# s:readable && !filereadable(name)
    throw object#IOError('file not readable: %s', string(name))
  endif

  if mode =~# s:writable && !filewritable(name)
    throw object#IOError('file not writable %s', string(name))
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
  call s:lazy_readfile(self)
  return self._read
endfunction

""
" @dict file
" __repr__(file) <==> repr(file)
function! s:file.__repr__()
  return printf('<%s file %s, mode %s>', self.closed ? 'closed' : 'open',
        \ string(self.name), string(self.mode))
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
"
" Note: Newlines are stripped.
function! s:file.readlines()
  call s:lazy_readfile(self)
  return object#list(self._read)
endfunction

""
" @dict file
" Write a {str} to the file.
" {str} is appended to the last line of file.
"
" Note: If {str} becomes the first line of the file, a newline will be added
" right after this line as if it is done with writeline().
function! s:file.write(str)
  call s:write_mode(self)
  let str = maktaba#ensure#IsString(a:str)
  if !has_key(self, '_written')
    let self._written = [str]
    return
  endif
  let self._written[-1] .= str
endfunction

""
" @dict file
" Write a {line} to the file.
function! s:file.writeline(line)
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
function! s:file.writelines(iter)
  call s:write_mode(self)
  let iter = object#iter(a:iter)
  if !has_key(self, '_written')
    let self._written = []
  endif
  " It will be too slow if we first consume the iter and then
  " check for IsString.
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
function! s:file.flush()
  if self.closed
    throw object#IOError(s:closed_exception)
  endif
  " Note: Testing ``self.mode ~=# s:readable`` is not ok here. Think about 'rw'.
  if self.mode !~# s:writable || !has_key(self, '_written')
    return
  endif
  try
    call writefile(self._written, self.name, s:write_flags(self))
  catch /E482/
    throw object#IOError('cannot create file %s', string(self.name))
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
  if has_key(self, '_read')
    unlet self._read
  endif
  if has_key(self, '_written')
    unlet self._written
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

" a stands for append.
" b stands for binary.
function! s:write_flags(file)
  if has_key(a:file, '_wflags')
    return a:file._wflags
  endif
  let flags = join(map(['a', 'b'], 'stridx(a:file.mode, v:val)>0?v:val:""'), '')
  let a:file._wflags = flags
  return flags
endfunction

" Extract flags to |readfile()| from mode string.
function! s:read_flags(file)
  if has_key(a:file, '_rflags')
    return a:file._rflags
  endif
  let flags = stridx(a:file.mode, 'b')>0?'b':''
  let a:file._rflags = flags
  return flags
endfunction

" Ensure that {file} is opened for reading and it is readable.
function! s:read_mode(file)
  if a:file.closed
    throw object#IOError(s:closed_exception)
  endif
  if a:file.mode !~# s:readable
    throw object#IOError('File not open for reading')
  endif
  if !filereadable(a:file.name)
    throw object#IOError('file not readable: %s', string(a:file.name))
  endif
endfunction

" Ensure that {file} is opened for writing and it is writable.
function! s:write_mode(file)
  if a:file.closed
    throw object#IOError(s:closed_exception)
  endif
  if a:file.mode !~# s:writable
    throw object#IOError('File not open for writing')
  endif
  if !filewritable(a:file.name)
    throw object#IOError('file not writable: %s', string(a:file.name))
  endif
endfunction

" Lazily read all the lines from {file}.
function! s:lazy_readfile(file)
  call s:read_mode(a:file)
  if has_key(a:file, '_read')
    return
  endif
  try
    let lines = readfile(a:file.name, s:read_flags(a:file))
  catch /E484/
    throw object#IOError('cannot open file %s', string(a:file.name))
  catch /E485/
    throw object#IOError('cannot read file %s', string(a:file.name))
  endtry
  let a:file._read = object#iter(lines)
endfunction

" Return patterns for valid mode string, readable and writable mode string.
" Append counts as writable.
function! object#file#patterns()
  return [s:mode_pattern, s:readable, s:writable]
endfunction
