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

| Step | Detail |
|---|---|
| Xcode CLT | Installs if missing (provides `gcc`, `make`, `git`) |
| Homebrew | Installs if missing, then runs `brew bundle` against `install/Brewfile` |
| Rust | `rustup` via rustup.rs, then the cargo crates: `eza`, `zoxide`, `rnvm`, `tree-sitter-cli` |
| uv | Python package manager, then `uv tool install pybritive` |
| opencode | v2 via `curl -fsSL https://opencode.ai/v2/install \| bash`, into `~/.opencode/bin` |
| Symlinks | `stow --restow` into `$HOME`, after pruning dangling links |
| `this-env.sh` | Creates an empty one if missing |
| SSH | Generates an ed25519 key, writes `~/.ssh/config`, uploads to GitHub as both an auth and a signing key |
| Git identity | Prompts for name and email, writes `~/.gitconfig.local` |
| Login shell | `chsh` to Homebrew zsh |
| Node | `rnvm install --lts` if no version present |
| opencode | `bun install` for the local plugin |

### Prompts

Two: git `user.name` and `user.email`. The SSH key name is defaulted to
`$USER_$(hostname -s)`; press Enter to accept it.

Pre-seed them to run unattended:

```sh
GIT_NAME="your-name" GIT_EMAIL="you@example.com" ~/.dotfiles/install/install.sh
```

### Stow conflicts

If a real file already sits where a symlink should go, the script lists the
conflicts and stops. Either move the files aside and re-run, or let stow absorb
them into the repo:

```sh
ADOPT=1 ~/.dotfiles/install/install.sh
git -C ~/.dotfiles diff   # review what was absorbed
```

## Manual steps

- Fill in `~/zsh/this-env.sh` with machine-specific env vars and tokens. It is
  gitignored and starts empty.
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
list, so the version-control defaults are repeated in it.

## Linux

The configs branch on `uname` and work on Linux, but `install.sh` is macOS-only
and exits cleanly elsewhere. Install the `install/Brewfile` equivalents with your
package manager, then run `stow --restow --target="$HOME" .` from the repo root.
