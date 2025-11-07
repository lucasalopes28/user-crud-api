#!/bin/bash

# Script to install JDK 21 and Maven 3.9.0 on Jenkins server
# Run this script on your Jenkins server with sudo privileges

set -e

echo "Installing JDK 21 and Maven 3.9.0 for Jenkins..."

# Create tools directory
TOOLS_DIR="/opt/jenkins-tools"
sudo mkdir -p $TOOLS_DIR
cd $TOOLS_DIR

# Install JDK 21
echo "Installing JDK 21..."
if [ ! -d "jdk-21" ]; then
    # Download OpenJDK 21
    wget https://download.java.net/java/GA/jdk21.0.1/415e3f918a1f4062a0074a2794853d0d/12/GPL/openjdk-21.0.1_linux-x64_bin.tar.gz
    
    # Extract JDK
    tar -xzf openjdk-21.0.1_linux-x64_bin.tar.gz
    mv jdk-21.0.1 jdk-21
    rm openjdk-21.0.1_linux-x64_bin.tar.gz
    
    echo "JDK 21 installed at: $TOOLS_DIR/jdk-21"
else
    echo "JDK 21 already exists at: $TOOLS_DIR/jdk-21"
fi

# Install Maven 3.9.0
echo "Installing Maven 3.9.0..."
if [ ! -d "maven-3.9.0" ]; then
    # Download Maven 3.9.0
    wget https://archive.apache.org/dist/maven/maven-3/3.9.0/binaries/apache-maven-3.9.0-bin.tar.gz
    
    # Extract Maven
    tar -xzf apache-maven-3.9.0-bin.tar.gz
    mv apache-maven-3.9.0 maven-3.9.0
    rm apache-maven-3.9.0-bin.tar.gz
    
    echo "Maven 3.9.0 installed at: $TOOLS_DIR/maven-3.9.0"
else
    echo "Maven 3.9.0 already exists at: $TOOLS_DIR/maven-3.9.0"
fi

# Set proper permissions
sudo chown -R jenkins:jenkins $TOOLS_DIR
sudo chmod -R 755 $TOOLS_DIR

echo "Installation completed!"
echo ""
echo "Next steps:"
echo "1. Go to Jenkins → Manage Jenkins → Global Tool Configuration"
echo "2. Add JDK with name 'JDK-21' and JAVA_HOME: $TOOLS_DIR/jdk-21"
echo "3. Add Maven with name 'Maven-3.9.0' and MAVEN_HOME: $TOOLS_DIR/maven-3.9.0"
echo ""
echo "Or use these paths in your Jenkins configuration:"
echo "JDK 21 Path: $TOOLS_DIR/jdk-21"
echo "Maven 3.9.0 Path: $TOOLS_DIR/maven-3.9.0"