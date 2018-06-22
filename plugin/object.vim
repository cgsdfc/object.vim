if exists('s:object_vim_loaded') && s:object_vim_loaded
  finish
endif
let s:object_vim_loaded = 1

function! s:print_(args)
  let str = join(map(a:args, 'object#repr(eval(v:val))'), ' ')
  echo str
endfunction

function! s:print(...)
  call s:print_(copy(a:000))
endfunction

command! ObjectShell call object#shell#run()
command! -complete=expression -nargs=* Repr call <SID>print(<f-args>)
