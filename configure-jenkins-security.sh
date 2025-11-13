#!/bin/bash

# Jenkins Security Configuration Script
# Enables authentication and creates admin user

set -e

echo "🔐 Configuring Jenkins Security..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check if Jenkins is running
if ! docker ps | grep -q jenkins-server; then
    echo -e "${RED}❌ Jenkins is not running${NC}"
    echo -e "${YELLOW}Run: ./run-jenkins.sh first${NC}"
    exit 1
fi

# Prompt for admin credentials
echo -e "${BLUE}Enter admin credentials:${NC}"
read -p "Username (default: admin): " ADMIN_USER
ADMIN_USER=${ADMIN_USER:-admin}

read -sp "Password: " ADMIN_PASSWORD
echo ""

if [ -z "$ADMIN_PASSWORD" ]; then
    echo -e "${RED}❌ Password cannot be empty${NC}"
    exit 1
fi

# Create security configuration script
echo -e "${YELLOW}📝 Creating security configuration...${NC}"
docker exec jenkins-server bash -c "cat > /var/jenkins_home/init.groovy.d/security-config.groovy << 'EOFSCRIPT'
#!groovy
import jenkins.model.*
import hudson.security.*
import jenkins.install.InstallState

def instance = Jenkins.getInstance()

println 'Configuring Jenkins security...'

// Create security realm (user database)
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
instance.setSecurityRealm(hudsonRealm)

// Create admin user
def user = hudsonRealm.createAccount('${ADMIN_USER}', '${ADMIN_PASSWORD}')
user.save()
println 'Admin user created: ${ADMIN_USER}'

// Set authorization strategy
def strategy = new FullControlOnceLoggedInStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
println 'Authorization strategy set'

// Disable setup wizard
if (!instance.installState.isSetupComplete()) {
    InstallState.INITIAL_SETUP_COMPLETED.initializeState()
    println 'Setup wizard disabled'
}

// Save configuration
instance.save()
println 'Security configuration saved successfully'
EOFSCRIPT
"

# Restart Jenkins to apply changes
echo -e "${YELLOW}🔄 Restarting Jenkins to apply security settings...${NC}"
docker restart jenkins-server

# Wait for Jenkins to start
echo -e "${YELLOW}⏳ Waiting for Jenkins to restart...${NC}"
sleep 30

# Wait for Jenkins web interface
for i in {1..15}; do
    if curl -s http://localhost:8090 >/dev/null 2>&1; then
        break
    fi
    echo -n "."
    sleep 2
done
echo ""

# Clean up security script (optional, for security)
docker exec jenkins-server rm -f /var/jenkins_home/init.groovy.d/security-config.groovy

echo ""
echo -e "${GREEN}✅ Security configured successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Login Credentials:${NC}"
echo -e "  🌐 URL: http://localhost:8090"
echo -e "  👤 Username: ${ADMIN_USER}"
echo -e "  🔑 Password: ********"
echo ""
echo -e "${YELLOW}⚠️  Keep these credentials safe!${NC}"
echo ""
