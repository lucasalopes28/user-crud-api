# User CRUD API - Jenkins CI/CD

Simple Jenkins setup for building and deploying Spring Boot applications from GitHub.

## 🚀 Quick Start

### Option 1: Jenkins CI/CD

Run one command to set up everything:

```bash
./run-jenkins.sh
```

This will:
- ✅ Start Jenkins with Docker support
- ✅ Install Git and Docker CLI
- ✅ Install required Jenkins plugins
- ✅ Provide access credentials

### Option 2: GitLab CI/CD

Push to GitLab and pipelines run automatically:

```bash
# Add GitLab remote
git remote add gitlab https://gitlab.com/your-username/user-crud-api.git

# Push to GitLab
git push -u gitlab main
```

📖 **See `GITLAB_SETUP.md` for complete GitLab configuration**

## 📁 Project Structure

```
├── run-jenkins.sh         # One-click Jenkins setup
├── docker-compose.yml     # Jenkins container config
├── Jenkinsfile           # CI/CD pipeline
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

After setup completes, choose your preferred option:

**Option A: Pipeline from SCM (Recommended)**

1. Open **http://localhost:8090**
2. Login with provided credentials
3. Click **"New Item"**
4. Name: **"user-crud-api"**
5. Type: **"Pipeline"**
6. Configure Pipeline:
   - Definition: **"Pipeline script from SCM"**
   - SCM: **"Git"**
   - Repository URL: **"https://github.com/lucasalopes28/user-crud-api"**
   - Branch: **"*/main"**
   - Script Path: **"Jenkinsfile"**
7. **Save** and click **"Build Now"**

📖 **Detailed SCM setup:** See `JENKINS_SCM_SETUP.md`

**Option B: Standalone Pipeline (For Testing)**

1. Create Pipeline job as above
2. In Pipeline section:
   - Definition: **"Pipeline script"**
   - Copy content from **`Jenkinsfile.standalone`**
   - Paste into Script box
3. **Save** and **Build**

## 🐳 Pipeline Stages

The pipeline will:

1. **Checkout** - Clone code from GitHub
2. **Run Unit Tests** - Execute JUnit tests with Maven
3. **Build** - Create Docker image
4. **Test Image** - Validate Docker image
5. **Deploy to Staging** - Run on port 8080
6. **Integration Tests** - Test endpoints
7. **Deploy to Production** - Run on port 8081 (requires approval)
8. **Create Git Tag** - Auto-increment version (v0.0.1, v0.0.2, etc.)
9. **Cleanup** - Remove old images

### 🏷️ Automatic Versioning

Each successful build automatically:
- Creates a new Git tag with incremented version
- Uses semantic versioning (v0.0.1 → v0.0.2 → v0.0.3)
- Tags are created locally (see `GITHUB_CREDENTIALS.md` to push to GitHub)

## 🌐 Application Endpoints

After deployment:

- **Staging:** http://localhost:8080
- **Production:** http://localhost:8081
- **Health Check:** http://localhost:8080/actuator/health

### 📡 API Testing with curl

#### Health & Info Endpoints

```bash
# Health check
curl http://localhost:8080/actuator/health

# Application info
curl http://localhost:8080/actuator/info

# H2 Console (in browser)
open http://localhost:8080/h2-console
```

#### User CRUD Operations

**Create a User (POST)**
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890"
  }'
```

**Get All Users (GET)**
```bash
curl http://localhost:8080/api/users
```

**Get User by ID (GET)**
```bash
# Replace {id} with actual user ID
curl http://localhost:8080/api/users/1
```

**Update User (PUT)**
```bash
# Replace {id} with actual user ID
curl -X PUT http://localhost:8080/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Updated",
    "email": "john.updated@example.com",
    "phone": "+1234567890"
  }'
```

**Delete User (DELETE)**
```bash
# Replace {id} with actual user ID
curl -X DELETE http://localhost:8080/api/users/1
```

#### Complete Test Workflow

```bash
# 1. Create a user
USER_ID=$(curl -s -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Smith",
    "email": "jane.smith@example.com",
    "phone": "+9876543210"
  }' | jq -r '.id')

echo "Created user with ID: $USER_ID"

# 2. Get all users
echo "All users:"
curl -s http://localhost:8080/api/users | jq

# 3. Get specific user
echo "User details:"
curl -s http://localhost:8080/api/users/$USER_ID | jq

# 4. Update user
echo "Updating user..."
curl -s -X PUT http://localhost:8080/api/users/$USER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Updated",
    "email": "jane.updated@example.com",
    "phone": "+9876543210"
  }' | jq

# 5. Verify update
echo "Updated user:"
curl -s http://localhost:8080/api/users/$USER_ID | jq

# 6. Delete user
echo "Deleting user..."
curl -X DELETE http://localhost:8080/api/users/$USER_ID

# 7. Verify deletion
echo "Remaining users:"
curl -s http://localhost:8080/api/users | jq
```

#### Testing Production Environment

Replace `8080` with `8081` for production:

```bash
# Production health check
curl http://localhost:8081/actuator/health

# Production API
curl http://localhost:8081/api/users
```

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

### Git Errors ("not in a git directory" or "Error fetching remote repo")

**Quick Fix: Use Standalone Pipeline**
1. Copy content from `Jenkinsfile.standalone`
2. Create Pipeline with "Pipeline script" (not SCM)
3. Paste the script directly
4. This bypasses all Git/SCM issues

**Or Fix Git Plugin:**
```bash
# Reinstall Git and configure
docker exec -u root jenkins-server bash -c "
    apt-get update && apt-get install -y git
    git config --global user.email 'jenkins@localhost'
    git config --global user.name 'Jenkins'
"

# Reinstall Git plugin
docker exec jenkins-server jenkins-plugin-cli --plugins git:latest
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
