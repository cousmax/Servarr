#!/bin/bash

# Simple NFS Setup Script (without directory creation)
# Use this if you've already created directories on TrueNAS

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Source environment variables
if [ -f .env ]; then
    source .env
else
    echo -e "${RED}Error: .env file not found${NC}"
    exit 1
fi

echo -e "${BLUE}=== Simple NFS Mount Setup ===${NC}"
echo -e "${BLUE}This script assumes directories already exist on TrueNAS${NC}"
echo ""

# Check if running as root for mounting
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (sudo ./simple-setup.sh)${NC}"
    exit 1
fi

# Install NFS utilities only
echo -e "${BLUE}Installing NFS utilities...${NC}"
if command -v apt-get &> /dev/null; then
    apt-get update
    apt-get install -y nfs-common
elif command -v yum &> /dev/null; then
    yum install -y nfs-utils
elif command -v pacman &> /dev/null; then
    pacman -S --noconfirm nfs-utils
fi

# Create mount point
echo -e "${BLUE}Creating mount point: ${NFS_MOUNT_POINT}${NC}"
mkdir -p ${NFS_MOUNT_POINT}

# Test NFS connection
echo -e "${BLUE}Testing NFS connection to ${NFS_SERVER}:${NFS_SHARE}${NC}"
if showmount -e ${NFS_SERVER} | grep -q ${NFS_SHARE}; then
    echo -e "${GREEN}✓ NFS share is accessible${NC}"
else
    echo -e "${RED}✗ NFS share not accessible. Please check your TrueNAS configuration.${NC}"
    exit 1
fi

# Mount NFS share
echo -e "${BLUE}Mounting NFS share...${NC}"
if mount -t nfs -o rw,sync,hard,intr ${NFS_SERVER}:${NFS_SHARE} ${NFS_MOUNT_POINT}; then
    echo -e "${GREEN}✓ NFS share mounted successfully${NC}"
else
    echo -e "${RED}✗ Failed to mount NFS share${NC}"
    exit 1
fi

# Add to fstab for persistent mounting
echo -e "${BLUE}Adding NFS mount to /etc/fstab for persistence...${NC}"
FSTAB_ENTRY="${NFS_SERVER}:${NFS_SHARE} ${NFS_MOUNT_POINT} nfs defaults,_netdev 0 0"
if ! grep -q "${NFS_SERVER}:${NFS_SHARE}" /etc/fstab; then
    echo "${FSTAB_ENTRY}" >> /etc/fstab
    echo -e "${GREEN}✓ Added NFS mount to fstab${NC}"
else
    echo -e "${YELLOW}NFS mount already exists in fstab${NC}"
fi

# Check if directories exist
echo -e "${BLUE}Checking directory structure...${NC}"
if [ -d "${NFS_MOUNT_POINT}/media" ] && [ -d "${NFS_MOUNT_POINT}/torrents" ]; then
    echo -e "${GREEN}✓ Required directories found${NC}"
    
    # List the structure
    echo -e "${BLUE}Current directory structure:${NC}"
    find ${NFS_MOUNT_POINT} -type d 2>/dev/null | head -20 | sort
    
else
    echo -e "${YELLOW}Warning: Expected directories not found${NC}"
    echo -e "${YELLOW}Please ensure these directories exist on your TrueNAS:${NC}"
    echo "  /mnt/Pool1/MediaData/media"
    echo "  /mnt/Pool1/MediaData/torrents"
fi

# Create local config directories
echo -e "${BLUE}Creating local configuration directories...${NC}"
mkdir -p config/{prowlarr,sonarr,radarr,lidarr,readarr,qbittorrent,bazarr,jellyseerr,notifiarr,gluetun}
chown -R ${PUID}:${PGID} config/
chmod -R 775 config/

echo -e "${GREEN}✓ Configuration directories created${NC}"

echo ""
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Configure Gluetun VPN settings in docker-compose.yml"
echo "2. Run: ./manage.sh start"
echo "3. Configure your applications"
echo ""
echo -e "${YELLOW}If directories are missing on the NFS mount, use one of these methods:${NC}"
echo "  - ./setup-truenas-ssh.sh (via SSH)"
echo "  - Copy create-truenas-dirs.sh to TrueNAS and run it"
echo "  - Create manually via TrueNAS web interface"
