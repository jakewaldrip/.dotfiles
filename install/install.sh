# Only setup for mac at the moment
if ! [ "$(uname)" == "Darwin" ]; then
  echo "Only mac install is supported via script."
  exit
fi

echo "===================="
echo "Running .dotfile installation script"

# Install and setup Stow
if ! command -v stow &> /dev/null
then
  echo "Stow not found, installing via homebrew"
  brew install stow
fi

echo "Setting up stow"
cd $HOME/.dotfiles
stow .
cd $HOME

# Create this-env.sh
if [ ! -f $HOME/zsh/this-env.sh ]
then
  echo "Creating .this-env.sh"
  touch $HOME/zsh/this-env.sh
fi

# Cargo
if ! command -v cargo &> /dev/null
then
  echo "Cargo not found, installing via curl"
  curl https://sh.rustup.rs -sSf | sh
fi

# GCC
if ! command -v gcc &> /dev/null
then
  echo "GCC not found, installing via homebrew"
  brew install gcc
fi

# Make
if ! command -v make &> /dev/null
then
  echo "Make not found, installing via homebrew"
  brew install make
fi

# Ripgrep
if ! command -v rg &> /dev/null
then
  echo "Ripgrep not found, installing via homebrew"
  brew install ripgrep
fi

# fzf
if ! command -v fzf &> /dev/null
then
  echo "fzf not found, installing via homebrew"
  brew install fzf
fi

# Zoxide
if ! command -v zoxide &> /dev/null
then
  echo "Zoxide not found, installing via cargo"
  cargo install zoxide --locked
fi

# Eza
if ! command -v eza &> /dev/null
then
  echo "Eza not found, installing via homebrew"
  brew install eza
fi

# Zsh
if ! command -v zsh &> /dev/null
then
  echo "Zsh not found, installing via homebrew"
  brew install zsh
fi

# Nvm
if ! command -v nvm &> /dev/null
then
  echo "NVM not found, installing via homebrew"
  brew install nvm
fi

# Wezterm
if ! command -v wezterm &> /dev/null
then
  echo "Wezterm not found, installing via homebrew (cask)"
  brew install --cask wezterm
fi

# p10k
if [ ! "$HOME/.p10k.zsh"]
then
  echo "p10k not found, installing via homebrew"
  brew install powerlevel10k
  echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >> ~/.zshrc
fi

echo "Installing zsh-autosuggestions"
brew install zsh-autosuggestions

echo "Installing zsh-syntax-highlighting"
brew install zsh-syntax-highlighting

# Download Neovim
if ! command -v nvim &> /dev/null
then
  echo "\n====================\n"
  echo "Neovim not found, please install from the following link"
  echo "https://github.com/neovim/neovim/blob/master/INSTALL.md"
fi

# Font download prompt
echo "Download font of choice from https://www.nerdfonts.com/font-downloads"
echo "(0xProto Nerd Font) is preferred"

echo ".dotfile installation script complete!"
echo "===================="
