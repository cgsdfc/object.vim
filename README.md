# object.vim
> An object-oriented framework for Vimscript.

[![Build Status](https://travis-ci.org/cgsdfc/object.vim.svg?branch=master)](https://travis-ci.org/cgsdfc/object.vim)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![codecov](https://codecov.io/gh/cgsdfc/object.vim/branch/master/graph/badge.svg)](https://codecov.io/gh/cgsdfc/object.vim)

```
               __      _           __
        ____  / /_    (_)__  _____/ /_
       / __ \/ __ \  / / _ \/ ___/ __/
      / /_/ / /_/ / / /  __/ /__/ /_
      \____/_.___/_/ /\___/\___/\__/
                /___/
```
An object-oriented framework for Vimscript that looks and feels like Python and
strives for maximum convenience and compatibility with built-in functions.

# Examples
- Defining classes and creating instances.
```vim
let MyClass = object#class('MyClass')
let var = object#new(MyClass)
```

- Calling methods of parents and siblings with `super()`.
```vim
" MyClass as above.
function! MyClass.__init__()
  call object#super(MyClass, self).__init__()
  let self.data = 1
endfunction
```

- Creating Lambdas.
```vim
let x = reverse(range(3))
echo sort(x, object#lambda('x y', 'x - y'))
[0, 1, 2]
```

- Iterator and for loop construct.
```vim
echo object#list(object#zip('abc', range(3)))
[['a', 0], ['b', 1], ['c', 2]]

let dict = {'foo': 1, 'bar': 2}
call object#for('key val', items(dict), 'echo key val')
foo 1
bar 2
```

- Open files for reading and writing.
```vim
let f = object#open('data.txt', 'r')
echo object#repr(f)
<open file 'data.txt', mode 'r'>

echo f.read()
'All the lines concatenated with newline.'
```

- Wrappers for built-in types for inheritance.
```vim
let dict = object#dict_()
echo object#repr(dict)
<'dict' type>

let MyDict = object#class('MyDict', dict)
let var = object#new(MyDict, {'foo': 1})
echo var.values()
[['foo', 1]]
```

- A bunch of hookable protocol functions.
```vim
echo object#len(range(10))
10

echo object#contains('', 'string')
1

let object = object#object_()
echo object#dir(object)
['__name__', '__bases__', '__base__', '__repr__', '__class__', '__init__', '__mro__']
```

- Hashing arbitrary objects.
```vim
echo object#hash('this is a string')
197650594

echo object#hash(-1234)
2147482414

echo object#hash(function('tr'))
233815837
```

# Features
* Shallow namespace `object#`.
* Multiple inheritance powered by C3 linearization.
* A complete set of Python-like built-in functions.
* True lambda with closure and named arguments.
* True iterator and `zip()` and `enumerate()`.
* Hash (nearly) arbitrary object.
* Read and write files with `open()`.

# Future Work
* Increase coverage of `file.vim` and `list.vim`.
* Finish `compare.vim` for hookable comparition.
* Add `str.vim` for Python-like formatting.
* Better documentation.
* Improve performance.

# Installation
This plugin follows the standard runtime path structure,
and as such it can be installed with a variety of plugin managers:

| Plugin Manager  | Install with... |
| -------------   | ------------- |
| [NeoBundle][4] | `NeoBundle 'cgsdfc/object.vim'` |
| [Vundle][5]    | `Plugin 'cgsdfc/object.vim'` |
| [Plug][6]      | `Plug 'cgsdfc/object.vim'` |
| [VAM][7]       | `call vam#ActivateAddons(['vim-airline'])` |
| [Dein][8]      | `call dein#add('cgsdfc/object.vim')` |
| [minpac][9]    | `call minpac#add('cgsdfc/object.vim')` |


# Dependencies

* [vim-maktaba][1] for handling built-in type.
* [vader.vim][2] for unit tests.
* [vimdoc.vim][3] for generating the help file from comments.

# Documentation

`:help object`

# License

MIT License. Copyright (c) 2018-2019 cgsdfc.

[1]: https://github.com/google/vim-maktaba
[2]: https://github.com/junegunn/vader.vim
[3]: https://github.com/google/vimdoc

[4]: https://github.com/Shougo/neobundle.vim
[5]: https://github.com/VundleVim/Vundle.vim
[6]: https://github.com/junegunn/vim-plug
[7]: https://github.com/MarcWeber/vim-addon-manager
[8]: https://github.com/Shougo/dein.vim
[9]: https://github.com/k-takata/minpac/
