if exists('s:object_vim_loaded') && s:object_vim_loaded
  finish
endif
let s:object_vim_loaded = 1

command ObjectShell call object#shell#run()
