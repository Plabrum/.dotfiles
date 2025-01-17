#!/bin/zsh
set -o errexit
# Function to download and install Miniconda
install_miniconda() {
    # Check if Conda is already installed
    if command -v conda &> /dev/null; then
        echo "Conda is already installed. Skipping Miniconda installation."
        return 0
    fi
    miniconda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
    miniconda_installer="$HOME/Miniconda3-latest-MacOSX-arm64.sh"
    
    echo "Downloading Miniconda installer..."
    curl -o "$miniconda_installer" "$miniconda_url"

    echo "Installing Miniconda..."
    bash "$miniconda_installer"

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
