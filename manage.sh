#!/bin/bash

# Helper script for managing the *arr stack

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo -e "${BLUE}*arr Stack Management Script${NC}"
    echo ""
    echo "Usage: ./manage.sh [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start         Start all services"
    echo "  stop          Stop all services"
    echo "  restart       Restart all services"
    echo "  status        Show service status"
    echo "  logs          Show logs for all services"
    echo "  logs [APP]    Show logs for specific app"
    echo "  update        Update all containers"
    echo "  backup        Backup configuration"
    echo "  restore       Restore configuration"
    echo "  clean         Clean up unused containers/images"
    echo "  mount-check   Check NFS mount status"
    echo "  fix-perms     Fix file permissions"
    echo "  urls          Show all service URLs"
    echo ""
    echo "Examples:"
    echo "  ./manage.sh start"
    echo "  ./manage.sh logs sonarr"
    echo "  ./manage.sh update"
}

check_mount() {
    if mount | grep -q "/mnt/media"; then
        echo -e "${GREEN}✓ NFS mount is active${NC}"
        return 0
    else
        echo -e "${RED}✗ NFS mount not found${NC}"
        echo -e "${YELLOW}Run: sudo ./setup.sh to setup NFS mount${NC}"
        return 1
    fi
}

case "$1" in
    start)
        echo -e "${BLUE}Starting *arr stack...${NC}"
        check_mount
        docker-compose up -d
        echo -e "${GREEN}✓ All services started${NC}"
        ;;
    stop)
        echo -e "${BLUE}Stopping *arr stack...${NC}"
        docker-compose down
        echo -e "${GREEN}✓ All services stopped${NC}"
        ;;
    restart)
        echo -e "${BLUE}Restarting *arr stack...${NC}"
        docker-compose restart
        echo -e "${GREEN}✓ All services restarted${NC}"
        ;;
    status)
        echo -e "${BLUE}Service Status:${NC}"
        docker-compose ps
        ;;
    logs)
        if [ -n "$2" ]; then
            docker-compose logs -f "$2"
        else
            docker-compose logs -f
        fi
        ;;
    update)
        echo -e "${BLUE}Updating containers...${NC}"
        docker-compose pull
        docker-compose up -d
        echo -e "${GREEN}✓ All containers updated${NC}"
        ;;
    backup)
        BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
        echo -e "${BLUE}Creating backup in ${BACKUP_DIR}${NC}"
        mkdir -p "$BACKUP_DIR"
        cp -r config/ "$BACKUP_DIR/"
        cp docker-compose.yml "$BACKUP_DIR/"
        cp .env "$BACKUP_DIR/"
        echo -e "${GREEN}✓ Backup created: ${BACKUP_DIR}${NC}"
        ;;
    restore)
        echo -e "${YELLOW}Available backups:${NC}"
        ls -la backups/ 2>/dev/null || echo "No backups found"
        echo "To restore: cp -r backups/[BACKUP_DATE]/config/* config/"
        ;;
    clean)
        echo -e "${BLUE}Cleaning up unused containers and images...${NC}"
        docker system prune -f
        echo -e "${GREEN}✓ Cleanup complete${NC}"
        ;;
    mount-check)
        echo -e "${BLUE}Checking NFS mount...${NC}"
        check_mount
        df -h /mnt/media 2>/dev/null || echo -e "${RED}Mount not accessible${NC}"
        ;;
    fix-perms)
        echo -e "${BLUE}Fixing permissions...${NC}"
        source .env
        sudo chown -R ${PUID}:${PGID} /mnt/media config/
        sudo chmod -R 775 /mnt/media config/
        echo -e "${GREEN}✓ Permissions fixed${NC}"
        ;;
    urls)
        echo -e "${BLUE}Service URLs:${NC}"
        echo "Prowlarr:     http://localhost:9696 (via VPN)"
        echo "Sonarr:       http://localhost:8989"
        echo "Radarr:       http://localhost:7878"
        echo "Lidarr:       http://localhost:8686"
        echo "Readarr:      http://localhost:8787"
        echo "qBittorrent:  http://localhost:8080 (via VPN)"
        echo "NZBGet:       http://localhost:6789 (via VPN)"
        echo "Bazarr:       http://localhost:6767"
        echo "Jellyseerr:   http://localhost:5055"
        echo "Notifiarr:    http://localhost:5454"
        echo "Flaresolverr: http://localhost:8191"
        ;;
    *)
        show_help
        ;;
esac
