# Jenkins GitHub Webhook Configuration

Complete guide to configure Jenkins to automatically detect changes in GitHub branches.

## 🎯 Overview

There are two main ways to configure Jenkins to detect GitHub changes:

1. **GitHub Webhooks** (Recommended) - Instant trigger on push
2. **Polling** - Jenkins checks GitHub periodically

## 🚀 Method 1: GitHub Webhooks (Recommended)

Webhooks trigger Jenkins immediately when you push to GitHub.

### Prerequisites

- Jenkins accessible from the internet (or use ngrok for local testing)
- GitHub repository access
- Jenkins GitHub plugin installed

### Step 1: Install Jenkins Plugins

1. Go to Jenkins: `http://localhost:8090`
2. Click **"Manage Jenkins"** → **"Manage Plugins"**
3. Go to **"Available"** tab
4. Search and install:
   - ✅ **GitHub Integration Plugin**
   - ✅ **GitHub Branch Source Plugin**
   - ✅ **GitHub API Plugin**
5. Click **"Install without restart"**
6. Check **"Restart Jenkins when installation is complete"**

### Step 2: Create GitHub Personal Access Token

1. Go to GitHub: [github.com/settings/tokens](https://github.com/settings/tokens)
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Name: `Jenkins Webhook`
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `admin:repo_hook` (Full control of repository hooks)
5. Click **"Generate token"**
6. **Copy the token** (you won't see it again!)

### Step 3: Add GitHub Credentials to Jenkins

1. Go to Jenkins: **"Manage Jenkins"** → **"Manage Credentials"**
2. Click **(global)** domain
3. Click **"Add Credentials"**
4. Configure:
   - **Kind**: Username with password
   - **Username**: Your GitHub username
   - **Password**: Paste the Personal Access Token
   - **ID**: `github-token`
   - **Description**: `GitHub Personal Access Token`
5. Click **"Create"**

### Step 4: Configure Jenkins Job

#### Option A: Freestyle Project

1. Go to your Jenkins job
2. Click **"Configure"**
3. Under **"Source Code Management"**:
   - Select **Git**
   - **Repository URL**: `https://github.com/lucasalopes28/user-crud-api.git`
   - **Credentials**: Select `github-token`
   - **Branches to build**: `*/main` (or `*/develop`, `*/*` for all branches)
4. Under **"Build Triggers"**:
   - ✅ Check **"GitHub hook trigger for GITScm polling"**
5. Click **"Save"**

#### Option B: Pipeline Project

1. Go to your Jenkins job
2. Click **"Configure"**
3. Under **"Build Triggers"**:
   - ✅ Check **"GitHub hook trigger for GITScm polling"**
4. Under **"Pipeline"**:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/lucasalopes28/user-crud-api.git`
   - **Credentials**: Select `github-token`
   - **Branches to build**: `*/main`
   - **Script Path**: `Jenkinsfile`
5. Click **"Save"**

### Step 5: Configure GitHub Webhook

#### If Jenkins is Publicly Accessible:

1. Go to your GitHub repository
2. Click **"Settings"** → **"Webhooks"** → **"Add webhook"**
3. Configure:
   - **Payload URL**: `http://your-jenkins-url:8090/github-webhook/`
   - **Content type**: `application/json`
   - **Secret**: Leave empty (or add for security)
   - **Which events**: Select "Just the push event"
   - ✅ **Active**: Checked
4. Click **"Add webhook"**

#### If Jenkins is Local (Use ngrok):

```bash
# Install ngrok
brew install ngrok  # macOS
# or download from https://ngrok.com/download

# Start ngrok tunnel
ngrok http 8090

# Copy the HTTPS URL (e.g., https://abc123.ngrok.io)
# Use this URL in GitHub webhook: https://abc123.ngrok.io/github-webhook/
```

### Step 6: Test the Webhook

1. Go to GitHub repository → Settings → Webhooks
2. Click on your webhook
3. Scroll to **"Recent Deliveries"**
4. Click **"Redeliver"** to test
5. Check response is `200 OK`

### Step 7: Test with a Push

```bash
# Make a change
echo "# Test webhook" >> README.md

# Commit and push
git add README.md
git commit -m "Test Jenkins webhook"
git push origin main

# Jenkins should automatically start building!
```

## 🔄 Method 2: Polling (Fallback)

If webhooks don't work, use polling (Jenkins checks GitHub periodically).

### Configure Polling

1. Go to your Jenkins job → **"Configure"**
2. Under **"Build Triggers"**:
   - ✅ Check **"Poll SCM"**
   - **Schedule**: Enter cron expression
3. Click **"Save"**

### Polling Schedule Examples

```bash
# Check every 5 minutes
H/5 * * * *

# Check every 15 minutes
H/15 * * * *

# Check every hour
H * * * *

# Check every 2 hours
H */2 * * *

# Check every day at 2 AM
H 2 * * *
```

### Cron Syntax
```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday=0)
│ │ │ │ │
* * * * *
```

**Note**: `H` means "hash" - Jenkins distributes load by using a hash of the job name.

## 🌿 Multi-Branch Pipeline (Advanced)

For automatic detection of all branches and pull requests:

### Step 1: Create Multi-Branch Pipeline

1. Jenkins Dashboard → **"New Item"**
2. Name: `user-crud-api-multibranch`
3. Type: **"Multibranch Pipeline"**
4. Click **"OK"**

### Step 2: Configure Branch Sources

1. Under **"Branch Sources"**:
   - Click **"Add source"** → **"GitHub"**
   - **Credentials**: Select `github-token`
   - **Repository HTTPS URL**: `https://github.com/lucasalopes28/user-crud-api`
2. Under **"Behaviors"**:
   - ✅ Discover branches
   - ✅ Discover pull requests from origin
   - ✅ Discover pull requests from forks
3. Under **"Build Configuration"**:
   - **Mode**: by Jenkinsfile
   - **Script Path**: `Jenkinsfile`
4. Under **"Scan Multibranch Pipeline Triggers"**:
   - ✅ Check **"Periodically if not otherwise run"**
   - **Interval**: 1 hour (or less)
5. Click **"Save"**

### Step 3: Configure GitHub Webhook for Multi-Branch

Same as Method 1, Step 5, but Jenkins will automatically:
- Detect new branches
- Build pull requests
- Remove jobs for deleted branches

## 🔐 Security Best Practices

### 1. Use GitHub App (Most Secure)

Instead of Personal Access Token:

1. Go to Jenkins → **"Manage Jenkins"** → **"Configure System"**
2. Under **"GitHub"** section:
   - Click **"Add GitHub Server"**
   - Click **"Advanced"**
   - Click **"Manage additional GitHub actions"** → **"Convert login and password to token"**
3. Follow GitHub App setup wizard

### 2. Restrict Webhook IP (If Possible)

In GitHub webhook settings, restrict to Jenkins IP address.

### 3. Use Webhook Secret

1. Generate a secret: `openssl rand -hex 20`
2. Add to GitHub webhook **"Secret"** field
3. Configure in Jenkins job

## 🐛 Troubleshooting

### Webhook Not Triggering

**Check:**
1. Jenkins is accessible from internet
2. Webhook URL is correct: `http://your-jenkins:8090/github-webhook/`
3. GitHub webhook shows `200 OK` in Recent Deliveries
4. Jenkins job has "GitHub hook trigger" enabled
5. Firewall allows incoming connections

**Test:**
```bash
# Test Jenkins webhook endpoint
curl -X POST http://localhost:8090/github-webhook/
```

### Polling Not Working

**Check:**
1. Cron syntax is correct
2. Jenkins has credentials to access GitHub
3. Repository URL is correct
4. Check Jenkins logs: **"Manage Jenkins"** → **"System Log"**

### Authentication Failed

**Check:**
1. Personal Access Token is valid
2. Token has correct scopes (`repo`, `admin:repo_hook`)
3. Credentials are saved in Jenkins
4. Repository URL uses HTTPS (not SSH)

### Build Not Starting

**Check:**
1. Branch name matches configuration
2. Jenkinsfile exists in repository
3. Jenkins has permission to read repository
4. Check Jenkins job console output

## 📊 Monitoring

### View Webhook Deliveries

1. GitHub → Repository → Settings → Webhooks
2. Click on webhook
3. View **"Recent Deliveries"**
4. Check response codes and payloads

### View Jenkins Logs

1. Jenkins → **"Manage Jenkins"** → **"System Log"**
2. Add logger for `org.jenkinsci.plugins.github`
3. Set level to `FINE` or `FINEST`

### Test Webhook Manually

```bash
# Trigger webhook manually
curl -X POST \
  -H "Content-Type: application/json" \
  http://localhost:9090/github-webhook/
```

## ✅ Verification Checklist

After setup, verify:

- [ ] Jenkins plugins installed
- [ ] GitHub Personal Access Token created
- [ ] Credentials added to Jenkins
- [ ] Jenkins job configured with GitHub trigger
- [ ] GitHub webhook created
- [ ] Webhook shows `200 OK` in Recent Deliveries
- [ ] Test push triggers Jenkins build
- [ ] Build completes successfully

## 🎯 Quick Setup Summary

```bash
# 1. Install Jenkins plugins (GitHub Integration, Branch Source)
# 2. Create GitHub Personal Access Token
# 3. Add token to Jenkins credentials
# 4. Configure Jenkins job:
#    - Add Git repository
#    - Enable "GitHub hook trigger for GITScm polling"
# 5. Add webhook to GitHub:
#    - URL: http://your-jenkins:8090/github-webhook/
#    - Content type: application/json
# 6. Test with a push
git commit -m "Test" --allow-empty
git push origin main
# 7. Watch Jenkins automatically build!
```

## 📚 Additional Resources

- [Jenkins GitHub Plugin](https://plugins.jenkins.io/github/)
- [GitHub Webhooks Documentation](https://docs.github.com/en/webhooks)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [ngrok Documentation](https://ngrok.com/docs)

---

**Your Jenkins is now configured to automatically detect GitHub changes!** 🎉
