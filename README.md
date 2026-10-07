# dotfiles

macOS dev environment managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Set up a new machine

```sh
git clone https://github.com/jakewaldrip/.dotfiles.git ~/.dotfiles
~/.dotfiles/install/install.sh
```

Answer the prompts for git `user.name` and `user.email`. Press Enter to accept
the default SSH key name. Restart the terminal when it finishes.

Then fill in `~/zsh/this-env.sh` with machine-specific env vars and tokens, and
sign in to GUI apps.

Re-run the script any time; it skips whatever is already in place.

## Run it unattended

```sh
GIT_NAME="your-name" GIT_EMAIL="you@example.com" ~/.dotfiles/install/install.sh
```

## Resolve stow conflicts

When a real file sits where a symlink belongs, the script lists it and stops.
Move the files aside and re-run, or absorb them into the repo:

```sh
ADOPT=1 ~/.dotfiles/install/install.sh
git -C ~/.dotfiles diff
```

## Finish the GitHub SSH setup

Skip this if `gh` was authenticated during install. Otherwise add the key as
both types:

```sh
gh ssh-key add ~/.ssh/<key>.pub --title "<host>" --type authentication
gh ssh-key add ~/.ssh/<key>.pub --title "<host> (signing)" --type signing
```

Verify:

```sh
ssh -T git@github.com
git log --show-signature -1
```

## Add a package

Edit `install/Brewfile`, then:

```sh
brew bundle --file=~/.dotfiles/install/Brewfile
```

For a cargo crate, add it to the `crates` array in `install/install.sh`.

## Add a dotfile

Move the file into the repo under its path relative to `$HOME`, then restow:

```sh
mv ~/.config/foo/bar.toml ~/.dotfiles/.config/foo/bar.toml
cd ~/.dotfiles && stow --restow --target="$HOME" .
```

To keep something out of `$HOME`, add it to `.stow-local-ignore`. That file
replaces stow's built-in ignore list, so keep the version-control defaults in
it.

## Link a project config

```sh
~/.dotfiles/install/link-project.sh <name> <target-dir>
```

Run with no arguments to list what `misc/` provides.

## Set machine-local config

| File | Contents |
|---|---|
| `~/.gitconfig.local` | `[user]` name, email, signing key |
| `~/zsh/this-env.sh` | Work tokens and machine-specific env |

Both are gitignored and created by the install script.

## Install on Linux

`install.sh` is macOS-only and exits cleanly elsewhere. Install the
`install/Brewfile` equivalents with your package manager, then:

```sh
cd ~/.dotfiles && stow --restow --target="$HOME" .
```

## Layout

```
.dotfiles/
├── .config/          stowed into ~/.config
├── zsh/              stowed into ~/zsh
├── install/          Brewfile, install.sh, link-project.sh
├── misc/             per-project configs, linked on demand
└── wallpapers/
```
