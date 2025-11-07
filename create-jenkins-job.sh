#!/bin/bash

# Script to create Jenkins job with Jenkinsfile

echo "Creating Jenkins job..."

# Wait for Jenkins to be ready
echo "Waiting for Jenkins to be ready..."
until curl -s http://localhost:8090/login > /dev/null; do
    echo "Waiting for Jenkins..."
    sleep 5
done

# Download Jenkins CLI
echo "Downloading Jenkins CLI..."
curl -s -O http://localhost:8090/jnlpJars/jenkins-cli.jar

# Create job XML configuration
cat > job-config.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <actions/>
  <description>User CRUD API Pipeline</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.92">
    <script>
pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'user-crud-api'
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Build') {
            steps {
                echo 'Building application...'
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'mvn test'
            }
        }
        
        stage('Package') {
            steps {
                echo 'Packaging application...'
                sh 'mvn package -DskipTests'
            }
        }
        
        stage('Docker Build') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }
    }
}
    </script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

# Create the job
echo "Creating Jenkins job..."
java -jar jenkins-cli.jar -s http://localhost:8090 -auth admin:admin123 create-job user-crud-api-pipeline < job-config.xml

echo "Job created successfully!"
echo "Access it at: http://localhost:8090/job/user-crud-api-pipeline/"

# Cleanup
rm jenkins-cli.jar job-config.xml