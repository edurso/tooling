# Tooling Configuration for Ubuntu Machines

## Installation

On a clean installation of Ubuntu server, proceed as follows.

1. Set up [GitHub SSH keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
2. Download [`install.sh`](https://raw.githubusercontent.com/edurso/dotfiles/master/install.sh)
3. Run `chmod +x install.sh`
4. Run `sudo ./install.sh` (takes the flags `-d` for desktop, and `-p` for personal configurations)

## Things to install

By default:
    build tools
    network tools
    zsh
    docker
    python
    conda
If desktop:
    ubuntu-desktop, gnome-desktop, x11, wayland, vscode, etc.
If cuda:
    nvidia drivers, cuda drivers/toolkits, etc.
If personal tooling wanted:
    dropbox
    the gnome plugins
If advanced desktop wanted:
    scrcpy
    slack
    discord
    obsidian
