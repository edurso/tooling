#!/usr/bin/env bash

set -e

# Display Constant
readonly RED_BOLD='\033[1;31m'
readonly BLUE_BOLD='\033[1;34m'
readonly YELLOW_BOLD='\033[1;33m'
readonly NC='\033[0m'

# Force SSH
echo -e "${BLUE_BOLD}Ensuring SSH keys are set up ...${NC}"
if [ ! -f ~/.ssh/id_ed25519 ] && [ ! -f ~/.ssh/id_rsa ]; then
    echo -e "${RED_BOLD}Please see: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent${NC}"
    exit 1
fi

# Check CUDA Compatability
echo -e "${BLUE_BOLD}Checking CUDA compatability ...${NC}"
if lspci | grep -i nvidia &> /dev/null; then
    echo -e "${BLUE_BOLD}CUDA Compatable GPU Found${NC}"
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

readonly SCRIPT_PATH="$HOME/dev/tooling"
ansible-playbook -i "localhost," -c local "${SCRIPT_PATH}"/ansible/tmp.yml
