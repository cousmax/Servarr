# Gluetun VPN Configuration Guide

## ✅ Current Working Configuration
This guide reflects the **current working AirVPN setup** that is successfully running.

## Overview
Gluetun provides VPN connectivity for download clients (qBittorrent, NZBGet, Prowlarr) to ensure all traffic is routed through your VPN provider. This setup protects your privacy and helps avoid ISP throttling.

**Current Status**: ✅ **Connected to AirVPN Sweden (IP: 62.102.148.174)**

## Working AirVPN Configuration

### Environment Variables (.env file)
```bash
# VPN Provider Settings
VPN_SERVICE_PROVIDER=airvpn
VPN_TYPE=wireguard
FIREWALL_VPN_INPUT_PORTS=11152

# AirVPN WireGuard Settings (working configuration)
WIREGUARD_PUBLIC_KEY=PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=
WIREGUARD_PRIVATE_KEY=EExmrKB2LVN1a9BphbrDBOk5H0QG0H+bcufbsKvUskQ=
WIREGUARD_PRESHARED_KEY=DAjC+pdsjnWBo0aMOAvW2frnQuri3912I2frypYZ81Y=
WIREGUARD_ADDRESSES=10.138.205.139/32
WIREGUARD_ENDPOINT_IP=198.44.159.13
WIREGUARD_ENDPOINT_PORT=1637
```

### Docker Compose Configuration
```yaml
gluetun:
  image: qmcgaw/gluetun:latest
  container_name: gluetun
  cap_add:
    - NET_ADMIN
  devices:
    - /dev/net/tun:/dev/net/tun
  environment:
    - VPN_SERVICE_PROVIDER=${VPN_SERVICE_PROVIDER}
    - VPN_TYPE=${VPN_TYPE}
    - FIREWALL_VPN_INPUT_PORTS=${FIREWALL_VPN_INPUT_PORTS}
    - WIREGUARD_PUBLIC_KEY=${WIREGUARD_PUBLIC_KEY}
    - WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}
    - WIREGUARD_PRESHARED_KEY=${WIREGUARD_PRESHARED_KEY}
    - WIREGUARD_ADDRESSES=${WIREGUARD_ADDRESSES}
    - WIREGUARD_ENDPOINT_IP=${WIREGUARD_ENDPOINT_IP}
    - WIREGUARD_ENDPOINT_PORT=${WIREGUARD_ENDPOINT_PORT}
  ports:
    - "9696:9696"  # Prowlarr
    - "8080:8080"  # qBittorrent
    - "6881:6881"  # qBittorrent listen port
    - "6881:6881/udp"
    - "6789:6789"  # NZBGet
  networks:
    - servarr

# Services Using VPN
These services route through the Gluetun VPN tunnel:

## qBittorrent (VPN Protected)
- **Web UI**: http://localhost:8080 (through VPN)
- **Purpose**: BitTorrent download client
- **Network**: Uses Gluetun container network
- **Port Forwarding**: 11152 (configured for optimal seeding)

## NZBGet (VPN Protected)  
- **Web UI**: http://localhost:6789 (through VPN)
- **Purpose**: Usenet download client
- **Network**: Uses Gluetun container network
- **Storage**: Uses local ./local-storage/usenet/ (NFS permissions workaround)

## Prowlarr (VPN Protected)
- **Web UI**: http://localhost:9696 (through VPN)
- **Purpose**: Indexer management and search
- **Network**: Uses Gluetun container network
- **Function**: Manages torrent and usenet indexers

## Configuration Notes

### IPv4-Only Configuration
**Important**: The current working setup uses IPv4-only configuration to avoid connection issues:
- Use resolved IP addresses instead of hostnames
- Disable IPv6 if experiencing connection problems
- Current working endpoint: `198.44.159.13:1637`

### Port Forwarding
AirVPN provides port forwarding which is configured as:
- **Forwarded Port**: 11152
- **Purpose**: Improves seeding ratios and connection performance
- **Configuration**: Set in both Gluetun and qBittorrent

### Network Architecture
```
Internet → AirVPN Server (Sweden) → Gluetun Container → Services
                                                      ├── qBittorrent
                                                      ├── NZBGet  
                                                      └── Prowlarr
```

## Troubleshooting

### Connection Issues
1. **Check VPN Status**:
   ```bash
   docker logs gluetun
   ```

2. **Verify IP Address**:
   ```bash
   curl -4 ifconfig.co
   ```
   Should show: `62.102.148.174` (AirVPN Sweden server)

3. **Test Port Forwarding**:
   - Check that port 11152 is accessible
   - Verify qBittorrent is configured to use this port

### Common Fixes
- **DNS Resolution Issues**: Use IP addresses instead of hostnames
- **IPv6 Problems**: Stick to IPv4-only configuration
- **Connection Drops**: Check firewall rules and endpoint availability

### Health Monitoring
Monitor Gluetun health with:
```bash
docker exec gluetun cat /tmp/gluetun/ip
```

Should return the VPN server IP, not your real IP.

## Security Benefits
- All download traffic encrypted through AirVPN
- Real IP address hidden from trackers and peers
- ISP cannot see or throttle torrent/usenet traffic
- Port forwarding improves connectivity and seeding ratios

## Alternative VPN Providers
For other VPN providers, see examples below:
### Private Internet Access (PIA)
```yaml
gluetun:
  environment:
    - VPN_SERVICE_PROVIDER=private internet access
    - VPN_TYPE=openvpn
    - OPENVPN_USER=your_pia_username
    - OPENVPN_PASSWORD=your_pia_password
    - SERVER_REGIONS=US East
```

### NordVPN
```yaml
gluetun:
  environment:
    - VPN_SERVICE_PROVIDER=nordvpn
    - VPN_TYPE=openvpn
    - OPENVPN_USER=your_nordvpn_username
    - OPENVPN_PASSWORD=your_nordvpn_password
    - SERVER_COUNTRIES=United States
```

### ExpressVPN
```yaml
gluetun:
  environment:
    - VPN_SERVICE_PROVIDER=expressvpn
    - VPN_TYPE=openvpn
    - OPENVPN_USER=your_expressvpn_username
    - OPENVPN_PASSWORD=your_expressvpn_password
    - SERVER_COUNTRIES=United States
```

### Mullvad
```yaml
gluetun:
  environment:
    - VPN_SERVICE_PROVIDER=mullvad
    - VPN_TYPE=wireguard
    - WIREGUARD_PRIVATE_KEY=your_private_key
    - SERVER_COUNTRIES=Netherlands
```

## Setup Instructions for Other Providers

1. **Get VPN Credentials**: Obtain the necessary credentials from your VPN provider
   - For WireGuard: Private key, public key, preshared key  
   - For OpenVPN: Username and password

2. **Update Environment Variables**: Add your VPN settings to the `.env` file

3. **Configure Port Forwarding** (if available):
   - Some providers like PIA support port forwarding
   - Update the `FIREWALL_VPN_INPUT_PORTS` variable with your forwarded port
   - Configure qBittorrent to use the same port

4. **Test Connection**:
   ```bash
   docker logs gluetun
   ```
   Look for successful connection messages

## Important Notes for Alternative Providers
- **Access**: Services are accessed through Gluetun's exposed ports
- **Kill Switch**: If VPN connection drops, service traffic stops automatically
- **DNS**: Gluetun provides DNS resolution for connected containers
- **Performance**: Choose servers geographically closer to you for better speeds

### Connection Issues
- Check VPN credentials are correct
- Verify your VPN subscription is active
- Try different server regions/countries
- Check Gluetun logs for error messages

### qBittorrent Not Accessible
- Ensure Gluetun is running and connected
- Check that qBittorrent is using `network_mode: "service:gluetun"`
- Verify port 8080 is exposed on Gluetun

### DNS Issues
Add DNS settings to Gluetun:
```yaml
environment:
  - DOT=off
  - DNS_KEEP_NAMESERVER=on
```

## Security Notes

1. **Never expose VPN credentials** in plain text
2. **Use environment files** for sensitive data
3. **Enable kill switch** to prevent IP leaks
4. **Regularly update** Gluetun image
5. **Monitor logs** for connection issues

## Kill Switch Configuration

Add this to Gluetun to enable kill switch:
```yaml
environment:
  - FIREWALL=on
  - FIREWALL_VPN_INPUT_PORTS=your_ports
```

For more detailed configuration options, visit the [Gluetun documentation](https://github.com/qdm12/gluetun).
