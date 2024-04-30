## Installation
1. `git clone https://github.com/jakesboy2/.dotfiles.git`
2. `./.dotfiles/install/install.sh` (Currently Mac only)
3. Follow instructions on screen

### Temporary Extra Installation (Until Install Scripts Completed)
1. `brew install stow`
2. `cd .dotfiles`
3. `stow .`

## Todo
* [ ] Add Stow to installation
  * [ ] Add the running of stow to symlink files into $HOME
* [ ] Separate install scripts per environment
  * [ ] Create install script for Ubuntu
  * [ ] Create install script for WSL2
* [ ] Add `this-env.sh` automatic creation to installation to prevent error when sourcing
