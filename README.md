<h3 align="center"> <pre>  <br>   $ dotfiles   <br>  </pre> </h3>

![ndo-mbp-njt](./.dotfiles/macos_dotfiles.png)

<p>
  <img alt="MacOS" src="https://img.shields.io/badge/MacOS-white?style=for-the-badge&logo=apple&logoColor=black">
  <img alt="Ghostty" src="https://img.shields.io/badge/Ghostty-white?style=for-the-badge&logo=ghostty&logoColor=black">
  <img alt="zsh" src="https://img.shields.io/badge/zsh-white?style=for-the-badge&logo=zsh&logoColor=black">
  <img alt="neovim" src="https://img.shields.io/badge/neovim-white?style=for-the-badge&logo=neovim&logoColor=black">
</p>

> [!NOTE]
> `Mar 17, 2024` - My Linux boxes are on NixOS and can be found at [ndom91/nixos-config](https://github.com/ndom91/nixos-config)


## 🚀 Setup

Initial bare repo dotfiles setup

```bash
git init --bare $HOME/.dotfiles
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dot config status.showUntrackedFiles no
echo "alias dot='git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME'" >> ~/.zshrc
```

Restore on a new machine:

```bash
git clone --bare git@github.com:ndom91/dotfiles.git $HOME/.dotfiles
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dot checkout
dot config status.showUntrackedFiles no
```

## 📝 License

MIT
