# Jenkins UI Guide - Viewing Pipeline Steps

## Why Steps Might Not Be Visible

If you're not seeing detailed steps in the Jenkins UI, it could be due to:

1. **Using Classic Jenkins UI** - The classic UI shows less detail than Blue Ocean
2. **Script blocks** - Steps wrapped in `script {}` blocks are less visible
3. **Missing Blue Ocean plugin** - Blue Ocean provides the best visualization

## Recommended: Install Blue Ocean

Blue Ocean provides a modern, visual interface for Jenkins pipelines with excellent step visibility.

### Installation Steps

1. **Install Blue Ocean Plugin**:
   ```
   Jenkins → Manage Jenkins → Manage Plugins → Available
   Search for "Blue Ocean"
   Install and restart Jenkins
   ```

2. **Access Blue Ocean**:
   - Click "Open Blue Ocean" in the left sidebar
   - Or navigate to: `http://your-jenkins-url/blue`

3. **View Pipeline**:
   - Select your pipeline
   - Click on a build number
   - You'll see a visual representation of all stages and steps

### Blue Ocean Features

✅ **Visual Pipeline View**: See all stages in a horizontal flow
✅ **Step Details**: Click any stage to see individual steps
✅ **Real-time Logs**: Watch logs as they stream
✅ **Error Highlighting**: Failed steps are clearly marked
✅ **Parallel Stages**: Visual representation of parallel execution
✅ **Artifacts**: Easy access to build artifacts

## Alternative: Classic UI with Stage View

If you prefer the classic UI, install the Pipeline Stage View plugin:

1. **Install Plugin**:
   ```
   Jenkins → Manage Jenkins → Manage Plugins → Available
   Search for "Pipeline: Stage View"
   Install and restart
   ```

2. **View Stages**:
   - Go to your pipeline job
   - You'll see a stage view showing each stage's status
   - Click on stage names to see logs

## Current Pipeline Stages

Your pipeline has these stages (in order):

1. **Checkout** - Clone code from SCM
2. **Run Unit Tests** - Execute tests with coverage check
3. **Build Docker Image** - Build application container
4. **Test Image** - Validate Docker image
5. **Deploy to Staging** - Deploy to staging environment
6. **Integration Tests** - Run integration tests
7. **Deploy to Production** - Deploy to production (manual approval)
8. **Create Git Tag** - Tag successful builds
9. **Cleanup** - Clean up old Docker images

## Viewing Step Details

### In Blue Ocean:
1. Click on any stage
2. See all steps with their output
3. Steps are shown with their echo messages:
   - "Building Docker image with tests..."
   - "Extracting test results from Docker image..."
   - "Publishing test results..."
   - "Checking coverage threshold..."

### In Classic UI:
1. Click "Console Output" to see full logs
2. Look for stage markers like:
   ```
   [Pipeline] stage (Run Unit Tests)
   [Pipeline] { (Run Unit Tests)
   [Pipeline] echo
   🧪 Running unit tests with coverage check...
   ```

## Improved Step Visibility

The Jenkinsfile has been updated to:

✅ **Explicit echo statements** - Each major action has a descriptive echo
✅ **Separated commands** - Long shell scripts split into smaller steps
✅ **Clear stage names** - Descriptive stage names with emojis
✅ **Better error handling** - Clear error messages when steps fail

### Example: Run Unit Tests Stage

The stage now shows these steps clearly:
```
🧪 Running unit tests with coverage check...
Building Docker image with tests...
Extracting test results from Docker image...
✅ Unit tests passed
Publishing test results...
📊 Archiving JaCoCo coverage report...
Checking coverage threshold...
📊 Code Coverage: 97%
✅ Coverage 97% meets the 80% threshold
```

## Troubleshooting

### Steps still not visible?

1. **Check Jenkins version**:
   - Go to Jenkins → Manage Jenkins → System Information
   - Recommended: Jenkins 2.300+

2. **Check installed plugins**:
   - Pipeline plugin (required)
   - Pipeline: Stage View (recommended)
   - Blue Ocean (highly recommended)

3. **Check browser console**:
   - Open browser developer tools (F12)
   - Look for JavaScript errors
   - Try a different browser

4. **Restart Jenkins**:
   ```bash
   # If running in Docker
   docker restart jenkins
   
   # Or from Jenkins UI
   Jenkins → Manage Jenkins → Reload Configuration from Disk
   ```

### Console output is cluttered?

Use the "Pipeline Steps" view:
1. Click on build number
2. Click "Pipeline Steps" in the left sidebar
3. See a tree view of all steps

## Best Practices

1. **Use Blue Ocean** for the best experience
2. **Add descriptive echo statements** before major operations
3. **Keep stages focused** - One main purpose per stage
4. **Use meaningful stage names** - Clear and descriptive
5. **Check logs regularly** - Monitor for warnings or issues

## Additional Resources

- [Blue Ocean Documentation](https://www.jenkins.io/doc/book/blueocean/)
- [Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Pipeline Steps Reference](https://www.jenkins.io/doc/pipeline/steps/)
- [Stage View Plugin](https://plugins.jenkins.io/pipeline-stage-view/)
