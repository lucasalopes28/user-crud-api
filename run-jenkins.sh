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

# Note: Plugins will be installed through the setup wizard
echo -e "${YELLOW}📦 Plugins will be installed via setup wizard${NC}"
echo -e "${YELLOW}   Select 'Install suggested plugins' when prompted${NC}"

# Test Docker access
echo -e "${YELLOW}🧪 Testing Docker access...${NC}"
if docker exec jenkins-server docker --version >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker is working in Jenkins!${NC}"
else
    echo -e "${YELLOW}⚠️  Docker setup may need manual configuration${NC}"
fi

# Wait for Jenkins to fully initialize
echo -e "${YELLOW}⏳ Waiting for Jenkins to fully initialize...${NC}"
echo -e "${YELLOW}   This may take up to 2 minutes...${NC}"

# Wait for Jenkins web interface
for i in {1..30}; do
    if curl -s ${JENKINS_URL} >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Jenkins web interface is up${NC}"
        break
    fi
    echo -n "."
    sleep 3
done
echo ""

# Wait a bit more for Jenkins to fully start
sleep 10

# Wait for initial admin password file to be created
echo -e "${YELLOW}🔑 Retrieving initial admin password...${NC}"
ADMIN_PASSWORD=""
for i in {1..40}; do
    # Check if password file exists
    if docker exec jenkins-server test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
        ADMIN_PASSWORD=$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "")
        if [ ! -z "$ADMIN_PASSWORD" ]; then
            echo -e "${GREEN}✅ Password retrieved successfully${NC}"
            break
        fi
    fi
    
    # Check if Jenkins is fully started
    if docker logs jenkins-server 2>&1 | grep -q "Jenkins is fully up and running"; then
        # Jenkins is up, try to get password
        ADMIN_PASSWORD=$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "")
        if [ ! -z "$ADMIN_PASSWORD" ]; then
            echo -e "${GREEN}✅ Password retrieved from logs${NC}"
            break
        fi
    fi
    
    echo -n "."
    sleep 3
done
echo ""

# If still no password, provide manual instructions
if [ -z "$ADMIN_PASSWORD" ]; then
    echo -e "${YELLOW}⚠️  Password file not found. Checking Jenkins logs...${NC}"
    
    # Try to extract password from logs
    LOG_PASSWORD=$(docker logs jenkins-server 2>&1 | grep -A 5 "Please use the following password" | grep -oP '\*{10,}' | head -1)
    
    if [ ! -z "$LOG_PASSWORD" ]; then
        ADMIN_PASSWORD=$LOG_PASSWORD
        echo -e "${GREEN}✅ Password found in logs${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not retrieve password automatically${NC}"
        echo -e "${BLUE}   Run this command to get it:${NC}"
        echo -e "${BLUE}   docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword${NC}"
        echo ""
        echo -e "${BLUE}   Or check the logs:${NC}"
        echo -e "${BLUE}   docker logs jenkins-server 2>&1 | grep -A 5 'password'${NC}"
        ADMIN_PASSWORD="<see-commands-above>"
    fi
fi

# Final instructions
echo ""
echo -e "${GREEN}🎉 Jenkins is ready!${NC}"
echo ""

if [ "$ADMIN_PASSWORD" == "<see-commands-above>" ]; then
    echo -e "${YELLOW}📋 Manual Password Retrieval Needed:${NC}"
    echo ""
    echo -e "  ${BLUE}Method 1 - From file:${NC}"
    echo -e "  docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword"
    echo ""
    echo -e "  ${BLUE}Method 2 - From logs:${NC}"
    echo -e "  docker logs jenkins-server 2>&1 | grep -B 2 -A 5 'password'"
    echo ""
    echo -e "  ${BLUE}Method 3 - Check web UI:${NC}"
    echo -e "  Open ${JENKINS_URL} - password may be shown there"
    echo ""
else
    echo -e "${BLUE}📋 First Time Setup (Follow these steps):${NC}"
    echo ""
    echo -e "  ${YELLOW}Step 1:${NC} Open ${JENKINS_URL} in your browser"
    echo ""
    echo -e "  ${YELLOW}Step 2:${NC} Enter Initial Admin Password:"
    echo -e "           ${GREEN}${ADMIN_PASSWORD}${NC}"
    echo ""
    echo -e "  ${YELLOW}Step 3:${NC} Click ${GREEN}'Install suggested plugins'${NC}"
    echo -e "           (This installs Git, Pipeline, Docker, and other essential plugins)"
    echo -e "           Wait ~2-3 minutes for installation to complete"
    echo ""
    echo -e "  ${YELLOW}Step 4:${NC} Create your admin user:"
    echo -e "           - Username: (your choice, e.g., 'admin')"
    echo -e "           - Password: (choose a strong password)"
    echo -e "           - Full name: (your name)"
    echo -e "           - Email: (your email)"
    echo ""
    echo -e "  ${YELLOW}Step 5:${NC} Configure Jenkins URL"
    echo -e "           Keep default: ${JENKINS_URL}"
    echo ""
    echo -e "  ${YELLOW}Step 6:${NC} Click ${GREEN}'Start using Jenkins'${NC}"
    echo ""
    echo -e "${YELLOW}💡 IMPORTANT - SAVE THIS PASSWORD:${NC} ${GREEN}${ADMIN_PASSWORD}${NC}"
    echo ""
fi

echo -e "${BLUE}🔧 Useful Commands:${NC}"
echo -e "  Get password:  docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword"
echo -e "  View logs:     docker logs jenkins-server -f"
echo -e "  Stop Jenkins:  docker-compose down"
echo -e "  Start Jenkins: docker-compose up -d"
echo -e "  Reset Jenkins: ./reset-jenkins.sh"
echo ""
echo -e "${GREEN}🚀 Ready to build!${NC}"
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