# User CRUD API - Jenkins CI/CD Setup

Simple Jenkins setup for building and deploying Spring Boot applications from GitHub.

## 🚀 Quick Setup

Run this single command to set up Jenkins:

```bash
./run-jenkins.sh
```

This script will:
- ✅ Start Jenkins with Docker support
- ✅ Install Docker CLI in Jenkins container
- ✅ Configure permissions and access
- ✅ Provide Jenkins credentials
- ✅ Give you step-by-step instructions

## 📋 What You Get

- **Jenkins Server** running on http://localhost:8090
- **Automated Pipeline** that builds and deploys your Spring Boot app
- **Docker Integration** for containerized deployments
- **GitHub Integration** for automatic builds on code changes

## 🔧 Pipeline Features

The Jenkins pipeline will:

1. **Checkout** code from https://github.com/lucasalopes28/user-crud-api
2. **Build** the Spring Boot application with Docker
3. **Test** the application
4. **Deploy to Staging** on port 8080
5. **Run Integration Tests**
6. **Deploy to Production** on port 8081 (with approval)

## 📁 Project Structure

```
├── run-jenkins.sh           # One-click Jenkins setup
├── docker-compose.yml       # Jenkins container configuration  
├── Jenkinsfile.simple       # Docker-based CI/CD pipeline
├── Dockerfile              # Application container
└── README.md              # This file
```

## 🎯 Usage

### Initial Setup
```bash
# Run the setup script
./run-jenkins.sh
```

### Access Jenkins
- **URL:** http://localhost:8090
- **Username:** admin
- **Password:** (provided by setup script)

### Manage Jenkins
```bash
# Start Jenkins
docker-compose up -d

# Stop Jenkins
docker-compose down

# View logs
docker logs jenkins-server

# Restart Jenkins
docker restart jenkins-server
```

### Manual Job Creation (if needed)

If the automatic job creation fails:

1. Open http://localhost:8090
2. Click "New Item"
3. Enter name: `user-crud-api-pipeline`
4. Select "Pipeline"
5. In Pipeline section:
   - Definition: "Pipeline script from SCM"
   - SCM: Git
   - Repository URL: `https://github.com/lucasalopes28/user-crud-api`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile.simple`
6. Save and Build

## 🐳 Application Endpoints

After successful deployment:

- **Staging:** http://localhost:8080
- **Production:** http://localhost:8081
- **Health Check:** http://localhost:8080/actuator/health

## 🔍 Troubleshooting

### Jenkins Won't Start
```bash
docker-compose down
docker-compose up -d
docker logs jenkins-server
```

### Docker Not Working in Jenkins
```bash
# Fix Docker permissions
docker exec -u root jenkins-server chmod 666 /var/run/docker.sock
```

### Pipeline Fails
1. Check Jenkins logs: `docker logs jenkins-server`
2. Verify GitHub repository is accessible
3. Check Dockerfile exists in repository
4. Ensure all required files are present

## 📚 Additional Information

- **Spring Boot Version:** 3.2.0
- **Java Version:** 21
- **Database:** H2 (in-memory)
- **Build Tool:** Maven
- **Container Runtime:** Docker

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Push to GitHub
5. Jenkins will automatically build and test your changes

## 📞 Support

If you encounter issues:
1. Check the Jenkins logs
2. Verify Docker is running
3. Ensure ports 8080, 8081, and 8090 are available
4. Check GitHub repository accessibility

---

**Ready to go!** Run `./run-jenkins.sh` and start building! 🚀