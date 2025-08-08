#!/bin/bash

# VPN Status Checker Script
# Checks Gluetun VPN connection status, IP address, and location

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis
CHECK="✅"
CROSS="❌"
SHIELD="🛡️"
GLOBE="🌐"
LOCATION="📍"

echo -e "${CYAN}===========================================${NC}"
echo -e "${CYAN}          VPN CONNECTION CHECKER${NC}"
echo -e "${CYAN}===========================================${NC}"
echo ""

# Function to check if Gluetun container is running
check_gluetun_running() {
    if docker ps --filter "name=gluetun" --filter "status=running" --quiet | grep -q .; then
        echo -e "${GREEN}${CHECK} Gluetun Container: Running${NC}"
        return 0
    else
        echo -e "${RED}${CROSS} Gluetun Container: Not running${NC}"
        return 1
    fi
}

# Function to get VPN status from logs
check_vpn_connection() {
    local healthy_check=$(docker logs gluetun 2>/dev/null | grep -i "healthy" | tail -1)
    local connection_check=$(docker logs gluetun 2>/dev/null | grep -i "You are running" | tail -1)
    
    if [[ -n "$healthy_check" && -n "$connection_check" ]]; then
        echo -e "${GREEN}${CHECK} VPN Status: Connected and Healthy${NC}"
        return 0
    else
        echo -e "${RED}${CROSS} VPN Status: Not connected or unhealthy${NC}"
        return 1
    fi
}

# Function to get current IP and location
get_ip_info() {
    echo -e "${BLUE}${GLOBE} Getting IP information...${NC}"
    
    # Try to get IP through Gluetun container
    local external_ip
    local location_info
    
    # Get external IP
    if external_ip=$(timeout 10 docker exec gluetun wget -qO- ifconfig.co 2>/dev/null); then
        echo -e "${GREEN}${CHECK} External IP: ${external_ip}${NC}"
    else
        echo -e "${RED}${CROSS} Could not retrieve external IP${NC}"
        return 1
    fi
    
    # Get location information
    echo -e "${BLUE}${LOCATION} Getting location information...${NC}"
    if location_info=$(timeout 10 docker exec gluetun wget -qO- ipinfo.io 2>/dev/null); then
        # Parse JSON response
        local city=$(echo "$location_info" | grep '"city"' | cut -d'"' -f4)
        local region=$(echo "$location_info" | grep '"region"' | cut -d'"' -f4)
        local country=$(echo "$location_info" | grep '"country"' | cut -d'"' -f4)
        local org=$(echo "$location_info" | grep '"org"' | cut -d'"' -f4)
        local timezone=$(echo "$location_info" | grep '"timezone"' | cut -d'"' -f4)
        
        echo -e "${GREEN}${CHECK} Location Details:${NC}"
        echo -e "    ${CYAN}City:${NC} $city"
        echo -e "    ${CYAN}Region:${NC} $region"
        echo -e "    ${CYAN}Country:${NC} $country"
        echo -e "    ${CYAN}ISP/Provider:${NC} $org"
        echo -e "    ${CYAN}Timezone:${NC} $timezone"
    else
        echo -e "${YELLOW}⚠️  Could not retrieve detailed location info${NC}"
    fi
}

# Function to check VPN endpoint from logs
check_vpn_endpoint() {
    echo -e "${BLUE}${SHIELD} Checking VPN endpoint...${NC}"
    
    local endpoint=$(docker logs gluetun 2>/dev/null | grep -i "Connecting to" | tail -1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}:[0-9]\{1,5\}')
    
    if [[ -n "$endpoint" ]]; then
        echo -e "${GREEN}${CHECK} VPN Endpoint: ${endpoint}${NC}"
    else
        echo -e "${YELLOW}⚠️  VPN endpoint not found in logs${NC}"
    fi
}

# Function to check port forwarding
check_port_forwarding() {
    echo -e "${BLUE}🔧 Checking port forwarding...${NC}"
    
    local forwarded_port=$(docker logs gluetun 2>/dev/null | grep -i "setting allowed input port" | tail -1 | grep -o '[0-9]\{4,5\}')
    
    if [[ -n "$forwarded_port" ]]; then
        echo -e "${GREEN}${CHECK} Forwarded Port: ${forwarded_port}${NC}"
    else
        echo -e "${YELLOW}⚠️  No forwarded port configured${NC}"
    fi
}

# Function to test connectivity
test_connectivity() {
    echo -e "${BLUE}🔗 Testing connectivity through VPN...${NC}"
    
    if timeout 5 docker exec gluetun wget -qO- --spider https://www.google.com 2>/dev/null; then
        echo -e "${GREEN}${CHECK} Internet connectivity: Working${NC}"
    else
        echo -e "${RED}${CROSS} Internet connectivity: Failed${NC}"
    fi
}

# Function to show summary
show_summary() {
    echo ""
    echo -e "${CYAN}===========================================${NC}"
    echo -e "${CYAN}              SUMMARY${NC}"
    echo -e "${CYAN}===========================================${NC}"
    
    # Quick status check
    if check_gluetun_running >/dev/null 2>&1 && check_vpn_connection >/dev/null 2>&1; then
        echo -e "${GREEN}${SHIELD} VPN Status: PROTECTED${NC}"
        echo -e "${GREEN}Your download clients are secured through AirVPN${NC}"
    else
        echo -e "${RED}${CROSS} VPN Status: NOT PROTECTED${NC}"
        echo -e "${RED}Your download clients may be exposed!${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}💡 Quick Commands:${NC}"
    echo -e "   ${CYAN}View Gluetun logs:${NC} docker logs gluetun"
    echo -e "   ${CYAN}Restart Gluetun:${NC} docker compose restart gluetun"
    echo -e "   ${CYAN}Check services:${NC} ./manage.sh status"
}

# Main execution
main() {
    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}${CROSS} Docker is not installed or not in PATH${NC}"
        exit 1
    fi
    
    # Check if Gluetun container exists
    if ! docker ps -a --filter "name=gluetun" --quiet | grep -q .; then
        echo -e "${RED}${CROSS} Gluetun container not found${NC}"
        echo -e "${YELLOW}Make sure you've started the stack with: ./manage.sh start${NC}"
        exit 1
    fi
    
    # Run checks
    if check_gluetun_running; then
        check_vpn_connection
        get_ip_info
        check_vpn_endpoint
        check_port_forwarding
        test_connectivity
    else
        echo -e "${YELLOW}⚠️  Cannot perform VPN checks - Gluetun container is not running${NC}"
        echo -e "${YELLOW}Start the stack with: ./manage.sh start${NC}"
    fi
    
    show_summary
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "VPN Status Checker"
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo "  --ip          Show only IP address"
        echo "  --status      Show only connection status"
        echo "  --location    Show only location info"
        echo ""
        exit 0
        ;;
    --ip)
        if check_gluetun_running >/dev/null 2>&1; then
            docker exec gluetun wget -qO- ifconfig.co 2>/dev/null || echo "Could not retrieve IP"
        else
            echo "Gluetun container not running"
        fi
        exit 0
        ;;
    --status)
        if check_gluetun_running >/dev/null 2>&1 && check_vpn_connection >/dev/null 2>&1; then
            echo "CONNECTED"
        else
            echo "DISCONNECTED"
        fi
        exit 0
        ;;
    --location)
        if check_gluetun_running >/dev/null 2>&1; then
            get_ip_info
        else
            echo "Gluetun container not running"
        fi
        exit 0
        ;;
    *)
        main
        ;;
esac
