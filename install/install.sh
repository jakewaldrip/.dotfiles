# Only setup for mac at the moment
if ! [ "$(uname)" == "Darwin" ]; then
  echo "Only mac install is supported via script."
  exit
fi

echo "===================="
echo "Running .dotfile installation script"

# Git
if ! command -v git &> /dev/null
then
  echo "Git not found, installing via homebrew"
  brew install git
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
if ! command -v git &> /dev/null
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

# Zsh
if ! command -v nvm &> /dev/null
then
  echo "NVM not found, installing via homebrew"
  brew install nvm
fi

# Oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
echo "\n====================\n"
echo "Oh-my-zsh not found, please run the following command to complete setup"
echo "sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
fi

# Download Neovim
if ! command -v nvim &> /dev/null
then
  echo "\n====================\n"
  echo "Neovim not found, please install from the following link"
  echo "https://github.com/neovim/neovim/blob/master/INSTALL.md"
fi

echo ".dotfile installation script complete!"
echo "===================="
