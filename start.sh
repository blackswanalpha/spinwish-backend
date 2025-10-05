#!/bin/bash

# Simple Start Script for SpinWish Backend
# Usage: ./start.sh [profile]
# Profiles: auto (default), prod, local, dev

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROFILE=${1:-auto}

echo -e "${BLUE}🚀 Starting SpinWish Backend${NC}"
echo ""

case $PROFILE in
    "auto")
        echo -e "${YELLOW}Using smart database detection...${NC}"
        ./smart_start.sh
        ;;
    "prod")
        echo -e "${YELLOW}Using production profile (remote PostgreSQL with fallback)${NC}"
        cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=prod
        ;;
    "local")
        echo -e "${YELLOW}Using local profile (local PostgreSQL with fallback)${NC}"
        cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=local
        ;;
    "dev")
        echo -e "${YELLOW}Using development profile (H2 in-memory)${NC}"
        cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
        ;;
    *)
        echo "Usage: ./start.sh [profile]"
        echo "Profiles:"
        echo "  auto  - Smart database detection (default)"
        echo "  prod  - Remote PostgreSQL with local fallback"
        echo "  local - Local PostgreSQL with H2 fallback"
        echo "  dev   - H2 in-memory database"
        exit 1
        ;;
esac
