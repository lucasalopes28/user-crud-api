#!/bin/bash

# Run Jenkins with your project mounted as a volume
# This allows Jenkins to access your project files directly

PROJECT_DIR=$(pwd)
JENKINS_HOME="$HOME/jenkins_home"

echo "Starting Jenkins with project mounted..."
echo "Project directory: $PROJECT_DIR"
echo "Jenkins home: $JENKINS_HOME"

# Create Jenkins home directory if it doesn't exist
mkdir -p $JENKINS_HOME

# Run Jenkins container with project volume mounted
docker run -d \
    --name jenkins-with-project \
    -p 8080:8080 \
    -p 50000:50000 \
    -v $JENKINS_HOME:/var/jenkins_home \
    -v $PROJECT_DIR:/var/jenkins_home/workspace/user-crud-api \
    jenkins/jenkins:lts

echo "Jenkins is starting..."
echo "Access Jenkins at: http://localhost:8080"
echo "Project files are available at: /var/jenkins_home/workspace/user-crud-api"
echo ""
echo "To get initial admin password:"
echo "docker exec jenkins-with-project cat /var/jenkins_home/secrets/initialAdminPassword"