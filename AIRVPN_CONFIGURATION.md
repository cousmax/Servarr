# AirVPN Configuration Guide

## ✅ Current Working Configuration
This guide reflects the **current working AirVPN setup** that is successfully running with Gluetun.

**Current Status**: ✅ **Connected to AirVPN Sweden Server (IP: 62.102.148.174)**

## Prerequisites
1. **AirVPN Account**: Active subscription required
2. **WireGuard Configuration**: Generated from AirVPN client area
3. **IPv4-Only Setup**: Required for reliable connections (IPv6 causes issues)

## ✅ Working Configuration Values

### Environment Variables (.env)
```bash
# VPN Provider Settings  
VPN_SERVICE_PROVIDER=airvpn
VPN_TYPE=wireguard
FIREWALL_VPN_INPUT_PORTS=11152

# AirVPN WireGuard Configuration (WORKING VALUES)
WIREGUARD_PUBLIC_KEY=PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=
WIREGUARD_PRIVATE_KEY=EExmrKB2LVN1a9BphbrDBOk5H0QG0H+bcufbsKvUskQ=
WIREGUARD_PRESHARED_KEY=DAjC+pdsjnWBo0aMOAvW2frnQuri3912I2frypYZ81Y=
WIREGUARD_ADDRESSES=10.138.205.139/32
WIREGUARD_ENDPOINT_IP=198.44.159.13
WIREGUARD_ENDPOINT_PORT=1637
```

### Key Configuration Notes
- ✅ **IPv4-Only**: Uses resolved IP address (198.44.159.13) instead of hostname
- ✅ **Port Forwarding**: 11152 configured and working
- ✅ **Endpoint Resolution**: Hostname resolves to working IP
- ✅ **Network**: Successfully routes qBittorrent, NZBGet, and Prowlarr traffic

## Step-by-Step Setup Process

### Step 1: Generate AirVPN WireGuard Configuration

1. **Access AirVPN Client Area**: Login to https://airvpn.org/client/
2. **Navigate to Config Generator**: 
   - Go to "Client Area" → "Config Generator"
   - Select "WireGuard" as the protocol
3. **Choose Server**: 
   - Select your preferred country/server
   - Current working setup uses Sweden server
4. **Generate Configuration**: 
   - Click "Generate Config"
   - Download the .conf file
5. **Extract Configuration Values**: 
   - Open the downloaded .conf file
   - Copy the keys and addresses to your .env file

### Step 2: Configure Environment Variables
Update your `.env` file with the extracted values:

```bash
# Copy these values from your AirVPN WireGuard config
WIREGUARD_PRIVATE_KEY=your_private_key_from_config
WIREGUARD_PUBLIC_KEY=your_server_public_key_from_config  
WIREGUARD_PRESHARED_KEY=your_preshared_key_from_config
WIREGUARD_ADDRESSES=your_vpn_ip_address/32
```

### Step 3: Handle Endpoint Configuration
**Important**: Use IP address instead of hostname for reliability:

1. **Find Endpoint Hostname**: Look for the endpoint in your AirVPN config
2. **Resolve to IP**: Use `nslookup` or `dig` to get the IP address
3. **Set in .env file**:
   ```bash
   # Use resolved IP instead of hostname
   WIREGUARD_ENDPOINT_IP=resolved_ip_address
   WIREGUARD_ENDPOINT_PORT=port_number
   ```

### Step 4: Configure Port Forwarding (Optional but Recommended)

1. **Access Port Forwarding**: In AirVPN client area
   - Go to "Client Area" → "Port Forwarding"  
2. **Request Forwarded Port**: 
   - Click "Request New Port"
   - Note the assigned port number
3. **Update Configuration**:
   ```bash
   FIREWALL_VPN_INPUT_PORTS=your_forwarded_port
   ```
4. **Configure qBittorrent**: Set the same port in qBittorrent settings
## Troubleshooting Common Issues

### Connection Problems

#### IPv6 Issues
**Problem**: Connection fails or is unstable
**Solution**: Use IPv4-only configuration
```bash
# Ensure your WIREGUARD_ADDRESSES uses IPv4 only
WIREGUARD_ADDRESSES=10.x.x.x/32  # NOT IPv6
```

#### DNS Resolution Issues  
**Problem**: Cannot resolve AirVPN server hostnames
**Solution**: Use resolved IP addresses
```bash
# Instead of: sweden.aivpn.org
# Use: 198.44.159.13
WIREGUARD_ENDPOINT_IP=198.44.159.13
```

#### Firewall Blocking
**Problem**: Connection established but no internet access
**Solution**: Check firewall configuration
```bash
# Verify port forwarding is set
FIREWALL_VPN_INPUT_PORTS=your_port

# Check Gluetun logs
docker logs gluetun
```

### Performance Issues

#### Slow Speeds
1. **Try Different Servers**: Change to servers closer to your location
2. **Check Server Load**: Some servers may be overloaded
3. **Verify Port Forwarding**: Improves seeding performance

#### Connection Drops
1. **Monitor Logs**: `docker logs gluetun -f`
2. **Check Server Status**: Verify server is operational on AirVPN status page
3. **Network Stability**: Test with different endpoints

### Configuration Verification

#### Check VPN Connection
```bash
# View current IP (should show VPN server IP)
docker exec gluetun wget -qO- ifconfig.co

# Check Gluetun status
docker logs gluetun | grep -i "You are running"
```

#### Verify Port Forwarding
```bash
# Check if port is open (from external network)
nmap -p your_forwarded_port your_vpn_ip

# Test from qBittorrent
# Go to Options → Connection → check "Test Port"
```

## Advanced Configuration

### Multiple Server Locations
You can configure multiple endpoints for failover:

```bash
# Primary endpoint
WIREGUARD_ENDPOINT_IP=198.44.159.13
WIREGUARD_ENDPOINT_PORT=1637

# If connection fails, try different server
# Update IP/port and restart Gluetun
```

### Custom DNS Settings
AirVPN provides DNS servers for enhanced privacy:

```yaml
gluetun:
  environment:
    - DOT=off  # Disable DNS over TLS if having issues
    - DNS_ADDRESS=10.4.0.1  # AirVPN DNS server
```

## Security Best Practices

### Kill Switch Verification
Test that traffic stops when VPN disconnects:

1. **Stop Gluetun**: `docker stop gluetun`
2. **Check qBittorrent**: Should lose internet connectivity
3. **Restart Gluetun**: `docker start gluetun`
4. **Verify Reconnection**: Traffic should resume

### DNS Leak Testing
Ensure DNS requests go through VPN:

```bash
# Should show AirVPN DNS servers
docker exec gluetun nslookup google.com
```

### Regular IP Verification
Create monitoring script to verify VPN connection:

```bash
#!/bin/bash
# Check if using VPN IP
CURRENT_IP=$(docker exec gluetun wget -qO- ifconfig.co)
if [[ "$CURRENT_IP" == "62.102.148.174" ]]; then
    echo "✅ VPN Connected: $CURRENT_IP"
else  
    echo "❌ VPN Problem: $CURRENT_IP"
fi
```

## AirVPN-Specific Features

### Eddie Client Integration
While using Gluetun, you can still use AirVPN's Eddie client for:
- Server monitoring
- Port forwarding management  
- Connection testing
- Real-time statistics

### Port Forwarding Management
- **Maximum Ports**: Up to 20 forwarded ports per account
- **Port Types**: Both TCP and UDP supported
- **Management**: Via client area or Eddie client
- **Duration**: Ports persist until manually removed

### Server Selection Tips
- **Latency**: Choose servers with lowest ping
- **Load**: Avoid overloaded servers (>80% CPU)
- **Features**: Some servers have special features (streaming optimized, etc.)
- **Locations**: Consider legal jurisdiction for your use case

## Configuration Summary

The working AirVPN configuration provides:
- ✅ **Privacy**: All torrent/usenet traffic encrypted
- ✅ **Performance**: Port forwarding for optimal seeding
- ✅ **Reliability**: IPv4-only setup prevents connection issues  
- ✅ **Security**: Kill switch prevents traffic leaks
- ✅ **Monitoring**: Easy verification of VPN status

For issues not covered in this guide, consult:
- AirVPN Support: https://airvpn.org/support/
- Gluetun Documentation: https://github.com/qdm12/gluetun
- Container Logs: `docker logs gluetun`
