if exists('s:object_vim_loaded') && s:object_vim_loaded
  finish
endif
let s:object_vim_loaded = 1

function! s:print_(args)
  let str = join(map(a:args, 'object#repr(v:val)'), ' ')
  echo str
endfunction

function! s:print(...)
  call s:print_(copy(a:000))
endfunction

command! ObjectShell call object#shell#run()
command! -complete=expression -nargs=* Repr call <SID>print(eval(<f-args>))
command! -complete=expression -nargs=1 Dir echo object#dir(<args>)
