# The Recursive inclusion limit exceeded problem

## What is the problem
Inside this directory there is a ``main.vader``, which includes a ``sub.vader``, which in turn,
includes a bunch of ``sub{id}.vader``, which is all empty files. When you run ``:Vader %`` with
``main.vader`` in the Vim buffer, Vader will show you an error:

```
Error detected while processing function <SNR>77_vader[5]..vader#run:
line   96:
Vader error: Vim(echoerr):Recursive inclusion limit exceeded (in function <SNR>77_vader[5]..vader#run[36]..vader#pars
er#parse[1]..<SNR>142_read_vader, line 19)
```

It sounds like the inclusion stack (if any) of Vader is too deep to allow it to functioning.
But the situation is, we have a file ``sub.vader`` which is including a lot of files, while the
_depth_ of inclusion is rather modist (it is only 2, guys). So it is confusing. As we know,
C preprocessor like ``cpp`` won't halt because one use too much ``#include`` in one file.

What's more, the error message is a bit misleading. It mentions *Recursive*, but we are not doing any
recursive inclusion here. It talks about *limit*, but we don't know what _kind_ of limit is it talking
about. It is the limit of depth or limit of width (the number of ``Include`` you can use in one file)?

Well, Vader has been a great tool. I wrote a ton of vader scripts and don't want to give it up. All I
want here is an explanantion about what's happening from those who knows Vader better than me. And I
want work-around or fix-up if possible.

To reproduce the problem, just go to ``main.vader`` with Vim and fire Vader.
