#!/bin/bash

# *arr Stack Setup Script
# This script sets up the NFS mount and TRASHguides folder structure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Source environment variables
if [ -f .env ]; then
    source .env
else
    echo -e "${RED}Error: .env file not found${NC}"
    exit 1
fi

echo -e "${BLUE}=== *arr Stack Setup Script ===${NC}"
echo -e "${BLUE}Using TRASHguides folder structure${NC}"
echo ""

# Check if running as root for mounting
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}Warning: Running as root. This is required for NFS mounting.${NC}"
else
    echo -e "${YELLOW}Note: You may need to run this script with sudo for NFS mounting.${NC}"
fi

# Install required packages
echo -e "${BLUE}Installing required packages...${NC}"
if command -v apt-get &> /dev/null; then
    apt-get update
    
    # Install NFS utilities
    apt-get install -y nfs-common
    
    # Check if Docker is already installed
    if ! command -v docker &> /dev/null; then
        echo -e "${BLUE}Installing Docker...${NC}"
        
        # Remove conflicting packages
        apt-get remove -y docker docker-engine docker.io containerd runc containerd.io 2>/dev/null || true
        
        # Install Docker using the official method
        apt-get install -y ca-certificates curl gnupg lsb-release
        
        # Add Docker's official GPG key
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        
        # Set up the repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Update and install Docker
        apt-get update
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        # Enable and start Docker
        systemctl enable docker
        systemctl start docker
        
        # Add current user to docker group
        usermod -aG docker $SUDO_USER 2>/dev/null || true
        
        echo -e "${GREEN}✓ Docker installed successfully${NC}"
    else
        echo -e "${GREEN}✓ Docker already installed${NC}"
    fi
    
    # Install docker-compose if not available
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e "${BLUE}Installing docker-compose...${NC}"
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        echo -e "${GREEN}✓ docker-compose installed${NC}"
    else
        echo -e "${GREEN}✓ docker-compose already available${NC}"
    fi
    
elif command -v yum &> /dev/null; then
    yum install -y nfs-utils
    if ! command -v docker &> /dev/null; then
        yum install -y docker docker-compose
        systemctl enable docker
        systemctl start docker
    fi
elif command -v pacman &> /dev/null; then
    pacman -S --noconfirm nfs-utils
    if ! command -v docker &> /dev/null; then
        pacman -S --noconfirm docker docker-compose
        systemctl enable docker
        systemctl start docker
    fi
else
    echo -e "${YELLOW}Please install nfs-common/nfs-utils and docker manually${NC}"
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
    echo -e "${YELLOW}Make sure the NFS share is configured and accessible from this host.${NC}"
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

# Check if we can write to the NFS mount
echo -e "${BLUE}Testing NFS write permissions...${NC}"
if touch ${NFS_MOUNT_POINT}/test_write 2>/dev/null; then
    rm -f ${NFS_MOUNT_POINT}/test_write
    echo -e "${GREEN}✓ NFS mount is writable${NC}"
else
    echo -e "${YELLOW}Warning: NFS mount may have permission restrictions${NC}"
    echo -e "${YELLOW}This is normal for some NFS configurations${NC}"
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

# Create TRASHguides folder structure
echo -e "${BLUE}Creating TRASHguides folder structure...${NC}"

# Check if folders already exist on NFS
if [ -d "${NFS_MOUNT_POINT}/media" ] && [ -d "${NFS_MOUNT_POINT}/torrents" ]; then
    echo -e "${GREEN}✓ TRASHguides folders already exist on NFS${NC}"
else
    echo -e "${BLUE}Creating folders on NFS share...${NC}"
    
    # Try to create directories with proper permissions
    if mkdir -p ${NFS_MOUNT_POINT}/{media,torrents,usenet} 2>/dev/null; then
        echo -e "${GREEN}✓ Main directories created${NC}"
    else
        echo -e "${YELLOW}Warning: Could not create main directories directly${NC}"
        echo -e "${YELLOW}You may need to create these on your TrueNAS server:${NC}"
        echo -e "${YELLOW}  - ${NFS_SHARE}/media${NC}"
        echo -e "${YELLOW}  - ${NFS_SHARE}/torrents${NC}"
        echo -e "${YELLOW}  - ${NFS_SHARE}/usenet${NC}"
        echo ""
        echo -e "${BLUE}Checking if directories exist...${NC}"
        
        # Check if directories exist but we just can't create them
        if [ -d "${NFS_MOUNT_POINT}/media" ] && [ -d "${NFS_MOUNT_POINT}/torrents" ]; then
            echo -e "${GREEN}✓ Required directories already exist${NC}"
        else
            echo -e "${RED}✗ Required directories don't exist${NC}"
            echo -e "${YELLOW}Please create these directories on your TrueNAS server first:${NC}"
            echo "  mkdir -p /mnt/Pool1/MediaData/media"
            echo "  mkdir -p /mnt/Pool1/MediaData/torrents"
            echo "  mkdir -p /mnt/Pool1/MediaData/usenet"
            echo ""
            read -p "Press Enter after creating the directories on TrueNAS, or Ctrl+C to exit..."
        fi
    fi
fi

# Create subdirectories if main directories exist
if [ -d "${NFS_MOUNT_POINT}/media" ] && [ -d "${NFS_MOUNT_POINT}/torrents" ]; then
    echo -e "${BLUE}Creating subdirectories...${NC}"
    
    # Media directories (following TRASHguides structure)
    mkdir -p ${NFS_MOUNT_POINT}/media/{movies,tv,music,books,audiobooks} 2>/dev/null || echo -e "${YELLOW}Some media subdirectories may already exist${NC}"
    
    # Torrent directories with categories
    mkdir -p ${NFS_MOUNT_POINT}/torrents/{movies,tv,music,books,audiobooks} 2>/dev/null || echo -e "${YELLOW}Some torrent subdirectories may already exist${NC}"
    
    # Additional useful directories
    mkdir -p ${NFS_MOUNT_POINT}/torrents/{incomplete,watch} 2>/dev/null || echo -e "${YELLOW}Some utility directories may already exist${NC}"
    
    # Usenet directories
    mkdir -p ${NFS_MOUNT_POINT}/usenet/{complete,incomplete,intermediate} 2>/dev/null || echo -e "${YELLOW}Some usenet directories may already exist${NC}"
    mkdir -p ${NFS_MOUNT_POINT}/usenet/complete/{movies,tv,music,books,audiobooks} 2>/dev/null || echo -e "${YELLOW}Some usenet category directories may already exist${NC}"
    
    echo -e "${GREEN}✓ TRASHguides folder structure processed${NC}"
else
    echo -e "${RED}✗ Cannot proceed without main directories${NC}"
    exit 1
fi

# Set proper permissions
echo -e "${BLUE}Setting permissions...${NC}"
if chown -R ${PUID}:${PGID} ${NFS_MOUNT_POINT} 2>/dev/null; then
    echo -e "${GREEN}✓ Ownership set successfully${NC}"
else
    echo -e "${YELLOW}Warning: Could not change ownership (this may be normal for NFS)${NC}"
fi

if chmod -R 775 ${NFS_MOUNT_POINT} 2>/dev/null; then
    echo -e "${GREEN}✓ Permissions set successfully${NC}"
else
    echo -e "${YELLOW}Warning: Could not change permissions (this may be normal for NFS)${NC}"
fi

# Create local config directories
echo -e "${BLUE}Creating local configuration directories...${NC}"
mkdir -p config/{prowlarr,sonarr,radarr,lidarr,readarr,qbittorrent,nzbget,bazarr,jellyseerr,notifiarr,gluetun}
chown -R ${PUID}:${PGID} config/
chmod -R 775 config/

echo -e "${GREEN}✓ Configuration directories created${NC}"

# Display folder structure
echo -e "${BLUE}=== Folder Structure Created ===${NC}"
echo -e "${YELLOW}NFS Mount Point: ${NFS_MOUNT_POINT}${NC}"
echo ""
echo "📁 ${NFS_MOUNT_POINT}/"
echo "├── 📁 media/"
echo "│   ├── 📁 movies/          # Radarr - Movies"
echo "│   ├── 📁 tv/              # Sonarr - TV Shows"
echo "│   ├── 📁 music/           # Lidarr - Music"
echo "│   ├── 📁 books/           # Readarr - eBooks"
echo "│   └── 📁 audiobooks/      # Readarr - Audiobooks"
echo "├── 📁 torrents/"
echo "│   ├── 📁 movies/          # Movie downloads"
echo "│   ├── 📁 tv/              # TV downloads"
echo "│   ├── 📁 music/           # Music downloads"
echo "│   ├── 📁 books/           # Book downloads"
echo "│   ├── 📁 audiobooks/      # Audiobook downloads"
echo "│   ├── 📁 incomplete/      # Incomplete downloads"
echo "│   └── 📁 watch/           # Watch folder"
echo "└── 📁 usenet/"
echo "    ├── 📁 complete/        # Completed usenet downloads"
echo "    │   ├── 📁 movies/"
echo "    │   ├── 📁 tv/"
echo "    │   ├── 📁 music/"
echo "    │   ├── 📁 books/"
echo "    │   └── 📁 audiobooks/"
echo "    ├── 📁 incomplete/      # Active usenet downloads"
echo "    └── 📁 intermediate/    # NZBGet intermediate directory"
echo ""

echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Configure Gluetun VPN settings in docker-compose.yml"
echo "2. Run: docker-compose up -d"
echo "3. Configure your applications:"
echo "   - Prowlarr: http://localhost:9696"
echo "   - Sonarr: http://localhost:8989"
echo "   - Radarr: http://localhost:7878"
echo "   - Lidarr: http://localhost:8686"
echo "   - Readarr: http://localhost:8787"
echo "   - qBittorrent: http://localhost:8080 (via VPN)"
echo "   - NZBGet: http://localhost:6789"
echo "   - Bazarr: http://localhost:6767"
echo "   - Jellyseerr: http://localhost:5055"
echo "   - Notifiarr: http://localhost:5454"
echo ""
echo -e "${YELLOW}Remember to configure the download paths in each *arr application${NC}"
echo -e "${YELLOW}according to the TRASHguides recommendations!${NC}"
echo ""
echo -e "${RED}IMPORTANT: Configure your VPN settings in docker-compose.yml before starting!${NC}"
