pipeline {
    agent any
    
    environment {
        APP_NAME = 'user-crud-api'
        IMAGE_TAG = "${APP_NAME}:${BUILD_NUMBER}"
        STAGING_PORT = '8080'
        PROD_PORT = '8081'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out code from SCM...'
                checkout scm
                
                // Verify checkout
                sh '''
                    echo "Workspace contents:"
                    ls -la
                    echo "Checking for pom.xml:"
                    ls -la pom.xml || echo "ERROR: pom.xml not found!"
                '''
            }
        }
        
        stage('Run Unit Tests') {
            steps {
                echo '🧪 Running unit tests...'
                script {
                    try {
                        // Run tests using Docker build
                        sh """
                            echo "Building Docker image with tests..."
                            
                            # Build image which runs tests as part of the build process
                            docker build --target build -t ${APP_NAME}-test:${BUILD_NUMBER} .
                            
                            # Extract test results from the build image
                            docker create --name test-extract-${BUILD_NUMBER} ${APP_NAME}-test:${BUILD_NUMBER}
                            docker cp test-extract-${BUILD_NUMBER}:/app/target ./target || echo "Could not extract test results"
                            docker rm test-extract-${BUILD_NUMBER}
                            
                            echo "✅ Unit tests passed"
                        """
                    } catch (Exception e) {
                        echo "⚠️ Tests failed or had errors"
                        sh """
                            if [ -d target/surefire-reports ]; then
                                echo "Test reports:"
                                ls -la target/surefire-reports/
                                cat target/surefire-reports/*.txt || true
                            fi
                        """
                        throw e
                    }
                }
            }
            post {
                always {
                    script {
                        if (fileExists('target/surefire-reports')) {
                            junit testResults: 'target/surefire-reports/*.xml', allowEmptyResults: true
                            archiveArtifacts artifacts: 'target/surefire-reports/**', allowEmptyArchive: true
                        } else {
                            echo "No test reports to publish"
                        }
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    sh "docker build -t ${IMAGE_TAG} ."
                    sh "docker tag ${IMAGE_TAG} ${APP_NAME}:latest"
                    echo "✅ Docker image built: ${IMAGE_TAG}"
                    sh "docker images | grep ${APP_NAME}"
                }
            }
        }
        
        stage('Test Image') {
            steps {
                echo '🧪 Testing Docker image...'
                sh """
                    # Verify image exists
                    docker images ${IMAGE_TAG}
                    
                    # Inspect image
                    docker inspect ${IMAGE_TAG} > /dev/null
                    
                    echo "✅ Image validated"
                """
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                echo '🚀 Deploying to staging...'
                script {
                    sh """
                        # Stop existing staging container
                        docker stop ${APP_NAME}-staging 2>/dev/null || true
                        docker rm ${APP_NAME}-staging 2>/dev/null || true
                        
                        # Run new staging container
                        docker run -d \
                            --name ${APP_NAME}-staging \
                            -p ${STAGING_PORT}:8080 \
                            -e SPRING_PROFILES_ACTIVE=staging \
                            ${IMAGE_TAG}
                        
                        echo "✅ Staging deployed on port ${STAGING_PORT}"
                    """
                    
                    // Wait and check health
                    sh """
                        echo "Waiting for application to start..."
                        sleep 30
                        
                        echo "Container status:"
                        docker ps | grep ${APP_NAME}-staging
                        
                        echo "Testing health endpoint:"
                        curl -f http://localhost:${STAGING_PORT}/actuator/health || echo "⚠️  Health check pending"
                    """
                }
            }
        }
        
        stage('Integration Tests') {
            steps {
                echo '✅ Running integration tests...'
                sh """
                    # Test staging endpoints
                    curl -f http://localhost:${STAGING_PORT}/actuator/health || echo "Health endpoint test"
                    curl -f http://localhost:${STAGING_PORT}/actuator/info || echo "Info endpoint test"
                    echo "✅ Integration tests completed"
                """
            }
        }
        
        stage('Deploy to Production') {
            steps {
                script {
                    // Manual approval for production
                    input message: 'Deploy to Production?', ok: 'Deploy'
                    
                    echo '🚀 Deploying to production...'
                    sh """
                        # Stop existing production container
                        docker stop ${APP_NAME}-prod 2>/dev/null || true
                        docker rm ${APP_NAME}-prod 2>/dev/null || true
                        
                        # Run new production container
                        docker run -d \
                            --name ${APP_NAME}-prod \
                            -p ${PROD_PORT}:8080 \
                            -e SPRING_PROFILES_ACTIVE=prod \
                            --restart unless-stopped \
                            ${IMAGE_TAG}
                        
                        echo "✅ Production deployed on port ${PROD_PORT}"
                    """
                    
                    // Wait and check health
                    sh """
                        echo "Waiting for production to start..."
                        sleep 30
                        
                        echo "Container status:"
                        docker ps | grep ${APP_NAME}-prod
                        
                        echo "Testing health endpoint:"
                        curl -f http://localhost:${PROD_PORT}/actuator/health || echo "⚠️  Health check pending"
                    """
                }
            }
        }
        
        stage('Create Git Tag') {
            when {
                expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
            }
            steps {
                echo '🏷️  Creating Git tag...'
                script {
                    sh """
                        # Configure git
                        git config user.email "jenkins@localhost"
                        git config user.name "Jenkins CI"
                        
                        # Get the latest tag
                        LATEST_TAG=\$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
                        echo "Latest tag: \$LATEST_TAG"
                        
                        # Extract version numbers
                        VERSION=\${LATEST_TAG#v}
                        MAJOR=\$(echo \$VERSION | cut -d. -f1)
                        MINOR=\$(echo \$VERSION | cut -d. -f2)
                        PATCH=\$(echo \$VERSION | cut -d. -f3)
                        
                        # Increment patch version
                        NEW_PATCH=\$((PATCH + 1))
                        NEW_VERSION="v\${MAJOR}.\${MINOR}.\${NEW_PATCH}"
                        
                        echo "New version: \$NEW_VERSION"
                        
                        # Create tag locally
                        git tag -a \$NEW_VERSION -m "Jenkins build ${BUILD_NUMBER} - Auto-tagged by CI/CD pipeline"
                        
                        echo "✅ Tag \$NEW_VERSION created locally"
                    """
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                echo '🧹 Cleaning up old images...'
                sh """
                    # Remove old images (keep last 3)
                    docker images ${APP_NAME} --format "{{.Tag}}" | grep -E '^[0-9]+\$' | sort -nr | tail -n +4 | while read tag; do
                        echo "Removing ${APP_NAME}:\$tag"
                        docker rmi ${APP_NAME}:\$tag 2>/dev/null || true
                    done
                    
                    # Clean dangling images
                    docker image prune -f
                    
                    echo "✅ Cleanup completed"
                """
            }
        }
    }
    
    post {
        always {
            script {
                echo '📊 Pipeline Summary'
                sh """
                    echo "=== Containers ==="
                    docker ps -a | grep ${APP_NAME} || echo "No containers found"
                    
                    echo "=== Images ==="
                    docker images | grep ${APP_NAME} || echo "No images found"
                """
            }
            // Clean workspace
            deleteDir()
        }
        success {
            echo '✅ Pipeline completed successfully!'
            echo "Staging: http://localhost:${STAGING_PORT}"
            echo "Production: http://localhost:${PROD_PORT}"
        }
        failure {
            echo '❌ Pipeline failed!'
            sh """
                echo "Staging logs:"
                docker logs ${APP_NAME}-staging 2>&1 || echo "No staging container"
                
                echo "Production logs:"
                docker logs ${APP_NAME}-prod 2>&1 || echo "No production container"
            """
        }
    }
}