pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9.0' // Adjust version based on your Jenkins Maven installation
        jdk 'JDK-21'        // Adjust based on your Jenkins JDK installation
    }
    
    environment {
        MAVEN_OPTS = '-Dmaven.test.failure.ignore=true'
        APP_NAME = 'user-crud-api'
        APP_VERSION = '1.0.0'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building the application...'
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'mvn test'
            }
            post {
                always {
                    // Publish test results
                    publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                    
                    // Publish JaCoCo coverage report
                    publishCoverage adapters: [
                        jacocoAdapter('target/site/jacoco/jacoco.xml')
                    ], sourceFileResolver: sourceFiles('STORE_LAST_BUILD')
                }
            }
        }
        
        stage('Package') {
            steps {
                echo 'Packaging the application...'
                sh 'mvn package -DskipTests'
            }
            post {
                success {
                    // Archive the built artifacts
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }
        
        stage('Code Quality Analysis') {
            parallel {
                stage('Static Analysis') {
                    steps {
                        echo 'Running static code analysis...'
                        // Add SonarQube or other static analysis tools here if needed
                        sh 'mvn verify -DskipTests'
                    }
                }
                stage('Security Scan') {
                    steps {
                        echo 'Running security scan...'
                        // Add OWASP dependency check or other security tools here
                        sh 'mvn org.owasp:dependency-check-maven:check || true'
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch 'develop'
                }
            }
            steps {
                script {
                    echo 'Building Docker image...'
                    def image = docker.build("${APP_NAME}:${BUILD_NUMBER}")
                    
                    // Tag with latest if on main/master branch
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                        image.tag('latest')
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch 'develop'
                }
            }
            steps {
                script {
                    echo 'Deploying to staging environment...'
                    
                    // Stop existing container if running
                    sh '''
                        docker stop user-crud-staging || true
                        docker rm user-crud-staging || true
                    '''
                    
                    // Run new container
                    sh """
                        docker run -d \
                            --name user-crud-staging \
                            -p 8080:8080 \
                            -e SPRING_PROFILES_ACTIVE=staging \
                            ${APP_NAME}:${BUILD_NUMBER}
                    """
                    
                    // Health check
                    sh '''
                        echo "Waiting for application to start..."
                        sleep 30
                        curl -f http://localhost:8080/actuator/health || exit 1
                        echo "Application is healthy!"
                    '''
                }
            }
        }
        
        stage('Integration Tests') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch 'develop'
                }
            }
            steps {
                echo 'Running integration tests against staging...'
                sh '''
                    # Add your integration test commands here
                    # Example: newman run postman-collection.json --environment staging.json
                    echo "Integration tests would run here"
                '''
            }
        }
        
        stage('Deploy to Production') {
            when {
                allOf {
                    anyOf {
                        branch 'main'
                        branch 'master'
                    }
                    // Only deploy if all previous stages passed
                    expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
                }
            }
            steps {
                script {
                    // Add manual approval for production deployment
                    input message: 'Deploy to Production?', ok: 'Deploy',
                          submitterParameter: 'DEPLOYER'
                    
                    echo "Deploying to production (approved by ${env.DEPLOYER})..."
                    
                    // Production deployment logic
                    sh '''
                        docker stop user-crud-prod || true
                        docker rm user-crud-prod || true
                    '''
                    
                    sh """
                        docker run -d \
                            --name user-crud-prod \
                            -p 8081:8080 \
                            -e SPRING_PROFILES_ACTIVE=prod \
                            ${APP_NAME}:${BUILD_NUMBER}
                    """
                    
                    // Production health check
                    sh '''
                        echo "Waiting for production application to start..."
                        sleep 30
                        curl -f http://localhost:8081/actuator/health || exit 1
                        echo "Production application is healthy!"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
            // Add notification logic here (email, Slack, etc.)
        }
        failure {
            echo 'Pipeline failed!'
            // Add failure notification logic here
        }
        unstable {
            echo 'Pipeline is unstable!'
            // Add unstable notification logic here
        }
    }
}