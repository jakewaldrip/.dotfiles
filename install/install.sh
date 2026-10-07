#!/usr/bin/env bash
set -uo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
BREWFILE="$DOTFILES/install/Brewfile"

export RNVM_DIR="${RNVM_DIR:-$HOME/.rnvm}"

INSTALLED=()
SKIPPED=()
MANUAL=()

GIT_NAME="${GIT_NAME:-}"
GIT_EMAIL="${GIT_EMAIL:-}"

log_step() { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }
log_ok() { printf '    \033[32m☑\033[0m %s\n' "$1"; }
log_do() { printf '    \033[33m→\033[0m %s\n' "$1"; }
log_warn() { printf '    \033[31m!\033[0m %s\n' "$1"; }

have() { command -v "$1" >/dev/null 2>&1; }

require_macos() {
  if [ "$(uname)" != "Darwin" ]; then
    echo "Only macOS is supported by this script."
    echo "Linux: the dotfiles themselves work, but install the packages manually."
    exit 0
  fi
}

xcode_clt() {
  log_step "Xcode Command Line Tools"
  if xcode-select -p >/dev/null 2>&1; then
    log_ok "already installed"
    SKIPPED+=("xcode-clt")
    return
  fi
  log_do "installing (a GUI dialog will open)"
  xcode-select --install
  echo "    Press Enter once the Xcode CLT install has finished..."
  read -r
  INSTALLED+=("xcode-clt")
}

homebrew() {
  log_step "Homebrew"
  if have brew; then
    log_ok "already installed"
    SKIPPED+=("homebrew")
  else
    log_do "installing"
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    INSTALLED+=("homebrew")
  fi

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

brew_bundle() {
  log_step "Homebrew packages (Brewfile)"
  if [ ! -f "$BREWFILE" ]; then
    log_warn "no Brewfile at $BREWFILE, skipping"
    return
  fi
  if brew bundle check --file="$BREWFILE" >/dev/null 2>&1; then
    log_ok "all packages present"
    SKIPPED+=("brewfile")
    return
  fi
  log_do "installing missing packages"
  brew bundle --file="$BREWFILE"
  INSTALLED+=("brewfile")
}

rust() {
  log_step "Rust toolchain"
  if have rustup || [ -f "$HOME/.cargo/env" ]; then
    log_ok "already installed"
    SKIPPED+=("rustup")
  else
    log_do "installing via rustup.rs"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    INSTALLED+=("rustup")
  fi
  # shellcheck source=/dev/null
  [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
}

cargo_crates() {
  log_step "Cargo crates"
  if ! have cargo; then
    log_warn "cargo unavailable, skipping"
    return
  fi
  local crates=(eza zoxide rnvm tree-sitter-cli)
  local installed_list
  installed_list="$(cargo install --list 2>/dev/null)"
  for crate in "${crates[@]}"; do
    if grep -q "^$crate " <<<"$installed_list"; then
      log_ok "$crate"
      SKIPPED+=("$crate")
    else
      log_do "installing $crate"
      cargo install "$crate" --locked
      INSTALLED+=("$crate")
    fi
  done
}

uv_install() {
  log_step "uv"
  if have uv || [ -f "$HOME/.local/bin/env" ]; then
    log_ok "already installed"
    SKIPPED+=("uv")
    return
  fi
  log_do "installing"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  INSTALLED+=("uv")
}

uv_tools() {
  log_step "uv tools"
  if ! have uv && [ ! -x "$HOME/.local/bin/uv" ]; then
    log_warn "uv unavailable, skipping"
    MANUAL+=("run 'uv tool install pybritive'")
    return
  fi
  local uv_bin
  uv_bin="$(command -v uv || echo "$HOME/.local/bin/uv")"

  if "$uv_bin" tool list 2>/dev/null | grep -q '^pybritive'; then
    log_ok "pybritive"
    SKIPPED+=("pybritive")
    return
  fi
  log_do "installing pybritive"
  "$uv_bin" tool install pybritive
  INSTALLED+=("pybritive")
}

opencode_install() {
  log_step "opencode v2"
  if [ -x "$HOME/.opencode/bin/opencode" ]; then
    log_ok "already installed ($("$HOME/.opencode/bin/opencode" --version 2>/dev/null))"
    SKIPPED+=("opencode")
    return
  fi
  log_do "installing via opencode.ai installer"
  curl -fsSL https://opencode.ai/v2/install | bash
  INSTALLED+=("opencode")
}

prune_dead_symlinks() {
  log_step "Stale symlinks"
  local found=0
  while IFS= read -r link; do
    log_do "removing dangling $link"
    rm "$link"
    found=1
  done < <(find "$HOME" -maxdepth 1 -type l ! -exec test -e {} \; -print 2>/dev/null)
  [ "$found" -eq 0 ] && log_ok "none found"
}

stow_dotfiles() {
  log_step "Symlinks (stow)"
  if ! have stow; then
    log_warn "stow unavailable, skipping"
    return
  fi

  local conflicts
  conflicts="$(cd "$DOTFILES" && stow --no --verbose=1 --target="$HOME" . 2>&1 |
    grep -i "existing target" || true)"

  if [ -n "$conflicts" ]; then
    log_warn "conflicts found, these real files block stow:"
    sed 's/^/        /' <<<"$conflicts"
    echo "    Move or delete them, then re-run. Or run with ADOPT=1 to let stow"
    echo "    absorb them into the repo (review 'git diff' afterwards)."
    if [ "${ADOPT:-0}" = "1" ]; then
      log_do "adopting existing files"
      (cd "$DOTFILES" && stow --adopt --target="$HOME" .)
      INSTALLED+=("stow-adopt")
    else
      MANUAL+=("resolve stow conflicts, then re-run install.sh")
      return
    fi
  else
    (cd "$DOTFILES" && stow --restow --target="$HOME" .)
    log_ok "linked"
    INSTALLED+=("stow")
  fi
}

this_env() {
  log_step "zsh/this-env.sh"
  if [ -f "$HOME/zsh/this-env.sh" ]; then
    log_ok "found"
    SKIPPED+=("this-env.sh")
    return
  fi
  log_do "creating empty this-env.sh"
  touch "$HOME/zsh/this-env.sh"
  MANUAL+=("fill in ~/zsh/this-env.sh with machine-specific env vars and tokens")
  INSTALLED+=("this-env.sh")
}

SSH_KEY=""
GIT_CONFIGURED=0

git_prompt() {
  log_step "Git identity"
  local local_cfg="$HOME/.gitconfig.local"

  if [ -f "$local_cfg" ] && grep -q "email" "$local_cfg"; then
    log_ok "~/.gitconfig.local already configured"
    SKIPPED+=("git-identity")
    GIT_CONFIGURED=1
    return
  fi

  printf '    Git user.name [%s]: ' "${GIT_NAME:-}"
  read -r reply
  GIT_NAME="${reply:-${GIT_NAME:-}}"
  printf '    Git user.email [%s]: ' "${GIT_EMAIL:-}"
  read -r reply
  GIT_EMAIL="${reply:-${GIT_EMAIL:-}}"
}

ssh_setup() {
  log_step "SSH key for GitHub"

  if [ -f "$HOME/.ssh/config" ] && grep -q "Host github.com" "$HOME/.ssh/config"; then
    SSH_KEY="$(awk '/Host github.com/{f=1} f&&/IdentityFile/{print $2; exit}' "$HOME/.ssh/config")"
    SSH_KEY="${SSH_KEY/#\~/$HOME}"
    log_ok "github.com entry already in ~/.ssh/config (${SSH_KEY})"
    SKIPPED+=("ssh-key")
    return
  fi

  local default_name="${USER}_$(hostname -s)"
  printf '    Key name [%s]: ' "$default_name"
  read -r key_name
  key_name="${key_name:-$default_name}"
  SSH_KEY="$HOME/.ssh/$key_name"

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [ -f "$SSH_KEY" ]; then
    log_ok "key $SSH_KEY already exists"
  else
    log_do "generating ed25519 key"
    ssh-keygen -t ed25519 -C "${GIT_EMAIL:-$key_name}" -f "$SSH_KEY" -N ""
    INSTALLED+=("ssh-key")
  fi

  log_do "adding github.com to ~/.ssh/config"
  cat >>"$HOME/.ssh/config" <<EOF

Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/$key_name
EOF
  chmod 600 "$HOME/.ssh/config"

  ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null || true

  local title
  title="$(hostname -s)"
  if have gh && gh auth status >/dev/null 2>&1; then
    log_do "uploading key to GitHub via gh"
    gh ssh-key add "$SSH_KEY.pub" --title "$title" --type authentication || true
    gh ssh-key add "$SSH_KEY.pub" --title "$title (signing)" --type signing || true
  else
    pbcopy <"$SSH_KEY.pub"
    log_warn "gh not authenticated. Public key copied to clipboard."
    echo "    Add it at https://github.com/settings/keys as BOTH:"
    echo "      - Authentication key"
    echo "      - Signing key   (required, commit.gpgsign is on)"
    echo "    Or run 'gh auth login' later, then:"
    echo "      gh ssh-key add $SSH_KEY.pub --title '$title' --type authentication"
    echo "      gh ssh-key add $SSH_KEY.pub --title '$title (signing)' --type signing"
    echo "    Press Enter once added..."
    read -r
  fi

  log_do "verifying GitHub SSH access"
  ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | sed 's/^/        /' || true
}

git_identity() {
  local local_cfg="$HOME/.gitconfig.local"
  [ "$GIT_CONFIGURED" = "1" ] && return

  log_step "Writing git identity"
  log_do "writing $local_cfg"
  cat >"$local_cfg" <<EOF
[user]
	name = ${GIT_NAME:-}
	email = ${GIT_EMAIL:-}
EOF

  if [ -n "$SSH_KEY" ] && [ -f "$SSH_KEY.pub" ]; then
    printf '\tsigningkey = %s\n' "$SSH_KEY.pub" >>"$local_cfg"
  else
    MANUAL+=("set user.signingkey in ~/.gitconfig.local")
  fi

  INSTALLED+=("git-identity")
}

login_shell() {
  log_step "Login shell"
  local brew_zsh
  brew_zsh="$(brew --prefix 2>/dev/null)/bin/zsh"

  if [ ! -x "$brew_zsh" ]; then
    log_ok "using system zsh (homebrew zsh not installed)"
    SKIPPED+=("login-shell")
    return
  fi
  if [ "$SHELL" = "$brew_zsh" ]; then
    log_ok "already $brew_zsh"
    SKIPPED+=("login-shell")
    return
  fi

  grep -qxF "$brew_zsh" /etc/shells || {
    log_do "adding $brew_zsh to /etc/shells (needs sudo)"
    echo "$brew_zsh" | sudo tee -a /etc/shells >/dev/null
  }
  log_do "setting login shell to $brew_zsh"
  chsh -s "$brew_zsh"
  INSTALLED+=("login-shell")
}

latest_lts() {
  have jq || return 1
  curl -fsSL --max-time 10 https://nodejs.org/dist/index.json 2>/dev/null |
    jq -r 'first(.[] | select(.lts != false) | .version) | ltrimstr("v")' 2>/dev/null
}

node_runtime() {
  log_step "Node (rnvm)"
  if ! have rnvm; then
    log_warn "rnvm unavailable, skipping"
    MANUAL+=("install node with 'rnvm install <version>'")
    return
  fi
  mkdir -p "$RNVM_DIR"
  if [ -n "$(ls -A "$RNVM_DIR" 2>/dev/null | grep -E '^[0-9]+\.' || true)" ]; then
    log_ok "a node version is already installed"
    SKIPPED+=("node")
    return
  fi

  local default_version
  default_version="${NODE_VERSION:-$(latest_lts)}"

  # rnvm needs an exact semver; it rejects "lts" and bare majors.
  printf '    Node version to install, x.y.z [%s]: ' "${default_version:-skip}"
  read -r version
  version="${version:-$default_version}"

  if [ -z "$version" ]; then
    log_warn "no version given, skipping"
    MANUAL+=("install node with 'rnvm install <version>'")
    return
  fi

  log_do "installing node $version"
  if rnvm install "$version"; then
    rnvm use "$version" >/dev/null 2>&1 || true
    INSTALLED+=("node-$version")
  else
    log_warn "rnvm install $version failed"
    MANUAL+=("install node with 'rnvm install <version>'")
  fi
}

opencode_plugins() {
  log_step "opencode plugin deps"
  local plugin_dir="$HOME/.config/opencode/plugins/no-external-skills"
  if [ ! -f "$plugin_dir/package.json" ]; then
    log_ok "no plugins to build"
    return
  fi
  if [ -d "$plugin_dir/node_modules" ]; then
    log_ok "dependencies present"
    SKIPPED+=("opencode-plugins")
    return
  fi
  if ! have bun; then
    MANUAL+=("run 'bun install' in $plugin_dir")
    log_warn "bun unavailable"
    return
  fi
  log_do "bun install"
  (cd "$plugin_dir" && bun install)
  INSTALLED+=("opencode-plugins")
}

summary() {
  printf '\n\033[1;34m====================\033[0m\n'
  printf '\033[1mInstall complete\033[0m\n\n'

  if [ "${#INSTALLED[@]}" -gt 0 ]; then
    printf '  Changed:  %s\n' "${INSTALLED[*]}"
  fi
  if [ "${#SKIPPED[@]}" -gt 0 ]; then
    printf '  Already:  %s\n' "${SKIPPED[*]}"
  fi

  if [ "${#MANUAL[@]}" -gt 0 ]; then
    printf '\n\033[1;33mManual follow-up:\033[0m\n'
    for item in "${MANUAL[@]}"; do
      printf '  - %s\n' "$item"
    done
  fi

  printf '\n  Link project configs with:\n'
  printf '    ./install/link-project.sh commons ~/path/to/commons\n'
  printf '\n  Restart your terminal to pick up the new shell config.\n'
  printf '\033[1;34m====================\033[0m\n'
}

main() {
  require_macos
  printf '\033[1;34m====================\033[0m\n'
  printf '\033[1mRunning .dotfiles installation\033[0m\n'

  xcode_clt
  homebrew
  brew_bundle
  rust
  cargo_crates
  uv_install
  uv_tools
  opencode_install
  prune_dead_symlinks
  stow_dotfiles
  this_env
  git_prompt
  ssh_setup
  git_identity
  login_shell
  node_runtime
  opencode_plugins
  summary
}

main "$@"
