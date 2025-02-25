#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Setting up Git changes...${NC}"

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Not a git repository. Please initialize git first.${NC}"
    exit 1
fi

# Check if develop branch exists
if ! git show-ref --verify --quiet refs/heads/develop; then
    echo -e "${YELLOW}Creating develop branch...${NC}"
    git checkout -b develop
else
    echo -e "${YELLOW}Switching to develop branch...${NC}"
    git checkout develop
fi

# Add new files
echo -e "${YELLOW}Adding new files...${NC}"
git add docker-compose.yml
git add traefik/traefik.yml
git add setup.sh
git add .gitignore 2>/dev/null || true

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    echo -e "${YELLOW}Creating .gitignore file...${NC}"
    cat > .gitignore << EOF
.env
host_data/
traefik/acme.json
EOF
fi

# Commit changes
echo -e "${YELLOW}Committing changes...${NC}"
git commit -m "Add SSL configuration with Traefik and data persistence

- Add Traefik reverse proxy configuration
- Configure Let's Encrypt SSL
- Add data persistence for PostgreSQL
- Add setup script for deployment
- Update docker-compose.yml with Traefik integration"

# Push to develop
echo -e "${YELLOW}Pushing to develop branch...${NC}"
git push origin develop

echo -e "${GREEN}Changes have been committed and pushed to develop branch!${NC}" 