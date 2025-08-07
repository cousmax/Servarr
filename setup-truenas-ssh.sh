#!/bin/bash

# Remote TrueNAS Directory Setup via SSH
# This script creates the directories on TrueNAS via SSH

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Remote TrueNAS Directory Setup ===${NC}"
echo ""

# Source environment variables
if [ -f .env ]; then
    source .env
else
    echo -e "${RED}Error: .env file not found${NC}"
    exit 1
fi

# TrueNAS connection details
TRUENAS_IP="10.84.2.60"
TRUENAS_BASE_PATH="/mnt/Pool1/MediaData"

echo -e "${BLUE}Connecting to TrueNAS at ${TRUENAS_IP}${NC}"
echo -e "${YELLOW}You will be prompted for SSH credentials${NC}"
echo ""

# Create the directory structure via SSH
echo -e "${BLUE}Creating directory structure on TrueNAS...${NC}"

ssh root@${TRUENAS_IP} "
    echo 'Creating TRASHguides folder structure...'
    
    # Create main directories
    mkdir -p ${TRUENAS_BASE_PATH}/media
    mkdir -p ${TRUENAS_BASE_PATH}/torrents
    
    # Create media subdirectories
    mkdir -p ${TRUENAS_BASE_PATH}/media/{movies,tv,music,books,audiobooks}
    
    # Create torrent subdirectories
    mkdir -p ${TRUENAS_BASE_PATH}/torrents/{movies,tv,music,books,audiobooks,incomplete,watch}
    
    # Set permissions
    chmod -R 775 ${TRUENAS_BASE_PATH}
    
    echo 'Directory structure created successfully!'
    echo ''
    echo 'Created directories:'
    find ${TRUENAS_BASE_PATH} -type d | sort
"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Directory structure created successfully on TrueNAS!${NC}"
    echo ""
    echo -e "${BLUE}Now you can run the setup script:${NC}"
    echo "sudo ./setup.sh"
else
    echo -e "${RED}✗ Failed to create directories on TrueNAS${NC}"
    echo -e "${YELLOW}Alternative options:${NC}"
    echo "1. Copy create-truenas-dirs.sh to your TrueNAS server and run it"
    echo "2. Manually create the directories via TrueNAS web interface"
    echo "3. Use TrueNAS shell directly"
fi
