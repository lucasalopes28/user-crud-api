#!/bin/bash

# Simple Jenkins Setup for User CRUD API
# Repository: https://github.com/lucasalopes28/user-crud-api

set -e

echo "🚀 Setting up Jenkins with Docker support..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

JENKINS_URL="http://localhost:8090"

# Stop existing Jenkins
echo -e "${YELLOW}🛑 Stopping existing Jenkins...${NC}"
docker-compose down 2>/dev/null || true

# Start Jenkins
echo -e "${YELLOW}🚀 Starting Jenkins...${NC}"
docker-compose up -d

# Wait for Jenkins to start
echo -e "${YELLOW}⏳ Waiting for Jenkins to start...${NC}"
sleep 30

# Check if Jenkins is running
if ! docker ps | grep -q jenkins-server; then
    echo -e "${RED}❌ Jenkins failed to start${NC}"
    exit 1
fi

# Install essential tools and plugins
echo -e "${YELLOW}🔧 Setting up Jenkins environment...${NC}"
docker exec -u root jenkins-server bash -c "
    # Update package list
    apt-get update -qq

    # Install essential tools
    apt-get install -y -qq curl git unzip ca-certificates

    # Configure git
    git config --global user.email 'jenkins@localhost'
    git config --global user.name 'Jenkins'
    git config --global http.sslVerify false

    # Install Docker CLI
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh || {
        # Fallback for ARM64
        curl -L https://download.docker.com/linux/static/stable/aarch64/docker-24.0.7.tgz | tar -xz
        cp docker/docker /usr/local/bin/
        chmod +x /usr/local/bin/docker
        rm -rf docker
    }

    # Fix Docker socket permissions
    chmod 666 /var/run/docker.sock
    usermod -aG docker jenkins

    # Clean up
    rm -f get-docker.sh
" 2>/dev/null || echo -e "${YELLOW}⚠️  Some setup steps may have failed${NC}"

# Verify Git installation
echo -e "${YELLOW}🔍 Verifying Git installation...${NC}"
docker exec jenkins-server git --version || echo -e "${RED}⚠️  Git not properly installed${NC}"

# Install Jenkins plugins
echo -e "${YELLOW}🔌 Installing Jenkins plugins...${NC}"
docker exec jenkins-server jenkins-plugin-cli --plugins \
    git:latest \
    workflow-aggregator:latest \
    github:latest \
    docker-workflow:latest \
    pipeline-stage-view:latest \
    ws-cleanup:latest 2>/dev/null || echo -e "${YELLOW}⚠️  Plugin installation may need retry${NC}"

# Restart Jenkins to load plugins
echo -e "${YELLOW}🔄 Restarting Jenkins...${NC}"
docker restart jenkins-server
sleep 25

# Test Docker access
echo -e "${YELLOW}🧪 Testing Docker access...${NC}"
if docker exec jenkins-server docker --version >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker is working in Jenkins!${NC}"
else
    echo -e "${YELLOW}⚠️  Docker setup may need manual configuration${NC}"
fi

# Get Jenkins password
ADMIN_PASSWORD=$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "admin")

# Wait for Jenkins web interface
echo -e "${YELLOW}⏳ Waiting for Jenkins web interface...${NC}"
for i in {1..15}; do
    if curl -s ${JENKINS_URL} >/dev/null 2>&1; then
        break
    fi
    echo -n "."
    sleep 2
done
echo ""

# Final instructions
echo ""
echo -e "${GREEN}🎉 Jenkins is ready!${NC}"
echo ""
echo -e "${BLUE}📋 Access Jenkins:${NC}"
echo -e "  🌐 URL: ${JENKINS_URL}"
echo -e "  👤 Username: admin"
echo -e "  🔑 Password: ${ADMIN_PASSWORD}"
echo ""
echo -e "${BLUE}📋 Create Pipeline:${NC}"
echo -e "  1. Open ${JENKINS_URL} in your browser"
echo -e "  2. Login with credentials above"
echo -e "  3. Click 'New Item'"
echo -e "  4. Name: 'user-crud-pipeline'"
echo -e "  5. Type: 'Pipeline'"
echo -e "  6. Pipeline Definition: 'Pipeline script from SCM'"
echo -e "  7. SCM: 'Git'"
echo -e "  8. Repository URL: 'https://github.com/lucasalopes28/user-crud-api'"
echo -e "  9. Branch: '*/main'"
echo -e "  10. Script Path: 'Jenkinsfile'"
echo -e "  11. Save and Build!"
echo ""
echo -e "${BLUE}🔧 Management:${NC}"
echo -e "  Stop:    docker-compose down"
echo -e "  Start:   docker-compose up -d"
echo -e "  Logs:    docker logs jenkins-server"
echo ""
echo -e "${GREEN}🚀 Ready to build!${NC}"