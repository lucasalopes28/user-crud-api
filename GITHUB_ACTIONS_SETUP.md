# GitHub Actions CI/CD Setup Guide

Complete guide to set up CI/CD for your Spring Boot application using GitHub Actions.

## 🎯 Overview

GitHub Actions is GitHub's built-in CI/CD platform. It's free for public repositories and includes 2,000 minutes/month for private repos.

## ✅ What's Included

Your `.github/workflows/ci-cd.yml` includes:

1. **Test Job** - Run unit tests with JaCoCo coverage
2. **Build Job** - Build JAR with Maven
3. **Docker Job** - Build and push to GitHub Container Registry
4. **Test Container** - Verify Docker image works
5. **Release Job** - Auto-create GitHub releases with version tags

## 🚀 Quick Start

### Step 1: Push to GitHub

```bash
# Add GitHub remote (if not already added)
git remote add origin https://github.com/lucasalopes28/user-crud-api.git

# Push code
git push -u origin main
```

### Step 2: Enable GitHub Actions

1. Go to your repository on GitHub
2. Click **"Actions"** tab
3. GitHub Actions should be enabled by default
4. You'll see the workflow running automatically!

### Step 3: Enable GitHub Container Registry

1. Go to **Settings** → **Actions** → **General**
2. Scroll to **"Workflow permissions"**
3. Select **"Read and write permissions"**
4. Check **"Allow GitHub Actions to create and approve pull requests"**
5. Click **Save**

## 📊 Pipeline Stages

### 1. Test Job
```yaml
- Checkout code
- Set up JDK 21
- Run Maven tests
- Publish test results
- Generate coverage report
- Upload to Codecov (optional)
- Archive test artifacts
```

**Runs on:** All branches and pull requests

### 2. Build Job
```yaml
- Checkout code
- Set up JDK 21
- Build JAR with Maven
- Upload JAR artifact
```

**Runs on:** All branches (after tests pass)

### 3. Docker Job
```yaml
- Checkout code
- Set up Docker Buildx
- Login to GitHub Container Registry
- Build Docker image
- Push to registry with multiple tags
```

**Runs on:** All branches (after build completes)

**Image tags:**
- `main` - Branch name
- `main-abc1234` - Branch + commit SHA
- `latest` - Latest from main branch

### 4. Test Container Job
```yaml
- Pull Docker image
- Run container
- Test health endpoints
- Verify container works
- Cleanup
```

**Runs on:** All branches (after Docker push)

### 5. Release Job
```yaml
- Get latest Git tag
- Increment version (v0.0.1 → v0.0.2)
- Create GitHub release
- Upload JAR artifact
- Tag Docker image
```

**Runs on:** Only main/master branch (after all jobs pass)

## 🐳 Using Your Docker Image

### Pull from GitHub Container Registry

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Pull image
docker pull ghcr.io/lucasalopes28/user-crud-api:latest

# Run locally
docker run -d -p 8080:8080 ghcr.io/lucasalopes28/user-crud-api:latest
```

### Make Image Public

By default, images are private. To make public:

1. Go to your GitHub profile
2. Click **"Packages"**
3. Click on `user-crud-api` package
4. Click **"Package settings"**
5. Scroll to **"Danger Zone"**
6. Click **"Change visibility"** → **"Public"**

## 🔧 Configuration

### Secrets

GitHub Actions automatically provides:
- `GITHUB_TOKEN` - For pushing to Container Registry
- `GITHUB_ACTOR` - Your username

No additional secrets needed for basic setup!

### Optional: Add Custom Secrets

For additional features, add secrets in:
**Settings** → **Secrets and variables** → **Actions**

Examples:
- `DOCKER_HUB_USERNAME` - For Docker Hub
- `DOCKER_HUB_TOKEN` - For Docker Hub
- `SLACK_WEBHOOK` - For notifications
- `CODECOV_TOKEN` - For Codecov integration

### Environment Variables

Edit in `.github/workflows/ci-cd.yml`:

```yaml
env:
  APP_NAME: user-crud-api
  STAGING_PORT: 8080
  PROD_PORT: 8081
```

## 📈 Viewing Results

### Workflow Runs

1. Go to **Actions** tab
2. See all workflow runs
3. Click on a run to see details
4. View logs for each job

### Test Results

1. Click on workflow run
2. Go to **"Summary"**
3. View test results and coverage
4. Download artifacts

### Releases

1. Go to **"Releases"** (right sidebar)
2. See all auto-generated releases
3. Download JAR files
4. View release notes

### Container Images

1. Go to repository main page
2. Click **"Packages"** (right sidebar)
3. See all Docker images
4. View tags and pull commands

## 🎨 Customization

### Run on Different Events

```yaml
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  workflow_dispatch:  # Manual trigger
```

### Add Slack Notifications

```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Pipeline completed!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
  if: always()
```

### Deploy to Cloud

```yaml
deploy-cloud:
  name: Deploy to Cloud Run
  runs-on: ubuntu-latest
  needs: docker
  steps:
    - name: Deploy to Google Cloud Run
      uses: google-github-actions/deploy-cloudrun@v2
      with:
        service: user-crud-api
        image: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
```

### Matrix Testing

Test on multiple Java versions:

```yaml
test:
  strategy:
    matrix:
      java: [17, 21]
  steps:
    - uses: actions/setup-java@v4
      with:
        java-version: ${{ matrix.java }}
```

## 🔍 Troubleshooting

### Workflow Not Running

**Check:**
- Workflow file is in `.github/workflows/`
- File has `.yml` or `.yaml` extension
- YAML syntax is valid
- Actions are enabled in repository settings

### Permission Denied for Container Registry

**Fix:**
1. Settings → Actions → General
2. Workflow permissions → Read and write
3. Save

### Tests Failing

**Debug:**
1. Click on failed job
2. Expand test step
3. View detailed logs
4. Download test artifacts

### Docker Build Fails

**Check:**
- Dockerfile exists
- Dockerfile syntax is correct
- All required files are in repository

## 📊 GitHub Actions vs Others

| Feature | GitHub Actions | Jenkins | GitLab CI/CD |
|---------|----------------|---------|--------------|
| Setup | Zero | Manual | Zero |
| Free tier | 2000 min/month | Unlimited | 400 min/month |
| Integration | Native | Manual | Native |
| UI | Modern | Traditional | Modern |
| Learning curve | Easy | Medium | Easy |
| Marketplace | Yes | Plugins | Limited |

## 🎯 Best Practices

1. **Use caching** for dependencies
2. **Matrix builds** for multiple versions
3. **Artifacts** for build outputs
4. **Branch protection** for main
5. **Required checks** before merge
6. **Automated releases** with tags
7. **Container scanning** for security

## 📚 Useful Actions

### Testing
- `actions/setup-java@v4` - Set up Java
- `dorny/test-reporter@v1` - Test reports
- `codecov/codecov-action@v4` - Coverage

### Docker
- `docker/setup-buildx-action@v3` - Docker Buildx
- `docker/login-action@v3` - Registry login
- `docker/build-push-action@v5` - Build & push

### Deployment
- `google-github-actions/deploy-cloudrun@v2` - Google Cloud
- `aws-actions/amazon-ecs-deploy-task-definition@v1` - AWS ECS
- `azure/webapps-deploy@v2` - Azure

### Notifications
- `8398a7/action-slack@v3` - Slack
- `dawidd6/action-send-mail@v3` - Email

## 🚀 Advanced Features

### Reusable Workflows

Create reusable workflows:

```yaml
# .github/workflows/reusable-test.yml
on:
  workflow_call:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: mvn test
```

Use in other workflows:

```yaml
jobs:
  test:
    uses: ./.github/workflows/reusable-test.yml
```

### Composite Actions

Create custom actions:

```yaml
# .github/actions/setup-app/action.yml
name: Setup Application
runs:
  using: composite
  steps:
    - uses: actions/setup-java@v4
      with:
        java-version: '21'
```

### Environment Protection

Protect production environment:

1. Settings → Environments
2. Add environment: `production`
3. Add protection rules:
   - Required reviewers
   - Wait timer
   - Deployment branches

## ✅ Verification

After setup, verify:

- [ ] Workflow file exists in `.github/workflows/`
- [ ] Push triggers workflow
- [ ] Tests run successfully
- [ ] Docker image builds
- [ ] Image pushed to registry
- [ ] Release created (on main branch)
- [ ] Artifacts available

## 📖 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Marketplace](https://github.com/marketplace?type=actions)
- [Actions Examples](https://github.com/actions/starter-workflows)

---

**GitHub Actions is ready!** Push to GitHub and watch your pipeline run automatically. 🎉