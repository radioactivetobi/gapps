#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting pre-deployment checks...${NC}\n"

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

# Create necessary directories
echo -e "Creating required directories..."
mkdir -p traefik
mkdir -p host_data

# Create and set permissions for acme.json
echo -e "Setting up Traefik SSL certificate storage..."
touch traefik/acme.json
chmod 600 traefik/acme.json

# Check if traefik.yml exists
if [ ! -f traefik/traefik.yml ]; then
    echo -e "${RED}traefik.yml not found. Please ensure it exists in the traefik directory.${NC}"
    exit 1
fi

# Check if email is configured in traefik.yml
if grep -q "your.actual@digissllc.com" traefik/traefik.yml; then
    echo -e "${RED}Please update the email address in traefik/traefik.yml${NC}"
    exit 1
fi

# Check if ports 80 and 443 are available
if netstat -tuln | grep -q ":80 "; then
    echo -e "${RED}Port 80 is already in use. Please free up this port.${NC}"
    exit 1
fi

if netstat -tuln | grep -q ":443 "; then
    echo -e "${RED}Port 443 is already in use. Please free up this port.${NC}"
    exit 1
fi

# Check if domain is configured
echo -e "\n${YELLOW}Checking DNS configuration for grc.digissllc.com...${NC}"
if host grc.digissllc.com > /dev/null; then
    echo -e "${GREEN}Domain DNS record found!${NC}"
else
    echo -e "${RED}Warning: Could not verify DNS record for grc.digissllc.com${NC}"
    echo -e "Please ensure your domain is pointing to this server's IP address."
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo -e "\nCreating .env file..."
    cat > .env << EOF
POSTGRES_USER=db1
POSTGRES_PASSWORD=$(openssl rand -base64 16)
POSTGRES_DB=db1
POSTGRES_HOST=postgres
DEFAULT_EMAIL=admin@example.com
DEFAULT_PASSWORD=admin
RESET_DB=no
VERSION=3.5.3
WORKER_CONCURRENCY=1
EOF
    echo -e "${GREEN}.env file created with secure random PostgreSQL password${NC}"
fi

# Final checks
echo -e "\n${YELLOW}Pre-deployment checklist:${NC}"
echo -e "✓ Docker installed"
echo -e "✓ Docker Compose installed"
echo -e "✓ Directories created"
echo -e "✓ SSL certificate storage configured"
echo -e "✓ Environment file created"

echo -e "\n${YELLOW}Before deploying, please ensure:${NC}"
echo -e "1. You have updated the email in traefik/traefik.yml"
echo -e "2. Your domain (grc.digissllc.com) is pointing to this server"
echo -e "3. Ports 80 and 443 are open in your firewall"
echo -e "4. You have reviewed the passwords in .env file"

echo -e "\n${GREEN}Setup complete! You can now run:${NC}"
echo -e "docker-compose up -d" 