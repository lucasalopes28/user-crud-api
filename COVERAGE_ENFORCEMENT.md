# Test Coverage Enforcement

## Overview
This project now enforces a minimum test coverage of **80%** across all CI/CD pipelines.

## Current Coverage
- **Instruction Coverage**: 97%
- **Branch Coverage**: 83%
- **Total Tests**: 28 tests

## Enforcement Mechanisms

### 1. Maven Build (pom.xml)
The JaCoCo Maven plugin is configured to automatically fail the build if coverage falls below 80%:

```xml
<execution>
    <id>jacoco-check</id>
    <phase>test</phase>
    <goals>
        <goal>check</goal>
    </goals>
    <configuration>
        <rules>
            <rule>
                <element>BUNDLE</element>
                <limits>
                    <limit>
                        <counter>INSTRUCTION</counter>
                        <value>COVEREDRATIO</value>
                        <minimum>0.80</minimum>
                    </limit>
                    <limit>
                        <counter>BRANCH</counter>
                        <value>COVEREDRATIO</value>
                        <minimum>0.80</minimum>
                    </limit>
                </limits>
            </rule>
        </rules>
    </configuration>
</execution>
```

**Command**: `mvn clean test`

This will automatically fail if coverage is below 80%.

### 2. Jenkins Pipeline (Jenkinsfile)
The Jenkins pipeline includes:
- Automated test execution with coverage report generation
- Coverage threshold validation (fails if < 80%)
- Coverage artifacts archiving (download from build artifacts)
- Optional HTML report publishing (requires HTML Publisher plugin)

**Key Stage**: `Run Unit Tests`

**Note**: See [JENKINS_COVERAGE_SETUP.md](JENKINS_COVERAGE_SETUP.md) for detailed Jenkins configuration and troubleshooting.

### 3. GitLab CI (.gitlab-ci.yml)
The GitLab CI pipeline includes:
- Unit test execution with coverage reporting
- Automatic coverage threshold check
- Coverage badge support via regex: `/Code Coverage: ([0-9]{1,3})%/`
- JaCoCo report artifacts

**Key Job**: `unit-tests`

### 4. GitHub Actions (.github/workflows/ci-cd.yml)
The GitHub Actions workflow includes:
- Test execution with coverage validation
- Coverage threshold enforcement (fails if < 80%)
- PR comments with coverage status
- Codecov integration
- Coverage artifacts upload

**Key Job**: `test`

## How It Works

### Build-Time Enforcement
When you run `mvn clean test`, the JaCoCo plugin will:
1. Execute all unit tests
2. Generate coverage report
3. Check coverage against 80% threshold
4. **FAIL the build** if coverage is below 80%

Example failure output:
```
[WARNING] Rule violated for bundle user-crud-api: instructions covered ratio is 0.53, but expected minimum is 0.80
[WARNING] Rule violated for bundle user-crud-api: branches covered ratio is 0.00, but expected minimum is 0.80
[INFO] BUILD FAILURE
```

### CI/CD Pipeline Enforcement
All three CI/CD systems (Jenkins, GitLab, GitHub Actions) will:
1. Run tests with coverage
2. Parse the coverage percentage from the JaCoCo HTML report
3. Compare against 80% threshold
4. Fail the pipeline if coverage is insufficient

## Viewing Coverage Reports

### Local Development
After running tests, open the coverage report:
```bash
mvn clean test jacoco:report
open target/site/jacoco/index.html
```

### CI/CD Pipelines
- **Jenkins**: Coverage report available in build artifacts under "JaCoCo Coverage Report"
- **GitLab**: Coverage report in job artifacts, coverage badge in merge requests
- **GitHub Actions**: Coverage uploaded to Codecov, artifacts available in workflow runs

## Test Structure

### Current Test Files
1. **UserControllerTest** (9 tests)
   - CRUD operations testing
   - Error handling scenarios
   - HTTP status validation

2. **UserServiceTest** (9 tests)
   - Business logic validation
   - Exception handling
   - Repository interaction testing

3. **UserTest** (9 tests)
   - Entity validation
   - Lifecycle callbacks
   - Field constraints

4. **UserCrudApplicationTest** (1 test)
   - Application context loading

## Maintaining Coverage

To maintain coverage above 80%:

1. **Write tests for new features** before merging
2. **Run tests locally** before pushing: `mvn clean test`
3. **Check coverage reports** to identify untested code
4. **Add tests for edge cases** and error scenarios
5. **Review CI/CD failures** and add missing tests

## Troubleshooting

### Build fails with coverage error
```bash
# Check current coverage
mvn clean test jacoco:report
open target/site/jacoco/index.html

# Identify uncovered code
# Add tests for uncovered methods/branches
# Re-run tests
mvn clean test
```

### CI/CD pipeline fails on coverage check
1. Check the pipeline logs for coverage percentage
2. Review the JaCoCo report artifacts
3. Add tests to cover missing code paths
4. Push changes and re-run pipeline

## Benefits

✅ **Quality Assurance**: Ensures code is properly tested before deployment
✅ **Regression Prevention**: Catches untested code changes early
✅ **Documentation**: Tests serve as living documentation
✅ **Confidence**: Higher coverage means more confidence in deployments
✅ **Consistency**: Same standards across all environments
