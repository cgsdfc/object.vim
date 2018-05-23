function! object#shell#run()
  while 1
    let x = input('>>> ', '', 'expression')
    if x =~# '\v\C^\s*$'
      echo "\n"
      continue
    endif
    try
      let Val = eval(x)
    catch
      echo printf("\n%s", v:exception)
      continue
    endtry
    echo "\n"
    echo object#repr(Val)
  endwhile
  return 0
endfunction
