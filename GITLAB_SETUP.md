# GitLab CI/CD Setup Guide

Complete guide to set up CI/CD for your Spring Boot application on GitLab.

## 🎯 Overview

GitLab CI/CD uses `.gitlab-ci.yml` to define pipelines. This guide covers:
- Setting up GitLab repository
- Configuring GitLab Runner
- Understanding the pipeline
- Deploying your application

## 📋 Prerequisites

- GitLab account (gitlab.com or self-hosted)
- Docker installed on your GitLab Runner
- Git configured locally

## 🚀 Quick Start

### Step 1: Create GitLab Repository

1. **Go to GitLab:** https://gitlab.com
2. **Create new project:**
   - Click **"New project"**
   - Select **"Create blank project"**
   - Project name: `user-crud-api`
   - Visibility: Public or Private
   - Click **"Create project"**

### Step 2: Push Your Code to GitLab

```bash
# Add GitLab as remote
git remote add gitlab https://gitlab.com/your-username/user-crud-api.git

# Or if you want to replace origin
git remote set-url origin https://gitlab.com/your-username/user-crud-api.git

# Push to GitLab
git push -u gitlab main
# or
git push -u origin main
```

### Step 3: Verify Pipeline

1. Go to your GitLab project
2. Click **CI/CD** → **Pipelines**
3. You should see a pipeline running automatically!

## 🏃 GitLab Runner Setup

### Option 1: Use GitLab.com Shared Runners (Easiest)

GitLab.com provides free shared runners:
- **No setup required!**
- Automatically available for all projects
- Limited to 400 CI/CD minutes per month (free tier)

To enable:
1. Go to **Settings** → **CI/CD**
2. Expand **Runners**
3. Enable **"Enable shared runners for this project"**

### Option 2: Install Your Own GitLab Runner

For unlimited builds or self-hosted GitLab:

#### On macOS:

```bash
# Install GitLab Runner
brew install gitlab-runner

# Register runner
gitlab-runner register

# When prompted:
# GitLab URL: https://gitlab.com (or your GitLab URL)
# Registration token: (get from Settings → CI/CD → Runners)
# Description: my-runner
# Tags: docker, macos
# Executor: docker
# Default Docker image: docker:latest

# Start runner
gitlab-runner start
```

#### On Linux:

```bash
# Download GitLab Runner
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

# Make it executable
sudo chmod +x /usr/local/bin/gitlab-runner

# Create GitLab Runner user
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# Install and start
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start

# Register runner
sudo gitlab-runner register
```

#### Using Docker:

```bash
# Run GitLab Runner in Docker
docker run -d --name gitlab-runner --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v gitlab-runner-config:/etc/gitlab-runner \
  gitlab/gitlab-runner:latest

# Register runner
docker exec -it gitlab-runner gitlab-runner register
```

## 📊 Pipeline Stages Explained

### 1. Test Stage
```yaml
unit-tests:
  - Runs Maven tests
  - Generates JUnit reports
  - Calculates code coverage
  - Artifacts saved for 1 week
```

### 2. Build Stage
```yaml
build-docker-image:
  - Builds Docker image
  - Tags with commit SHA
  - Tags as latest
```

### 3. Deploy Staging
```yaml
deploy-staging:
  - Deploys to staging environment
  - Runs on main/master/develop branches
  - Automatic deployment
  - Port 8080

integration-tests:
  - Tests staging endpoints
  - Validates deployment
```

### 4. Deploy Production
```yaml
deploy-production:
  - Deploys to production
  - Requires manual approval
  - Only on main/master branch
  - Port 8081
```

## 🔧 Configuration

### Environment Variables

Set in GitLab: **Settings** → **CI/CD** → **Variables**

```bash
# Docker Registry (optional)
DOCKER_REGISTRY=registry.gitlab.com/your-username/user-crud-api

# Docker credentials (for private registry)
CI_REGISTRY_USER=your-username
CI_REGISTRY_PASSWORD=your-token

# Application settings
STAGING_PORT=8080
PROD_PORT=8081
```

### Protected Branches

Protect your main branch:
1. **Settings** → **Repository** → **Protected branches**
2. Protect `main` branch
3. Allowed to merge: Maintainers
4. Allowed to push: No one

### Deployment Environments

GitLab automatically creates environments:
- **Staging:** http://localhost:8080
- **Production:** http://localhost:8081

View in: **Deployments** → **Environments**

## 🎨 Pipeline Customization

### Enable/Disable Stages

```yaml
# Skip tests (not recommended)
unit-tests:
  script:
    - echo "Tests skipped"
  when: manual

# Auto-deploy to production (remove manual approval)
deploy-production:
  when: on_success  # instead of: manual
```

### Add Notifications

```yaml
# Slack notification
notify-slack:
  stage: .post
  script:
    - 'curl -X POST -H "Content-type: application/json" --data "{\"text\":\"Pipeline $CI_PIPELINE_ID completed\"}" $SLACK_WEBHOOK_URL'
  when: always
```

### Add Docker Registry Push

```yaml
push-to-registry:
  stage: build
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker tag $APP_NAME:$CI_COMMIT_SHORT_SHA $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
```

## 📈 Monitoring & Logs

### View Pipeline

1. **CI/CD** → **Pipelines**
2. Click on pipeline number
3. View each job's logs

### View Job Logs

1. Click on job name (e.g., "unit-tests")
2. View real-time logs
3. Download artifacts

### View Environments

1. **Deployments** → **Environments**
2. See staging and production status
3. View deployment history

## 🔍 Troubleshooting

### Pipeline Not Starting

**Check:**
- `.gitlab-ci.yml` exists in repository root
- File is valid YAML (use GitLab CI Lint)
- Runners are available

**Validate YAML:**
1. **CI/CD** → **Editor**
2. Paste your `.gitlab-ci.yml`
3. Click **"Validate"**

### Runner Issues

```bash
# Check runner status
gitlab-runner status

# View runner logs
gitlab-runner --debug run

# Restart runner
gitlab-runner restart
```

### Docker Permission Denied

```bash
# Add gitlab-runner to docker group
sudo usermod -aG docker gitlab-runner

# Restart runner
sudo gitlab-runner restart
```

### Tests Failing

```bash
# Run tests locally
mvn clean test

# Check test reports in GitLab
# CI/CD → Pipelines → Job → Tests tab
```

## 🆚 GitLab vs Jenkins

| Feature | GitLab CI/CD | Jenkins |
|---------|--------------|---------|
| Configuration | `.gitlab-ci.yml` | `Jenkinsfile` |
| Setup | Built-in | Separate installation |
| UI | Modern, integrated | Plugin-based |
| Runners | Shared or self-hosted | Agents/nodes |
| Free tier | 400 min/month | Unlimited (self-hosted) |
| Learning curve | Easier | Steeper |

## 📚 GitLab CI/CD Features

### Merge Request Pipelines

Automatically run on merge requests:
```yaml
unit-tests:
  only:
    - merge_requests
```

### Scheduled Pipelines

Run pipelines on schedule:
1. **CI/CD** → **Schedules**
2. **New schedule**
3. Set cron expression: `0 2 * * *` (daily at 2 AM)

### Pipeline Badges

Add to README:
```markdown
[![pipeline status](https://gitlab.com/your-username/user-crud-api/badges/main/pipeline.svg)](https://gitlab.com/your-username/user-crud-api/-/commits/main)

[![coverage report](https://gitlab.com/your-username/user-crud-api/badges/main/coverage.svg)](https://gitlab.com/your-username/user-crud-api/-/commits/main)
```

## ✅ Best Practices

1. **Use caching** for dependencies
2. **Artifacts** for test reports
3. **Manual approval** for production
4. **Protected branches** for main
5. **Environment variables** for secrets
6. **Merge request pipelines** for code review
7. **Scheduled pipelines** for nightly builds

## 🚀 Next Steps

1. ✅ Push code to GitLab
2. ✅ Verify pipeline runs
3. ✅ Configure runners (if needed)
4. ✅ Set up environment variables
5. ✅ Enable merge request pipelines
6. ✅ Add pipeline badges to README

## 📖 Additional Resources

- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [GitLab Runner Documentation](https://docs.gitlab.com/runner/)
- [.gitlab-ci.yml Reference](https://docs.gitlab.com/ee/ci/yaml/)
- [GitLab CI/CD Examples](https://docs.gitlab.com/ee/ci/examples/)

---

**Ready for GitLab!** Push your code and watch the pipeline run automatically. 🎉