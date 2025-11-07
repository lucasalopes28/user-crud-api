#!/bin/bash

echo "Setting up Jenkins with admin user..."

# Stop current Jenkins
docker stop jenkins 2>/dev/null || true
docker rm jenkins 2>/dev/null || true

# Start Jenkins with setup wizard disabled
docker run -d \
  --name jenkins \
  -p 8090:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  jenkins/jenkins:lts

echo "Waiting for Jenkins to start..."
sleep 30

# Create admin user
docker exec jenkins bash -c "
echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount(\"admin\", \"admin123\")' | java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 groovy =
"

echo "Jenkins setup complete!"
echo "Access Jenkins at: http://localhost:8090"
echo "Username: admin"
echo "Password: admin123"