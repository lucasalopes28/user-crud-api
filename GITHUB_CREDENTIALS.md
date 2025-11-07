# GitHub Credentials Setup for Jenkins

This guide explains how to configure Jenkins to push Git tags to your GitHub repository.

## 🔑 Option 1: Using GitHub Personal Access Token (Recommended)

### Step 1: Create GitHub Personal Access Token

1. Go to GitHub: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Give it a name: `Jenkins CI/CD`
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
5. Click **"Generate token"**
6. **Copy the token** (you won't see it again!)

### Step 2: Add Credentials to Jenkins

1. Open Jenkins: http://localhost:8090
2. Go to **Manage Jenkins** → **Manage Credentials**
3. Click **(global)** → **Add Credentials**
4. Configure:
   - **Kind:** Username with password
   - **Username:** Your GitHub username
   - **Password:** Paste your Personal Access Token
   - **ID:** `github-credentials`
   - **Description:** GitHub Personal Access Token
5. Click **Save**

### Step 3: Update Jenkinsfile to Push Tags

Add this to your Jenkinsfile after creating the tag:

```groovy
stage('Push Git Tag to GitHub') {
    when {
        expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
    }
    steps {
        echo 'Pushing tag to GitHub...'
        script {
            withCredentials([usernamePassword(
                credentialsId: 'github-credentials',
                usernameVariable: 'GIT_USERNAME',
                passwordVariable: 'GIT_PASSWORD'
            )]) {
                sh """
                    # Get the new tag
                    NEW_TAG=\$(git describe --tags --abbrev=0)
                    
                    # Push tag to GitHub
                    git push https://\${GIT_USERNAME}:\${GIT_PASSWORD}@github.com/lucasalopes28/user-crud-api.git \$NEW_TAG
                    
                    echo "✅ Tag \$NEW_TAG pushed to GitHub"
                """
            }
        }
    }
}
```

## 🔑 Option 2: Using SSH Keys

### Step 1: Generate SSH Key in Jenkins

```bash
# Access Jenkins container
docker exec -it jenkins-server bash

# Generate SSH key
ssh-keygen -t ed25519 -C "jenkins@localhost" -f /var/jenkins_home/.ssh/id_ed25519 -N ""

# Display public key
cat /var/jenkins_home/.ssh/id_ed25519.pub
```

### Step 2: Add SSH Key to GitHub

1. Copy the public key from above
2. Go to GitHub: https://github.com/settings/keys
3. Click **"New SSH key"**
4. Title: `Jenkins CI/CD`
5. Paste the public key
6. Click **"Add SSH key"**

### Step 3: Update Jenkinsfile for SSH

```groovy
stage('Push Git Tag to GitHub') {
    steps {
        echo 'Pushing tag to GitHub...'
        script {
            sh """
                # Get the new tag
                NEW_TAG=\$(git describe --tags --abbrev=0)
                
                # Push tag using SSH
                git push git@github.com:lucasalopes28/user-crud-api.git \$NEW_TAG
                
                echo "✅ Tag \$NEW_TAG pushed to GitHub"
            """
        }
    }
}
```

## 📋 Complete Stage Example

Here's a complete stage that creates and pushes tags:

```groovy
stage('Version & Tag') {
    when {
        expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
    }
    steps {
        echo 'Creating and pushing Git tag...'
        script {
            // Configure git
            sh """
                git config user.email "jenkins@localhost"
                git config user.name "Jenkins CI"
            """
            
            // Get latest tag and increment
            def latestTag = sh(
                script: "git describe --tags --abbrev=0 2>/dev/null || echo 'v0.0.0'",
                returnStdout: true
            ).trim()
            
            def version = latestTag.replaceFirst('v', '')
            def parts = version.split('\\.')
            def newPatch = (parts[2] as Integer) + 1
            def newVersion = "v${parts[0]}.${parts[1]}.${newPatch}"
            
            echo "Latest tag: ${latestTag}"
            echo "New version: ${newVersion}"
            
            // Create tag
            sh "git tag -a ${newVersion} -m 'Jenkins build ${BUILD_NUMBER}'"
            
            // Push to GitHub with credentials
            withCredentials([usernamePassword(
                credentialsId: 'github-credentials',
                usernameVariable: 'GIT_USERNAME',
                passwordVariable: 'GIT_PASSWORD'
            )]) {
                sh """
                    git push https://\${GIT_USERNAME}:\${GIT_PASSWORD}@github.com/lucasalopes28/user-crud-api.git ${newVersion}
                """
            }
            
            echo "✅ Tag ${newVersion} created and pushed to GitHub"
        }
    }
}
```

## 🧪 Testing

After setup, run your pipeline and check:

1. **Jenkins Console Output** - Should show tag creation
2. **GitHub Repository** - Go to https://github.com/lucasalopes28/user-crud-api/tags
3. **Verify Tags** - You should see new tags like `v0.0.1`, `v0.0.2`, etc.

## 🔍 Troubleshooting

### Authentication Failed
```bash
# Verify credentials in Jenkins
# Make sure Personal Access Token has correct permissions
```

### Permission Denied (SSH)
```bash
# Test SSH connection
docker exec jenkins-server ssh -T git@github.com
```

### Tag Already Exists
```bash
# Delete tag locally and remotely if needed
git tag -d v0.0.1
git push origin :refs/tags/v0.0.1
```

## 📚 Version Scheme

The pipeline uses **Semantic Versioning** (SemVer):
- **v0.0.1** - Initial version
- **v0.0.2** - Patch increment (automatic)
- **v0.1.0** - Minor increment (manual)
- **v1.0.0** - Major increment (manual)

To manually set a version:
```bash
git tag -a v1.0.0 -m "Major release"
git push origin v1.0.0
```

The pipeline will then continue from v1.0.0 → v1.0.1 → v1.0.2...