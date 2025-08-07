# NZBGet Configuration Guide

## Overview
NZBGet is a lightweight and efficient Usenet downloader that integrates seamlessly with your *arr stack. It provides an alternative to torrenting through Usenet newsgroups.

## Initial Setup

### 1. First Access
- **URL**: http://localhost:6789 (through VPN)
- **Default Login**: 
  - Username: `nzbget`
  - Password: `tegbzn6789`
- **Change these credentials immediately!**

### 2. Basic Configuration

#### Main Settings
1. Go to **Settings > News-Servers**
2. Add your Usenet provider's server details:
   - **Level**: 0 (main server)
   - **Host**: Your provider's hostname
   - **Port**: Usually 563 (SSL) or 119 (non-SSL)
   - **Username**: Your Usenet username
   - **Password**: Your Usenet password
   - **SSL**: Enable if supported
   - **Connections**: Number of connections (check with your provider)

#### Download Directories
1. Go to **Settings > Paths**
2. Configure these paths:
   - **MainDir**: `/downloads` (already mapped)
   - **DestDir**: `/downloads/complete`
   - **InterDir**: `/intermediate-dir`
   - **TempDir**: `/downloads/incomplete`

#### Categories (for *arr integration)
1. Go to **Settings > Categories**
2. Add these categories:
   - **movies**: DestDir = `complete/movies`
   - **tv**: DestDir = `complete/tv`
   - **music**: DestDir = `complete/music`
   - **books**: DestDir = `complete/books`
   - **audiobooks**: DestDir = `complete/audiobooks`

### 3. Performance Settings

#### Download Settings
- **ArticleCache**: 200MB (adjust based on RAM)
- **WriteBuffer**: 1024KB
- **CrcCheck**: Yes
- **DirectWrite**: Yes (for better performance)

#### Connection Settings
- **MaxDownloadRate**: 0 (unlimited, or set your limit)
- **UrlConnections**: 4
- **LogBufferSize**: 1000

## Integration with *arr Applications

### Adding NZBGet to Sonarr/Radarr/Lidarr/Readarr

1. **Go to Settings > Download Clients**
2. **Add Download Client > NZBGet**
3. **Configure**:
   - **Name**: NZBGet
   - **Enable**: ✓
   - **Host**: `nzbget` (container name)
   - **Port**: `6789`
   - **Username**: Your NZBGet username
   - **Password**: Your NZBGet password
   - **Category**: Use appropriate category (movies, tv, music, books)
   - **Use SSL**: Only if you configured SSL
   - **Add Paused**: No (unless you want manual control)

### Remote Path Mappings

In each *arr application:
1. **Go to Settings > Download Clients**
2. **Add Remote Path Mapping**:
   - **Host**: `nzbget`
   - **Remote Path**: `/downloads/complete/[category]`
   - **Local Path**: `/data/media/usenet/complete/[category]`

Example mappings:
- Remote: `/downloads/complete/movies` → Local: `/data/media/usenet/complete/movies`
- Remote: `/downloads/complete/tv` → Local: `/data/media/usenet/complete/tv`

## Folder Structure

```
/mnt/media/usenet/         # NFS mounted storage from TrueNAS (10.84.2.60)
├── complete/              # Completed downloads (moved by *arr apps)
│   ├── movies/           # Radarr picks up movies here
│   ├── tv/               # Sonarr picks up TV shows here
│   ├── music/            # Lidarr picks up music here
│   ├── books/            # Readarr picks up books here
│   └── audiobooks/       # Readarr picks up audiobooks here
├── incomplete/           # Active downloads
└── intermediate/         # NZBGet working directory
```

**Note**: NZBGet now uses NFS-mounted storage from TrueNAS for better integration and shared access across the stack.

## Popular Usenet Providers

### Unlimited Plans
- **Newshosting**: High retention, fast speeds
- **UsenetServer**: Good value, reliable
- **Eweka**: European provider, excellent retention

### Block Accounts (backup)
- **Blocknews**: Good for filling gaps
- **UsenetExpress**: Reliable block provider

## Indexers for Prowlarr

Popular Usenet indexers to add to Prowlarr:
- **NZBGeek**: General purpose
- **DrunkenSlug**: Movies and TV
- **NZBPlanet**: Good retention
- **6box**: Fast indexing
- **NZBFinder**: Free tier available

## Security and Privacy

### SSL/TLS
- Enable SSL for news server connections
- Use SSL for NZBGet web interface in production

### VPN
NZBGet runs without VPN by default (unlike qBittorrent). Usenet traffic is typically:
- **Encrypted** by the news server
- **Not peer-to-peer** (direct server connection)
- **More private** than torrenting

If you want NZBGet through VPN, modify docker-compose.yml:
```yaml
nzbget:
  network_mode: "service:gluetun"
  # Remove the ports section since they'll be exposed via gluetun
```

## Troubleshooting

### Common Issues

#### Downloads Fail
- Check news server credentials
- Verify server settings (host, port, SSL)
- Check article retention (file may be too old)

#### Slow Downloads
- Increase connections (don't exceed provider limit)
- Check ArticleCache size
- Verify network speed

#### *arr Apps Can't See Downloads
- Check remote path mappings
- Verify category configuration
- Ensure proper permissions

### Useful NZBGet Settings

#### Health Check
- **HealthCheck**: `DiskSpace,DownloadRate`
- **DiskSpace**: Warning at 1000MB free

#### Cleanup
- **DeleteCleanupDisk**: 5000 (delete after 5GB cleanup)
- **ParCleanupQueue**: Yes
- **NzbCleanupDisk**: Yes

## Advanced Configuration

### Scripts
NZBGet supports post-processing scripts. Popular ones:
- **nzbToMedia**: Advanced post-processing
- **VideoSort**: Automatic video file organization
- **Flatten**: Remove unnecessary folder structures

### API
NZBGet provides a full API for automation:
- **API Endpoint**: `http://localhost:6789/jsonrpc`
- **Authentication**: Basic auth with username/password

### Monitoring
Monitor NZBGet performance:
- Check **Messages** tab for errors
- Monitor **History** for failed downloads
- Use **Statistics** for performance metrics

For more detailed configuration, visit the [NZBGet Documentation](https://nzbget.net/documentation).
