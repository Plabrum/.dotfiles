#!/bin/zsh
set -o errexit

# Function to download and install Miniconda
install_miniconda() {
    miniconda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
    miniconda_installer="~/Miniconda3-latest-MacOSX-arm64.sh"
    echo "Downloading Miniconda installer..."
    curl -O "$miniconda_url"

    echo "Installing Miniconda..."
    bash miniconda_installer

    echo "Initializing Miniconda..."
    source "$HOME/miniconda/bin/activate"
    conda init zsh

    echo "Cleaning up installer..."
    rm "$miniconda_installer"
}


# Function to install packages using conda
install_conda_packages() {
    packages=$0
    echo "Installing conda packages..."
    conda install -y $packages
}
