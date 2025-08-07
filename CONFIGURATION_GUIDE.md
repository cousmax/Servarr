# Complete Servarr Stack Configuration Guide

## ✅ Current Working Configuration
This guide reflects the **current working setup** that is successfully running with all services operational.

**Stack Status**: ✅ **All 12 services running with VPN protection for download clients**

## Quick Access URLs

### VPN-Protected Services (Download Clients)
These services route through AirVPN for privacy:
- **qBittorrent**: http://localhost:8080 (VPN Protected 🛡️)
- **NZBGet**: http://localhost:6789 (VPN Protected 🛡️)  
- **Prowlarr**: http://localhost:9696 (VPN Protected 🛡️)

### Direct Access Services (Management)
These services access the internet directly:
- **Radarr**: http://localhost:7878
- **Sonarr**: http://localhost:8989
- **Readarr**: http://localhost:8787
- **Lidarr**: http://localhost:8686
- **Bazarr**: http://localhost:6767
- **Overseerr**: http://localhost:5055
- **Tautulli**: http://localhost:8181
- **Flaresolverr**: http://localhost:8191

### System Monitoring
- **Gluetun VPN**: Check logs with `docker logs gluetun`
- **VPN IP Check**: Current server IP is `62.102.148.174` (Sweden)

## Architecture Overview

### Network Design
```
Internet 
├── Direct Access: Radarr, Sonarr, Readarr, Lidarr, Bazarr, Overseerr, Tautulli, Flaresolverr
└── VPN Tunnel (AirVPN) → Gluetun Container
    ├── qBittorrent (Port: 8080)
    ├── NZBGet (Port: 6789)
    └── Prowlarr (Port: 9696)
```

### Storage Configuration
- **Media Storage**: NFS mount from TrueNAS (10.84.2.60:/mnt/Pool1/MediaData) → `/mnt/media`
- **Download Storage**: 
  - **Torrents**: NFS mount → `/mnt/media/torrents/`
  - **Usenet**: NFS mount → `/mnt/media/usenet/` (successfully integrated)
- **Configuration**: Local directories → `./config/[service-name]/`

### TRASHguides Folder Structure
```
/mnt/media/
├── media/
│   ├── movies/
│   ├── tv/
│   ├── books/
│   └── music/
└── torrents/
    ├── movies/
    ├── tv/
    ├── books/
    └── music/
```

## Service Configuration Details

## 🔧 Application Configuration

### 1. Prowlarr (Indexer Manager)
- **URL**: http://localhost:9696 (via VPN)
- **Purpose**: Centralized indexer management
- **Setup**:
  1. Add your indexers (trackers)
  2. Configure Flaresolverr if needed: http://flaresolverr:8191
  3. Sync apps (Sonarr, Radarr, Lidarr, Readarr)
- **Note**: Routes through VPN for privacy when accessing indexers

### 2. qBittorrent (Download Client)
- **URL**: http://localhost:8080 (via VPN)
- **Default Login**: admin/adminadmin (change immediately!)
- **Configuration**:
  - **Downloads**: `/data/torrents/incomplete`
  - **Completed**: Move to category folders
  - **Categories**:
    - `movies` → `/data/torrents/movies`
    - `tv` → `/data/torrents/tv`
    - `music` → `/data/torrents/music`
    - `books` → `/data/torrents/books`
    - `audiobooks` → `/data/torrents/audiobooks`

### 2b. NZBGet (Usenet Client)
- **URL**: http://localhost:6789 (via VPN)
- **Default Login**: nzbget/tegbzn6789 (change immediately!)
- **Configuration**:
  - **Downloads**: `/downloads/incomplete`
  - **Completed**: Move to category folders
  - **Categories**:
    - `movies` → `/downloads/complete/movies`
    - `tv` → `/downloads/complete/tv`
    - `music` → `/downloads/complete/music`
    - `books` → `/downloads/complete/books`
    - `audiobooks` → `/downloads/complete/audiobooks`
- **Note**: Routes through VPN for enhanced privacy

### 3. Sonarr (TV Shows)
- **URL**: http://localhost:8989
- **Paths**:
  - **Root Folder**: `/data/media/tv`
  - **Download Clients**: 
    - qBittorrent (host: `gluetun`, port: 8080)
    - NZBGet (host: `gluetun`, port: 6789)
  - **Categories**: `tv` (both clients)
  - **Remote Paths**: 
    - qBittorrent: `/data/torrents/tv` → `/data/torrents/tv`
    - NZBGet: `/downloads/complete/tv` → `/data/usenet/complete/tv`

### 4. Radarr (Movies)
- **URL**: http://localhost:7878
- **Paths**:
  - **Root Folder**: `/data/media/movies`
  - **Download Clients**:
    - qBittorrent (host: `gluetun`, port: 8080)
    - NZBGet (host: `gluetun`, port: 6789)
  - **Categories**: `movies` (both clients)
  - **Remote Paths**:
    - qBittorrent: `/data/torrents/movies` → `/data/torrents/movies`
    - NZBGet: `/downloads/complete/movies` → `/data/usenet/complete/movies`

### 5. Lidarr (Music)
- **URL**: http://localhost:8686
- **Paths**:
  - **Root Folder**: `/data/media/music`
  - **Download Clients**:
    - qBittorrent (host: `gluetun`, port: 8080)
    - NZBGet (host: `gluetun`, port: 6789)
  - **Categories**: `music` (both clients)
  - **Remote Paths**:
    - qBittorrent: `/data/torrents/music` → `/data/torrents/music`
    - NZBGet: `/downloads/complete/music` → `/data/usenet/complete/music`

### 6. Readarr (Books)
- **URL**: http://localhost:8787
- **Paths**:
  - **Root Folders**: 
    - `/data/media/books` (eBooks)
    - `/data/media/audiobooks` (Audiobooks)
  - **Download Clients**:
    - qBittorrent (host: `gluetun`, port: 8080)
    - NZBGet (host: `gluetun`, port: 6789)
  - **Categories**: `books`, `audiobooks` (both clients)

### 7. Bazarr (Subtitles)
- **URL**: http://localhost:6767
- **Setup**:
  1. Connect to Sonarr and Radarr
  2. Configure subtitle providers
  3. Set up language preferences

### 8. Overseerr (Request Management)
- **URL**: http://localhost:5055
- **Setup**:
  1. Connect to Plex/Jellyfin
  2. Connect to Sonarr and Radarr
  3. Set up user permissions

## 🎯 TRASHguides Quality Profiles

### Sonarr Quality Profiles
- **HD-1080p**: For 1080p content
- **UHD-4K**: For 4K content
- Import custom formats from TRASHguides

### Radarr Quality Profiles
- **HD-1080p**: For 1080p movies
- **UHD-4K**: For 4K movies
- Import custom formats from TRASHguides

## 🔄 Naming Conventions

### TV Shows (Sonarr)
```
Series Folder: {Series Title} ({Series Year})
Season Folder: Season {season:00}
Episode File: {Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Full}
```

### Movies (Radarr)
```
Movie Folder: {Movie Title} ({Release Year})
Movie File: {Movie Title} ({Release Year}) {Quality Full}
```

## 🚀 Quick Start Commands

```bash
# Setup NFS and folder structure
sudo ./setup.sh

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Update all containers
docker-compose pull && docker-compose up -d
```

## 🔧 Troubleshooting

### NFS Mount Issues
```bash
# Check NFS exports on TrueNAS
showmount -e 10.84.2.60

# Test NFS mount manually
sudo mount -t nfs 10.84.2.60:/mnt/Pool1/MediaData /mnt/media

# Check mount status
mount | grep nfs
```

### Permission Issues
```bash
# Fix ownership
sudo chown -R 1000:1000 /mnt/media
sudo chown -R 1000:1000 ./config

# Fix permissions
sudo chmod -R 775 /mnt/media
sudo chmod -R 775 ./config
```

### Container Issues
```bash
# Restart specific service
docker-compose restart sonarr

# Check container logs
docker-compose logs sonarr

# Access container shell
docker-compose exec sonarr bash
```

## 📚 Additional Resources

- [TRASHguides](https://trash-guides.info/)
- [Sonarr Wiki](https://wiki.servarr.com/sonarr)
- [Radarr Wiki](https://wiki.servarr.com/radarr)
- [LinuxServer.io Documentation](https://docs.linuxserver.io/)

## 🔐 Security Notes

1. Change default passwords immediately
2. Consider using a reverse proxy (Traefik/nginx)
3. Set up proper firewall rules
4. Use strong authentication for exposed services
5. Regularly update containers
