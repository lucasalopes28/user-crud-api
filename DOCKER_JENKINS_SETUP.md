# Docker & Jenkins Setup for User CRUD API

This guide explains how to build and deploy the User CRUD API using Docker and Jenkins.

## Prerequisites

- Docker and Docker Compose installed
- Git repository access
- At least 4GB RAM available

## Quick Start

### 1. Build and Run Everything
```bash
./build-and-deploy.sh
```

### 2. Manual Setup

#### Build Docker Image
```bash
# Build the application image
docker build -t user-crud-api:latest .

# Or use docker-compose
docker-compose build
```

#### Run with Docker Compose
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f user-crud-api
```

## Jenkins Setup

### 1. Start Jenkins
```bash
docker-compose up -d jenkins
```

### 2. Access Jenkins
- URL: http://localhost:8090
- Username: `admin`
- Password: `admin123`

### 3. Create Pipeline Job

1. Go to Jenkins dashboard
2. Click "New Item"
3. Enter job name: `user-crud-api-pipeline`
4. Select "Pipeline"
5. In Pipeline section:
   - Definition: "Pipeline script from SCM"
   - SCM: Git
   - Repository URL: Your git repository URL
   - Script Path: `Jenkinsfile`

### 4. Configure Tools (if needed)

Go to "Manage Jenkins" > "Global Tool Configuration":

- **JDK**: Name: `JDK-21`, JAVA_HOME: `/opt/java/openjdk`
- **Maven**: Name: `Maven-3.9.4`, MAVEN_HOME: `/usr/share/maven`
- **Git**: Name: `Default`, Path: `git`

## Pipeline Stages

The Jenkins pipeline includes:

1. **Checkout** - Get source code
2. **Build** - Compile the application
3. **Test** - Run unit tests with coverage
4. **Package** - Create JAR file
5. **Code Quality** - SonarQube analysis & dependency check
6. **Build Docker Image** - Create container image
7. **Security Scan** - Scan image with Trivy
8. **Deploy to Staging** - Deploy on develop branch
9. **Deploy to Production** - Deploy on main branch (manual approval)

## Available Endpoints

### Application
- **API Base**: http://localhost:8080/api/users
- **Health Check**: http://localhost:8080/actuator/health
- **Metrics**: http://localhost:8080/actuator/metrics

### Jenkins
- **Dashboard**: http://localhost:8090
- **Blue Ocean**: http://localhost:8090/blue

## Docker Commands

### Application Management
```bash
# Build image
docker build -t user-crud-api .

# Run container
docker run -d -p 8080:8080 --name user-crud-api user-crud-api:latest

# View logs
docker logs -f user-crud-api

# Stop container
docker stop user-crud-api

# Remove container
docker rm user-crud-api
```

### Jenkins Management
```bash
# Start Jenkins
docker-compose up -d jenkins

# View Jenkins logs
docker-compose logs -f jenkins

# Stop Jenkins
docker-compose stop jenkins

# Backup Jenkins data
docker run --rm -v jenkins_home:/data -v $(pwd):/backup alpine tar czf /backup/jenkins-backup.tar.gz -C /data .
```

## Environment Variables

### Application
- `SPRING_PROFILES_ACTIVE`: Set to `docker` for container deployment
- `SERVER_PORT`: Application port (default: 8080)

### Jenkins
- `JAVA_OPTS`: JVM options for Jenkins
- `JENKINS_OPTS`: Jenkins-specific options

## Troubleshooting

### Common Issues

1. **Port conflicts**
   ```bash
   # Check what's using port 8080
   lsof -i :8080
   
   # Use different port
   docker run -p 8081:8080 user-crud-api
   ```

2. **Jenkins not starting**
   ```bash
   # Check logs
   docker-compose logs jenkins
   
   # Restart Jenkins
   docker-compose restart jenkins
   ```

3. **Build failures**
   ```bash
   # Clean and rebuild
   docker-compose down
   docker system prune -f
   docker-compose up --build
   ```

### Health Checks

```bash
# Application health
curl http://localhost:8080/actuator/health

# Jenkins health
curl http://localhost:8090/login

# Container status
docker ps
```

## Security Considerations

1. **Change default Jenkins password** in production
2. **Use secrets management** for sensitive data
3. **Enable HTTPS** for production deployments
4. **Regular security updates** for base images
5. **Network isolation** between services

## Production Deployment

For production, consider:

1. **External database** instead of H2
2. **Load balancer** for high availability
3. **Monitoring** with Prometheus/Grafana
4. **Log aggregation** with ELK stack
5. **Backup strategy** for data and configurations

## Cleanup

```bash
# Stop all services
docker-compose down

# Remove volumes (WARNING: This deletes Jenkins data)
docker-compose down -v

# Clean up Docker system
docker system prune -a
```