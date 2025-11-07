#!/bin/bash

# Simple Jenkins Setup Script
# Sets up Jenkins with Docker support for GitHub repository: https://github.com/lucasalopes28/user-crud-api

set -e

echo "🚀 Setting up Jenkins for User CRUD API..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
GITHUB_REPO="https://github.com/lucasalopes28/user-crud-api"
JENKINS_URL="http://localhost:8090"

echo -e "${BLUE}📋 Configuration:${NC}"
echo -e "  Repository: ${GITHUB_REPO}"
echo -e "  Jenkins URL: ${JENKINS_URL}"
echo ""

# Stop existing Jenkins
echo -e "${YELLOW}🛑 Stopping existing Jenkins...${NC}"
docker-compose down 2>/dev/null || true

# Start Jenkins
echo -e "${YELLOW}🚀 Starting Jenkins...${NC}"
docker-compose up -d jenkins

# Wait for Jenkins
echo -e "${YELLOW}⏳ Waiting for Jenkins to start (30 seconds)...${NC}"
sleep 30

# Check if running
if ! docker ps | grep -q jenkins-server; then
    echo -e "${RED}❌ Jenkins failed to start${NC}"
    exit 1
fi

# Install Docker CLI
echo -e "${YELLOW}🐳 Installing Docker CLI in Jenkins...${NC}"
docker exec -u root jenkins-server bash -c "
    apt-get update -qq > /dev/null 2>&1 &&
    apt-get install -y -qq curl > /dev/null 2>&1 &&
    curl -fsSL https://get.docker.com -o get-docker.sh &&
    sh get-docker.sh > /dev/null 2>&1 &&
    chmod 666 /var/run/docker.sock &&
    usermod -aG docker jenkins
" 2>/dev/null || {
    echo -e "${YELLOW}⚠️  Using alternative Docker installation...${NC}"
    docker exec -u root jenkins-server bash -c "
        apt-get update -qq > /dev/null 2>&1 &&
        apt-get install -y -qq curl > /dev/null 2>&1 &&
        curl -L https://download.docker.com/linux/static/stable/aarch64/docker-24.0.7.tgz | tar -xz > /dev/null 2>&1 &&
        cp docker/docker /usr/local/bin/ &&
        chmod +x /usr/local/bin/docker &&
        rm -rf docker &&
        chmod 666 /var/run/docker.sock
    " 2>/dev/null || echo -e "${YELLOW}⚠️  Docker installation may need manual setup${NC}"
}

# Test Docker
echo -e "${YELLOW}🧪 Testing Docker access...${NC}"
if docker exec jenkins-server docker --version >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker is working!${NC}"
else
    echo -e "${YELLOW}⚠️  Docker may need manual configuration${NC}"
fi

# Get admin password
ADMIN_PASSWORD=$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "admin")

# Wait for Jenkins web interface
echo -e "${YELLOW}⏳ Waiting for Jenkins web interface...${NC}"
for i in {1..20}; do
    if curl -s ${JENKINS_URL} >/dev/null 2>&1; then
        break
    fi
    echo -n "."
    sleep 3
done
echo ""

# Final status
echo ""
echo -e "${GREEN}🎉 Jenkins is ready!${NC}"
echo ""
echo -e "${BLUE}📋 Access Information:${NC}"
echo -e "  🌐 URL: ${JENKINS_URL}"
echo -e "  👤 Username: admin"
echo -e "  🔑 Password: ${ADMIN_PASSWORD}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo -e "  1. Open ${JENKINS_URL} in your browser"
echo -e "  2. Login with the credentials above"
echo -e "  3. Click 'New Item'"
echo -e "  4. Create a Pipeline job named 'user-crud-api-pipeline'"
echo -e "  5. Configure Pipeline:"
echo -e "     - Definition: Pipeline script from SCM"
echo -e "     - SCM: Git"
echo -e "     - Repository URL: ${GITHUB_REPO}"
echo -e "     - Branch: */main"
echo -e "     - Script Path: Jenkinsfile.simple"
echo -e "  6. Save and click 'Build Now'"
echo ""
echo -e "${BLUE}🔧 Management Commands:${NC}"
echo -e "  Stop:    docker-compose down"
echo -e "  Start:   docker-compose up -d"
echo -e "  Logs:    docker logs jenkins-server"
echo -e "  Restart: docker restart jenkins-server"
echo ""
echo -e "${GREEN}🚀 Ready to build your Spring Boot application!${NC}"