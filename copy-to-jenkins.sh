#!/bin/bash

# Script to copy project files directly to Jenkins workspace
# Replace these variables with your actual Jenkins server details

JENKINS_SERVER="your-jenkins-server"
JENKINS_USER="jenkins"
JENKINS_WORKSPACE="/var/lib/jenkins/workspace/user-crud-api"

echo "Copying project files to Jenkins server..."

# Create workspace directory on Jenkins server
ssh $JENKINS_USER@$JENKINS_SERVER "mkdir -p $JENKINS_WORKSPACE"

# Copy all project files except .git and target directories
rsync -av \
    --exclude='.git' \
    --exclude='target' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    ./ $JENKINS_USER@$JENKINS_SERVER:$JENKINS_WORKSPACE/

echo "Files copied successfully!"
echo "Next steps:"
echo "1. Create a Jenkins Freestyle project"
echo "2. Set workspace to: $JENKINS_WORKSPACE"
echo "3. Add build steps to run Maven commands"