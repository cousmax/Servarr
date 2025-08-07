<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# *arr Stack Project Instructions

This is a media automation stack project using Docker Compose with the following applications:
- Prowlarr (Indexer management)
- Sonarr (TV shows)
- Radarr (Movies)
- Lidarr (Music)
- Readarr (Books/Audiobooks)
- qBittorrent (Download client via VPN)
- Gluetun (VPN client)
- Bazarr (Subtitles)
- Jellyseerr (Request management for Jellyfin)
- Notifiarr (Notification system)
- Flaresolverr (Cloudflare bypass)

## Key Guidelines:
- Follow TRASHguides recommendations for folder structure and configurations
- Use NFS mount from TrueNAS server (10.84.2.60:/mnt/Pool1/MediaData)
- Maintain proper file permissions (PUID=1000, PGID=1000)
- Use LinuxServer.io Docker images for consistency
- Follow hardlink-friendly folder structure for efficient storage

## File Structure:
- `/mnt/media/` - Final media storage
- `/mnt/media/torrents/` - Download staging area
- `./config/` - Application configurations
- Docker paths use `/data` mapping to `/mnt/media`

## Important Notes:
- Always preserve the TRASHguides folder structure
- Ensure proper remote path mappings between download client and *arr apps
- Use atomic moves for completed downloads (same filesystem)
- Configure categories in qBittorrent for proper organization
