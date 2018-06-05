# object.vim
[![Build Status](https://travis-ci.org/cgsdfc/object.vim.svg?branch=master)](https://travis-ci.org/cgsdfc/object.vim)

```
               __      _           __
        ____  / /_    (_)__  _____/ /_
       / __ \/ __ \  / / _ \/ ___/ __/
      / /_/ / /_/ / / /  __/ /__/ /_
      \____/_.___/_/ /\___/\___/\__/
                /___/
```
An object-oriented framework for Vim that looks and feels like Python.
Strive for maximum convenience and compatibility with built-in functions.

# Features

* Shallow namespace `object#`.
* Multiple inheritance powered by C3 linearization.
* A complete set of Python-like built-in functions.
* True lambda with closure and named arguments.
* True iterator and `zip()` and `enumerate()`.
* Hash (nearly) arbitrary object.
* Read and write files with `open()`.
* No configuration is needed. Everything works out of the box.
* A comprehensive test suite.

# Status
Currently this project is in alpha stage. Most of the API is stable with some exceptions.
Features are adding in and so are tests. Feel free to try it out. Feedbacks are welcome.
_Don't put it into real battles right now._

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

# Rationale
There's already Python and Vimscript, why mix them together?

* A more serious object-oriented framework.
* There is good way to follow and I choose Python.
* Vimscript writers mostly know Python.

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
