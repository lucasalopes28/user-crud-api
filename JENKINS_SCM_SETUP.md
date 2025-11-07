# Jenkins SCM Configuration Guide

This guide shows how to configure Jenkins to automatically fetch the Jenkinsfile from your GitHub repository.

## 🎯 Benefits of Using SCM

- ✅ **Version Control** - Jenkinsfile is versioned with your code
- ✅ **Automatic Updates** - Pipeline changes automatically when you push to GitHub
- ✅ **No Manual Copying** - Jenkins fetches the latest Jenkinsfile automatically
- ✅ **Team Collaboration** - Everyone uses the same pipeline definition

## 📋 Step-by-Step Configuration

### Step 1: Push Jenkinsfile to GitHub

First, make sure your Jenkinsfile is in your GitHub repository:

```bash
# Add the updated Jenkinsfile
git add Jenkinsfile

# Commit the changes
git commit -m "Add Jenkins pipeline configuration"

# Push to GitHub
git push origin main
```

### Step 2: Configure Jenkins Job

1. **Open Jenkins** at http://localhost:8090

2. **Create New Pipeline Job:**
   - Click **"New Item"**
   - Enter name: `user-crud-api-scm`
   - Select **"Pipeline"**
   - Click **OK**

3. **Configure Pipeline:**
   
   **General Section:**
   - Description: `User CRUD API - Pipeline from SCM`
   - ☑️ Check **"GitHub project"**
   - Project URL: `https://github.com/lucasalopes28/user-crud-api`

   **Build Triggers (Optional):**
   - ☑️ **"GitHub hook trigger for GITScm polling"** (for automatic builds on push)
   - OR ☑️ **"Poll SCM"** with schedule: `H/5 * * * *` (check every 5 minutes)

   **Pipeline Section:**
   - Definition: **"Pipeline script from SCM"**
   - SCM: **"Git"**
   - Repository URL: `https://github.com/lucasalopes28/user-crud-api`
   - Credentials: *(leave empty for public repos)*
   - Branch Specifier: `*/main` (or `*/master` if that's your default branch)
   - Script Path: `Jenkinsfile`
   - ☑️ **"Lightweight checkout"** (recommended)

4. **Save** the configuration

### Step 3: Test the Pipeline

1. Click **"Build Now"**
2. Watch the build progress
3. Jenkins will:
   - Clone your repository
   - Find the Jenkinsfile
   - Execute the pipeline

## 🔄 Automatic Builds on Git Push

To trigger builds automatically when you push to GitHub:

### Option 1: GitHub Webhook (Recommended)

1. **In GitHub:**
   - Go to your repository
   - Settings → Webhooks → Add webhook
   - Payload URL: `http://your-jenkins-url:8090/github-webhook/`
   - Content type: `application/json`
   - Events: **"Just the push event"**
   - Click **Add webhook**

2. **In Jenkins:**
   - Job Configuration → Build Triggers
   - ☑️ **"GitHub hook trigger for GITScm polling"**

### Option 2: SCM Polling

If webhooks aren't available:

1. **In Jenkins:**
   - Job Configuration → Build Triggers
   - ☑️ **"Poll SCM"**
   - Schedule: `H/5 * * * *` (every 5 minutes)

## 📝 Jenkinsfile vs Jenkinsfile.standalone

| Feature | Jenkinsfile (SCM) | Jenkinsfile.standalone |
|---------|-------------------|------------------------|
| Location | GitHub repository | Paste in Jenkins UI |
| Updates | Automatic | Manual |
| Version Control | Yes | No |
| Team Collaboration | Easy | Difficult |
| Setup | Requires Git config | Simple paste |
| **Recommended** | ✅ **Yes** | For testing only |

## 🔧 Troubleshooting

### Issue: "Couldn't find any revision to build"

**Solution:**
- Check branch name (main vs master)
- Verify repository URL is correct
- Ensure repository is accessible

### Issue: "Script not found: Jenkinsfile"

**Solution:**
- Verify Jenkinsfile exists in repository root
- Check Script Path in Jenkins configuration
- Ensure file is named exactly `Jenkinsfile` (case-sensitive)

### Issue: Git credentials required

**Solution:**
For private repositories:
1. Jenkins → Manage Jenkins → Manage Credentials
2. Add GitHub credentials (username + Personal Access Token)
3. Select credentials in Pipeline configuration

### Issue: Pipeline fails at checkout

**Solution:**
```bash
# Verify Git is installed in Jenkins
docker exec jenkins-server git --version

# Check Jenkins can access GitHub
docker exec jenkins-server git ls-remote https://github.com/lucasalopes28/user-crud-api.git
```

## 📊 Comparing Configurations

### Current Setup (Jenkinsfile.standalone)
```
Jenkins Job → Pipeline Script → Paste entire Jenkinsfile
```

### New Setup (SCM)
```
Jenkins Job → Pipeline from SCM → GitHub → Jenkinsfile
```

## 🎯 Migration Steps

If you're currently using Jenkinsfile.standalone:

1. **Backup current job:**
   - Export job configuration
   - Save Jenkinsfile.standalone content

2. **Create new SCM job:**
   - Follow Step 2 above
   - Test with a build

3. **Verify it works:**
   - Check all stages execute
   - Verify deployments work

4. **Delete old job:**
   - Once confirmed working
   - Keep Jenkinsfile.standalone as backup

## ✅ Verification Checklist

After configuration:

- [ ] Jenkinsfile exists in GitHub repository
- [ ] Jenkins job configured with SCM
- [ ] Repository URL is correct
- [ ] Branch name is correct (main/master)
- [ ] Script Path is `Jenkinsfile`
- [ ] Build runs successfully
- [ ] All stages execute
- [ ] Deployments work

## 🚀 Next Steps

Once SCM is working:

1. **Enable automatic builds** (webhook or polling)
2. **Add branch protection** in GitHub
3. **Configure notifications** (email, Slack)
4. **Set up multi-branch pipeline** (for feature branches)

## 📚 Additional Resources

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [GitHub Webhooks Guide](https://docs.github.com/en/webhooks)
- [Jenkins SCM Configuration](https://www.jenkins.io/doc/book/pipeline/getting-started/#defining-a-pipeline-in-scm)

---

**Ready to use SCM!** Follow the steps above to configure Jenkins to automatically fetch your Jenkinsfile from GitHub. 🎉