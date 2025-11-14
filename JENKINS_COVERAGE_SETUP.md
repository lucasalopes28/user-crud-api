# Jenkins Coverage Setup

## Overview
The Jenkins pipeline is configured to enforce 80% test coverage. The coverage reports are archived as build artifacts.

## Current Configuration

### Coverage Enforcement
The pipeline automatically:
1. Runs tests with JaCoCo coverage
2. Extracts coverage percentage from the report
3. **Fails the build** if coverage is below 80%
4. Archives coverage reports as artifacts

### Viewing Coverage Reports

#### Option 1: Download Artifacts (Default)
1. Go to the build page in Jenkins
2. Click on "Build Artifacts"
3. Navigate to `target/site/jacoco/`
4. Download `index.html` and open it locally

#### Option 2: Install HTML Publisher Plugin (Optional)
For a better experience with inline HTML reports in Jenkins:

1. **Install the plugin**:
   - Go to Jenkins → Manage Jenkins → Manage Plugins
   - Click on "Available" tab
   - Search for "HTML Publisher"
   - Install the plugin and restart Jenkins

2. **Update Jenkinsfile** (optional enhancement):
   Replace the coverage archiving section with:
   ```groovy
   // Publish JaCoCo coverage report (requires HTML Publisher plugin)
   if (fileExists('target/site/jacoco')) {
       publishHTML([
           allowMissing: false,
           alwaysLinkToLastBuild: true,
           keepAll: true,
           reportDir: 'target/site/jacoco',
           reportFiles: 'index.html',
           reportName: 'JaCoCo Coverage Report'
       ])
       archiveArtifacts artifacts: 'target/site/jacoco/**', allowEmptyArchive: true
   }
   ```

3. **Benefits**:
   - View coverage reports directly in Jenkins UI
   - Click "JaCoCo Coverage Report" link in build sidebar
   - No need to download artifacts

## Coverage Threshold Check

The pipeline includes a shell script that:
- Parses the JaCoCo HTML report
- Extracts the total coverage percentage
- Compares against 80% threshold
- Exits with error code 1 if below threshold

### Example Output

**Success (Coverage ≥ 80%)**:
```
📊 Code Coverage: 97%
✅ Coverage 97% meets the 80% threshold
```

**Failure (Coverage < 80%)**:
```
📊 Code Coverage: 67%
❌ Coverage 67% is below the required 80% threshold
[ERROR] Build failed due to insufficient test coverage
```

## Troubleshooting

### Coverage check fails but tests pass
This means your tests are passing but don't cover enough code. To fix:

1. **Check the coverage report**:
   - Download artifacts from the failed build
   - Open `target/site/jacoco/index.html`
   - Identify uncovered classes/methods

2. **Add missing tests**:
   - Focus on red/yellow highlighted code
   - Add tests for uncovered branches
   - Test error handling paths

3. **Re-run the build**:
   ```bash
   # Test locally first
   mvn clean test
   # Push changes
   git add .
   git commit -m "Add tests to improve coverage"
   git push
   ```

### Coverage report not generated
If you see "⚠️ Coverage report not found":

1. Check that tests are running successfully
2. Verify JaCoCo plugin is configured in `pom.xml`
3. Check build logs for Maven errors
4. Ensure Docker build includes test execution

### Script fails with "grep: invalid option"
The current script uses POSIX-compatible commands that work on both Linux and macOS. If you encounter issues:

```bash
# Alternative coverage extraction (Linux with GNU grep)
COVERAGE=$(grep -oP '<tfoot>.*?</tfoot>' target/site/jacoco/index.html | grep -oP '\d+%' | head -1 | tr -d '%')

# Current portable version (works on macOS and Linux)
COVERAGE=$(sed -n '/<tfoot>/,/<\/tfoot>/p' target/site/jacoco/index.html | grep -o '[0-9]\+%' | head -1 | tr -d '%')
```

## Integration with Other Tools

### JaCoCo Maven Plugin
The coverage check in Jenkins complements the Maven plugin check:
- **Maven check**: Fails during `mvn test` phase
- **Jenkins check**: Additional validation with clear reporting

Both checks use the same 80% threshold.

### Docker Build
The Jenkinsfile extracts test results from the Docker build:
```groovy
docker build --target build -t ${APP_NAME}-test:${BUILD_NUMBER} .
docker cp test-extract-${BUILD_NUMBER}:/app/target ./target
```

This ensures tests run in the same environment as production.

## Best Practices

1. **Run tests locally** before pushing:
   ```bash
   mvn clean test
   ```

2. **Check coverage locally**:
   ```bash
   mvn clean test jacoco:report
   open target/site/jacoco/index.html
   ```

3. **Monitor coverage trends**:
   - Keep coverage above 80%
   - Aim for 90%+ on critical code
   - Review coverage in code reviews

4. **Archive reports**:
   - Coverage reports are kept with build artifacts
   - Useful for debugging failed builds
   - Track coverage history

## Additional Resources

- [JaCoCo Documentation](https://www.jacoco.org/jacoco/trunk/doc/)
- [Jenkins HTML Publisher Plugin](https://plugins.jenkins.io/htmlpublisher/)
- [Maven Surefire Plugin](https://maven.apache.org/surefire/maven-surefire-plugin/)
