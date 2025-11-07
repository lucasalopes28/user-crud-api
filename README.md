# User CRUD API - Jenkins CI/CD

Simple Jenkins setup for building and deploying Spring Boot applications from GitHub.

## 🚀 Quick Start

Run one command to set up everything:

```bash
./run-jenkins.sh
```

This will:
- ✅ Start Jenkins with Docker support
- ✅ Install Git and Docker CLI
- ✅ Install required Jenkins plugins
- ✅ Provide access credentials

## 📁 Project Structure

```
├── run-jenkins.sh         # One-click Jenkins setup
├── docker-compose.yml     # Jenkins container config
├── Jenkinsfile.simple     # CI/CD pipeline
├── Dockerfile            # Application container
├── pom.xml              # Maven configuration
└── src/                 # Spring Boot source code
```

## 🎯 Usage

### 1. Setup Jenkins
```bash
chmod +x run-jenkins.sh
./run-jenkins.sh
```

### 2. Create Pipeline

After setup completes:

1. Open **http://localhost:8090**
2. Login with provided credentials
3. Click **"New Item"**
4. Name: **"user-crud-pipeline"**
5. Type: **"Pipeline"**
6. Configure:
   - Definition: **"Pipeline script from SCM"**
   - SCM: **"Git"**
   - Repository URL: **"https://github.com/lucasalopes28/user-crud-api"**
   - Branch: **"*/main"**
   - Script Path: **"Jenkinsfile.simple"**
7. **Save** and click **"Build Now"**

## 🐳 Pipeline Stages

The pipeline will:

1. **Checkout** - Clone code from GitHub
2. **Build** - Create Docker image
3. **Test** - Validate Docker image
4. **Deploy to Staging** - Run on port 8080
5. **Integration Tests** - Test endpoints
6. **Deploy to Production** - Run on port 8081 (requires approval)
7. **Cleanup** - Remove old images

## 🌐 Application Endpoints

After deployment:

- **Staging:** http://localhost:8080
- **Production:** http://localhost:8081
- **Health Check:** http://localhost:8080/actuator/health

## 🔧 Management Commands

```bash
# Start Jenkins
docker-compose up -d

# Stop Jenkins
docker-compose down

# View logs
docker logs jenkins-server

# Restart Jenkins
docker restart jenkins-server

# Check running containers
docker ps

# View application logs
docker logs user-crud-api-staging
docker logs user-crud-api-prod
```

## 🔍 Troubleshooting

### Jenkins Won't Start
```bash
docker-compose down
docker-compose up -d
docker logs jenkins-server
```

### SCM Option Not Available
Wait a few minutes for plugins to load, then restart:
```bash
docker restart jenkins-server
```

### Docker Not Working
```bash
docker exec -u root jenkins-server chmod 666 /var/run/docker.sock
docker restart jenkins-server
```

### Pipeline Fails
1. Check Jenkins logs: `docker logs jenkins-server`
2. Verify GitHub repository is accessible
3. Ensure Docker is working: `docker exec jenkins-server docker --version`
4. Check application logs: `docker logs user-crud-api-staging`

## 📚 Tech Stack

- **Spring Boot:** 3.2.0
- **Java:** 21
- **Database:** H2 (in-memory)
- **Build Tool:** Maven
- **Container:** Docker
- **CI/CD:** Jenkins

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Push changes to GitHub
4. Jenkins will automatically build and test

---

**Ready!** Run `./run-jenkins.sh` and start building! 🚀