# dotfiles

> my personal dotfiles for \*nix.

## setup

in order to set up all these config files for yourself, simply clone the repository and run the `setup.sh` script:

```bash
# --recursive is important here as i use submodules to include some other repos like zsh plugins
git clone --recursive https://github.com/foxfirecodes/dotfiles.git
cd dotfiles
./setup.sh
```

this uses stow to symlink various packages into the appropriate places. by default not all packages are stowed (see `default_stows` at the bottom of `setup.sh`) as some of them are platform specific.

if you want to stow a package not covered by the default stows just use `./stow.sh`:

```bash
# symlink a package
./stow.sh <package>

# example with ghostty package
./stow.sh ghostty
```

(this is just a thin wrapper script to pass the right flags to GNU stow to ensure things are symlinked to your home directory and relative to this current directory)

the availabe packages are just the root directories of this repo (with the exception of `dconf` and `misc`)

## fonts

https://github.com/IdreesInc/Monocraft (i use the nerdfont version ofc)
