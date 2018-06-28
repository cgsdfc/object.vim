let s:whitespace = '\V\C\^\s\*\$'
" TODO: We should disable some dangerous commands/enable
" only a subset of commands

function! object#shell#run()
  while 1
    let user_input = input('>>> ', '', 'expression')
    if user_input =~# s:whitespace
      echo "\n"
      continue
    endif

    try
      echo printf("\n%s", object#repr(eval(user_input)))
    catch /E121/
      try
        echo "\n"
        execute user_input
      catch
        echo v:exception
      endtry
    catch
      echo "\n"
      echo v:exception
    endtry
  endwhile
endfunction
