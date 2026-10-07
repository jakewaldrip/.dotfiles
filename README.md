# dotfiles

Personal macOS dev environment: zsh, neovim, ghostty, starship, and opencode config,
managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Install

```sh
git clone https://github.com/jakewaldrip/.dotfiles.git ~/.dotfiles
~/.dotfiles/install/install.sh
```

The script is idempotent. Re-run it any time to pick up new tools.

### What it does

Every step is idempotent and reports whether it changed anything. The script
runs them in this order:

| # | Step | Detail |
|---|---|---|
| 1 | Platform guard | Exits cleanly on anything other than macOS |
| 2 | Xcode CLT | Installs if missing. Provides `gcc`, `make`, and `git` |
| 3 | Homebrew | Installs if missing, then loads `brew shellenv` for the rest of the run |
| 4 | Brewfile | `brew bundle` against `install/Brewfile`: 24 formulae, 4 casks, 2 taps |
| 5 | Rust | `rustup` via rustup.rs, then sources `~/.cargo/env` |
| 6 | Cargo crates | `eza`, `zoxide`, `rnvm`, `tree-sitter-cli` |
| 7 | uv | Python package manager. Creates the `~/.local/bin/env` that `.zshrc` sources |
| 8 | uv tools | `pybritive` |
| 9 | opencode | v2 via `curl -fsSL https://opencode.ai/v2/install \| bash`, into `~/.opencode/bin` |
| 10 | Stale symlinks | Removes dangling links in `$HOME` before stow runs |
| 11 | Symlinks | Conflict pre-check, then `stow --restow` into `$HOME` |
| 12 | `this-env.sh` | Creates an empty one if missing |
| 13 | Git identity | Prompts for `user.name` and `user.email` |
| 14 | SSH | Generates an ed25519 key, writes `~/.ssh/config`, uploads to GitHub as both an authentication and a signing key |
| 15 | Git identity | Writes `~/.gitconfig.local`, including the signing key from step 14 |
| 16 | Login shell | `chsh` to Homebrew zsh |
| 17 | Node | `rnvm install --lts` if no version is present |
| 18 | opencode plugin | `bun install` in `~/.config/opencode/plugins/no-external-skills` |

The order matters in two places. Git identity is split across steps 13 and 15 so
the email is known before the SSH key is generated, and so the key path can fill
in `user.signingkey` afterwards. Dangling links are pruned at step 10 because
stow treats them as conflicts.

### Packages

`install/Brewfile` is the single source of truth. Current contents:

| Group | Packages |
|---|---|
| Shell | `stow`, `starship`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf` |
| Core CLI | `ripgrep`, `fd`, `jq`, `difftastic`, `coreutils` |
| Git | `gh`, `graphite`, `pre-commit` |
| Editor + LSP | `neovim`, `lua-language-server`, `typescript-language-server` |
| Formatters | `stylua`, `prettier` (used by `conform.nvim` on save) |
| Runtimes | `node`, `pnpm`, `bun`, `pyenv` |
| Infra | `tenv`, `tflint` |
| Casks | `ghostty`, `font-0xproto-nerd-font`, `gcloud-cli`, `dbeaver-community` |

`difftastic` is not optional: `.gitconfig` sets `diff.external = difft`, so
`git diff` fails without it. The font matches the `font-family` in
`.config/ghostty/config`.

Things installed outside Homebrew, because each has a reason:

| Tool | Why not brew |
|---|---|
| `rustup` + cargo crates | Toolchain manages itself |
| `uv`, `pybritive` | `uv tool`, which avoids pip conflicting with pyenv |
| `opencode` | `.zshrc` puts `~/.opencode/bin` ahead of `/opt/homebrew/bin` on PATH, so a brew install would be shadowed. The installer also keeps `opencode upgrade` working |
| Node versions | `rnvm`, not `nvm` |

### Prompts

Two: git `user.name` and `user.email`. The SSH key name is defaulted to
`$USER_$(hostname -s)`; press Enter to accept it.

Pre-seed them to run unattended:

```sh
GIT_NAME="your-name" GIT_EMAIL="you@example.com" ~/.dotfiles/install/install.sh
```

### Stow conflicts

If a real file already sits where a symlink should go, the script lists the
conflicts and stops without touching anything. Either move the files aside and
re-run, or let stow absorb them into the repo:

```sh
ADOPT=1 ~/.dotfiles/install/install.sh
git -C ~/.dotfiles diff   # review what was absorbed
```

### SSH and commit signing

`.gitconfig` sets `commit.gpgsign = true` with `gpg.format = ssh`, so commits
are signed with the SSH key. GitHub needs that key registered **twice**, once as
an authentication key and once as a signing key. A key added only for
authentication still pushes fine, but commits show as Unverified.

The script handles both uploads when `gh` is authenticated. Otherwise it copies
the public key to the clipboard and prints the commands to run later:

```sh
gh ssh-key add ~/.ssh/<key>.pub --title "<host>" --type authentication
gh ssh-key add ~/.ssh/<key>.pub --title "<host> (signing)" --type signing
```

## Manual steps

- Fill in `~/zsh/this-env.sh` with machine-specific env vars and tokens. It is
  gitignored and starts empty, so nothing depending on it works until you do.
- Sign in to GUI apps.

## commons and nvm

The commons repo pins Node through `.nvmrc` and `scripts/cli/.zsh_cityblock`,
which lazy-loads nvm and replaces `node`, `npm`, `npx`, `pnpm`, `pnpx`, and
`corepack` with shell functions.

These dotfiles use `rnvm` instead and deliberately do **not** source that file.
Sourcing it would shadow rnvm-managed Node.

The Brewfile already covers the machine-level tools that commons'
`scripts/cli/dev_setup.sh` installs: `coreutils`, `pre-commit`, `bun`, `tenv`,
`tflint`, `gcloud-cli`, `dbeaver-community`, and `pybritive`. What it does not
cover is repo-specific and needs the checkout plus Britive auth: `.env` from
Secret Manager, the dev and test databases, GAR npm auth, cloud-sql-proxy, and
`pnpm install`.

If you need those, run the subsystems individually:

```sh
pnpm dev-setup --dotenv --dev-db
```

Avoid the `shell` subsystem. It appends a `source .zsh_cityblock` line to
`~/.zshrc`, which is a symlink into this repo, so it would modify a tracked file
and break rnvm.

## Project configs

`misc/` holds per-repo opencode config that is deliberately not stowed, since
repo paths vary by machine. Link it on demand:

```sh
~/.dotfiles/install/link-project.sh commons ~/code/commons
~/.dotfiles/install/link-project.sh chronos ~/notes/chronos
```

Run with no arguments to list what is available.

## Layout

```
.dotfiles/
├── .config/          stowed into ~/.config  (nvim, ghostty, opencode, starship)
├── zsh/              stowed into ~/zsh      (aliases, plugins, scripts)
├── install/          Brewfile, install.sh, link-project.sh
├── misc/             per-project configs, linked on demand
└── wallpapers/
```

`.stow-local-ignore` keeps `install/`, `misc/`, `wallpapers/`, and `README.md`
out of `$HOME`. Note that defining that file overrides stow's built-in ignore
list, so the version-control defaults are repeated in it. Without them stow
tries to link `.git` into `$HOME`.

Two files are generated per machine and stay out of git:

| File | Contents |
|---|---|
| `~/.gitconfig.local` | `[user]` name, email, signing key. Pulled in by an `include` in the tracked `.gitconfig` |
| `~/zsh/this-env.sh` | Work tokens and machine-specific env. Sourced by `.zshrc` if present |

## Linux

The configs branch on `uname` and work on Linux, but `install.sh` is macOS-only
and exits cleanly elsewhere. Install the `install/Brewfile` equivalents with your
package manager, then run `stow --restow --target="$HOME" .` from the repo root.
