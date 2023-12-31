#!/usr/bin/env bash

# Run on a fresh Ubuntu 22.04 server install.

set -e

# Display Constant
readonly RED_BOLD='\033[1;31m'
readonly BLUE_BOLD='\033[1;34m'
readonly YELLOW_BOLD='\033[1;33m'
readonly NC='\033[0m'

# Vars
desktop=false
personal=false
cuda=false

# User Home Directory
export HOME=/home/"$SUDO_USER"

# Script Usage
function show_usage {
    echo "Usage: $0 [-d] [-p] [-h]"
    echo "-d: Run desktop code"
    echo "-p: Run personal code"
    echo "-h: Help"
    exit 1
}

# Parse CLI
while getopts ":dph" opt; do
    case $opt in
        d)
            desktop=true
            ;;
        p)
            personal=true
            ;;
        h)
            show_usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            show_usage
            ;;
    esac
done


# Force SSH
echo -e "${BLUE_BOLD}Ensuring SSH keys are set up ...${NC}"
if [ ! -f "$HOME"/.ssh/id_ed25519 ] && [ ! -f "$HOME"/.ssh/id_rsa ]; then
    echo -e "${RED_BOLD}Please see: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent${NC}"
    exit 1
fi

# Check CUDA Compatability
echo -e "${BLUE_BOLD}Checking CUDA compatability ...${NC}"
if lspci | grep -i nvidia &> /dev/null; then
    cuda=true
fi

# Install PPAs
PPAS=(
    ansible/ansible
    git-core/ppa
)
NEED_APT_UPDATE=false
for PPA in "${PPAS[@]}"; do
    if ! grep -q "^deb .*${PPA}" /etc/apt/sources.list /etc/apt/sources.list.d/*;
    then
        echo -e "${BLUE_BOLD}Adding PPA: ${PPA}${NC}"
        sudo apt-add-repository ppa:"${PPA}" -y
        NEED_APT_UPDATE=true
    fi
done
if [ "${NEED_APT_UPDATE}" = true ]; then
    sudo apt update
fi

# Install aptitude, ansible, and git
sudo apt install -y aptitude ansible git git-lfs


# Clone playbooks
if [ ! -d "$HOME"/dev/tooling ]; then
    mkdir -p $HOME/dev/tooling
    git clone git@github.com:edurso/tooling $HOME/dev/tooling
fi


# ANSIBLE PLAYBOOKS
readonly SCRIPT_PATH="$HOME/dev/tooling"
ansible-playbook -i "localhost," -c local "${SCRIPT_PATH}"/ansible/basic.yml

if [ "$desktop" = true ]; then
    echo -e "${BLUE_BOLD}Setting Up Desktop Environment ...${NC}"
    ansible-playbook -i "localhost," -c local "${SCRIPT_PATH}"/ansible/desktop.yml
fi

if [ "${cuda}" = true ]; then
    echo -e "${BLUE_BOLD}Setting Up CUDA ...${NC}"
    ansible-playbook -i "localhost," -c local "${SCRIPT_PATH}"/ansible/cuda.yml
fi

if [ "$personal" = true ]; then
    echo -e "${BLUE_BOLD}Setting Up Personal Configurations ...${NC}"
    ansible-playbook -i "localhost," -c local "${SCRIPT_PATH}"/ansible/personal.yml
fi

# Restart system
sudo reboot
