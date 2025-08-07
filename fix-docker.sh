#!/bin/bash

# Docker Installation Fix Script
# This script resolves the containerd.io conflict issue

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Docker Installation Fix ===${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (sudo ./fix-docker.sh)${NC}"
    exit 1
fi

# Remove conflicting packages
echo -e "${BLUE}Removing conflicting Docker packages...${NC}"
apt-get remove -y docker docker-engine docker.io containerd runc containerd.io 2>/dev/null || true
apt-get autoremove -y

# Clean up any leftover files
echo -e "${BLUE}Cleaning up...${NC}"
rm -rf /var/lib/docker 2>/dev/null || true
rm -rf /etc/docker 2>/dev/null || true

# Install prerequisites
echo -e "${BLUE}Installing prerequisites...${NC}"
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
echo -e "${BLUE}Adding Docker GPG key...${NC}"
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    DISTRO="ubuntu"
fi

# Set up the repository
echo -e "${BLUE}Setting up Docker repository...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DISTRO} \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
apt-get update

# Install Docker Engine
echo -e "${BLUE}Installing Docker Engine...${NC}"
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
echo -e "${BLUE}Starting Docker service...${NC}"
systemctl enable docker
systemctl start docker

# Add user to docker group
if [ -n "$SUDO_USER" ]; then
    echo -e "${BLUE}Adding $SUDO_USER to docker group...${NC}"
    usermod -aG docker $SUDO_USER
fi

# Install docker-compose (standalone) if needed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${BLUE}Installing docker-compose...${NC}"
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Test Docker installation
echo -e "${BLUE}Testing Docker installation...${NC}"
if docker --version && docker-compose --version; then
    echo -e "${GREEN}✓ Docker installed successfully!${NC}"
else
    echo -e "${RED}✗ Docker installation failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo -e "${YELLOW}Note: You may need to log out and back in for docker group changes to take effect${NC}"
echo -e "${YELLOW}Or run: newgrp docker${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Run: sudo ./setup.sh"
echo "2. Or continue with: ./manage.sh start"
