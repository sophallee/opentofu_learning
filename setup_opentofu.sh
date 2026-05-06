#!/bin/bash

# OpenTofu and Azure CLI Installation Script for RPM-based systems
# Supports RHEL, CentOS Stream, AlmaLinux, and Rocky Linux (Versions 8, 9, 10)

set -e  # Exit immediately if any command fails

# Color codes for better output
readonly red='\033[0;31m'
readonly green='\033[0;32m'
readonly yellow='\033[1;33m'
readonly nc='\033[0m' # No Color

echo -e "${green}Starting OpenTofu and Azure CLI installation process...${nc}"

# Function to check if running as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${red}Error: This script must be run as root. Please use sudo.${nc}"
        exit 1
    fi
}

# Function to detect OS and version
detect_os() {
    if [ -f /etc/redhat-release ]; then
        if grep -qi "centos stream" /etc/redhat-release; then
            os="CentOS Stream"
            version=$(grep -oE '[0-9]+' /etc/redhat-release | head -1)
        elif grep -qi "red hat" /etc/redhat-release; then
            os="RHEL"
            version=$(grep -oE '[0-9]+' /etc/redhat-release | head -1)
        elif grep -qi "almalinux" /etc/redhat-release; then
            os="AlmaLinux"
            version=$(grep -oE '[0-9]+' /etc/redhat-release | head -1)
        elif grep -qi "rocky" /etc/redhat-release; then
            os="Rocky Linux"
            version=$(grep -oE '[0-9]+' /etc/redhat-release | head -1)
        fi
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        os=$NAME
        version=$VERSION_ID
    fi

    if [ -z "$os" ] || [ -z "$version" ]; then
        echo -e "${red}Error: Unable to detect OS or version.${nc}"
        exit 1
    fi

    echo -e "${yellow}Detected OS: $os $version${nc}"
}

# Install OpenTofu
install_opentofu() {
    echo -e "${green}Installing OpenTofu...${nc}"
    if ! sudo dnf install -y opentofu; then
        echo -e "${red}Error: Failed to install OpenTofu${nc}"
        exit 1
    fi
    echo -e "${green}OpenTofu installed successfully.${nc}"
}

# Import Microsoft repository key
import_microsoft_key() {
    echo -e "${green}Importing Microsoft repository key...${nc}"
    if [ "$version" -ge 10 ] 2>/dev/null; then
        echo -e "${yellow}Version 10 detected, importing Microsoft 2025 key...${nc}"
        if ! sudo rpm --import https://packages.microsoft.com/keys/microsoft-2025.asc; then
            echo -e "${red}Error: Failed to import Microsoft 2025 key${nc}"
            exit 1
        fi
    fi
    
    if ! sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc; then
        echo -e "${red}Error: Failed to import Microsoft key${nc}"
        exit 1
    fi
    echo -e "${green}Microsoft key(s) imported successfully.${nc}"
}

# Add Microsoft repository based on OS version
add_microsoft_repo() {
    echo -e "${green}Configuring Microsoft repository...${nc}"
    
    case "$os" in
        "RHEL"|"CentOS Stream"|"AlmaLinux"|"Rocky Linux")
            case "$version" in
                10|"10.0")
                    # For version 10, RHEL repository is often the most complete
                    # AlmaLinux and Rocky can safely use the RHEL 10 repo
                    repo_url="https://packages.microsoft.com/config/rhel/10/packages-microsoft-prod.rpm"
                    ;;
                9|"9.0"|"9.1")
                    repo_url="https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm"
                    ;;
                8|"8.0"|"8.1"|"8.2"|"8.3"|"8.4"|"8.5"|"8.6"|"8.7"|"8.8"|"8.9")
                    repo_url="https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm"
                    ;;
                *)
                    echo -e "${red}Error: Unsupported version $version for $os${nc}"
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo -e "${red}Error: Unsupported OS: $os${nc}"
            exit 1
            ;;
    esac

    echo -e "${yellow}Using repository URL: $repo_url${nc}"
    if ! sudo dnf install -y "$repo_url"; then
        echo -e "${red}Error: Failed to add Microsoft repository${nc}"
        exit 1
    fi
    
    echo -e "${green}Refreshing package cache...${nc}"
    sudo dnf makecache
    
    echo -e "${green}Microsoft repository configured successfully.${nc}"
}

# Install Azure CLI
install_azure_cli() {
    echo -e "${green}Installing Azure CLI...${nc}"
    if ! sudo dnf install -y azure-cli; then
        echo -e "${red}Error: Failed to install Azure CLI. The package 'azure-cli' was not found in the configured repositories.${nc}"
        exit 1
    fi
    echo -e "${green}Azure CLI installed successfully.${nc}"

    # Verify installation
    if az --version &>/dev/null; then
        echo -e "${green}Azure CLI verification successful.${nc}"
    else
        echo -e "${yellow}Warning: Azure CLI installation completed but verification failed.${nc}"
    fi
}

# Main execution
check_root
detect_os
install_opentofu
import_microsoft_key
add_microsoft_repo
install_azure_cli

echo -e "${green}Installation completed successfully!${nc}"
echo -e "${green}OpenTofu and Azure CLI are now ready to use.${nc}"