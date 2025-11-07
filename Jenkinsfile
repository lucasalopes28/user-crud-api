pipeline {
    agent any
    
    environment {
        // Docker and application settings
        APP_NAME = 'user-crud-api'
        APP_VERSION = '1.0.0'
        DOCKER_REGISTRY = 'localhost:5000' // Change to your registry if needed
        IMAGE_TAG = "${APP_NAME}:${BUILD_NUMBER}"
        IMAGE_LATEST = "${APP_NAME}:latest"
        
        // Container settings
        STAGING_CONTAINER = 'user-crud-staging'
        STAGING_PORT = '8080'
        PROD_CONTAINER = 'user-crud-prod'
        PROD_PORT = '8081'
        
        // Docker network for containers
        DOCKER_NETWORK = 'user-crud-network'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Setup Docker Environment') {
            steps {
                echo 'Setting up Docker environment...'
                script {
                    // Create Docker network if it doesn't exist
                    sh """
                        docker network ls | grep ${DOCKER_NETWORK} || docker network create ${DOCKER_NETWORK}
                    """
                    
                    // Clean up any existing test containers
                    sh '''
                        docker stop user-crud-test || true
                        docker rm user-crud-test || true
                    '''
                }
            }
        }
        
        stage('Build & Test in Docker') {
            steps {
                echo 'Building and testing application in Docker...'
                script {
                    // Build the Docker image (this includes Maven build and test)
                    def testImage = docker.build("${APP_NAME}-test:${BUILD_NUMBER}", "--target build .")
                    
                    // Run tests inside Docker container
                    testImage.inside("--name user-crud-test-${BUILD_NUMBER}") {
                        sh '''
                            echo "Running tests inside Docker container..."
                            mvn test
                        '''
                    }
                    
                    // Copy test results from container to Jenkins workspace
                    sh """
                        docker cp user-crud-test-${BUILD_NUMBER}:/app/target/surefire-reports ./target/ || true
                        docker cp user-crud-test-${BUILD_NUMBER}:/app/target/site ./target/ || true
                    """
                }
            }
            post {
                always {
                    // Publish test results
                    script {
                        if (fileExists('target/surefire-reports/*.xml')) {
                            junit testResults: 'target/surefire-reports/*.xml', allowEmptyResults: true
                        }
                        
                        // Archive JaCoCo coverage report
                        if (fileExists('target/site/jacoco/index.html')) {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'target/site/jacoco',
                                reportFiles: 'index.html',
                                reportName: 'JaCoCo Coverage Report'
                            ])
                        }
                    }
                    
                    // Clean up test container
                    sh "docker rm user-crud-test-${BUILD_NUMBER} || true"
                }
            }
        }
        
        stage('Build Production Docker Image') {
            steps {
                script {
                    echo 'Building production Docker image...'
                    
                    // Build the full production image
                    def image = docker.build("${IMAGE_TAG}")
                    
                    // Tag with latest
                    image.tag('latest')
                    
                    // Tag with version
                    image.tag("${APP_VERSION}")
                    
                    // Tag with branch name if available
                    if (env.BRANCH_NAME) {
                        image.tag("${env.BRANCH_NAME}-${BUILD_NUMBER}")
                    }
                    
                    echo "Docker image built successfully: ${IMAGE_TAG}"
                    
                    // Display image info
                    sh "docker images | grep ${APP_NAME}"
                }
            }
        }
        
        stage('Scan Docker Image') {
            steps {
                script {
                    echo 'Scanning Docker image for vulnerabilities...'
                    
                    // Basic image inspection
                    sh """
                        echo "Image size and layers:"
                        docker history ${IMAGE_TAG}
                        
                        echo "Image details:"
                        docker inspect ${IMAGE_TAG}
                    """
                    
                    // Optional: Add Trivy or other security scanning tools here
                    sh """
                        if command -v trivy &> /dev/null; then
                            echo "Running Trivy security scan..."
                            trivy image ${IMAGE_TAG}
                        else
                            echo "Trivy not installed, skipping security scan"
                        fi
                    """
                }
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                script {
                    echo 'Deploying to staging environment in Docker...'
                    
                    // Stop and remove existing staging container
                    sh """
                        docker stop ${STAGING_CONTAINER} 2>/dev/null || true
                        docker rm ${STAGING_CONTAINER} 2>/dev/null || true
                    """
                    
                    // Run new staging container
                    sh """
                        docker run -d \
                            --name ${STAGING_CONTAINER} \
                            --network ${DOCKER_NETWORK} \
                            -p ${STAGING_PORT}:8080 \
                            -e SPRING_PROFILES_ACTIVE=staging \
                            -e JAVA_OPTS="-Xmx512m -Xms256m" \
                            --restart unless-stopped \
                            --health-cmd="curl -f http://localhost:8080/actuator/health || exit 1" \
                            --health-interval=30s \
                            --health-timeout=3s \
                            --health-retries=3 \
                            ${IMAGE_TAG}
                    """
                    
                    echo "Staging container started: ${STAGING_CONTAINER}"
                    
                    // Wait for container to be healthy
                    sh """
                        echo "Waiting for staging application to be healthy..."
                        for i in {1..30}; do
                            if docker inspect --format='{{.State.Health.Status}}' ${STAGING_CONTAINER} 2>/dev/null | grep -q "healthy"; then
                                echo "Container is healthy!"
                                break
                            fi
                            echo "Waiting... (\$i/30)"
                            sleep 2
                        done
                        
                        # Show container status
                        docker ps -a | grep ${STAGING_CONTAINER}
                        
                        # Show container logs
                        echo "Container logs:"
                        docker logs --tail 50 ${STAGING_CONTAINER}
                    """
                    
                    // Test the endpoint
                    sh """
                        echo "Testing staging endpoint..."
                        curl -f http://localhost:${STAGING_PORT}/actuator/health || {
                            echo "Health check failed!"
                            docker logs ${STAGING_CONTAINER}
                            exit 1
                        }
                        echo "Staging deployment successful!"
                    """
                }
            }
        }
        
        stage('Integration Tests') {
            steps {
                script {
                    echo 'Running integration tests against staging container...'
                    
                    // Run integration tests in a separate container
                    sh """
                        docker run --rm \
                            --network ${DOCKER_NETWORK} \
                            --name integration-tests-${BUILD_NUMBER} \
                            curlimages/curl:latest \
                            sh -c '
                                echo "Running integration tests..."
                                
                                # Test health endpoint
                                curl -f http://${STAGING_CONTAINER}:8080/actuator/health
                                
                                # Test info endpoint
                                curl -f http://${STAGING_CONTAINER}:8080/actuator/info || echo "Info endpoint not available"
                                
                                # Add more API tests here
                                echo "Integration tests completed successfully!"
                            '
                    """
                    
                    // Optional: Run more comprehensive tests with Newman/Postman
                    sh '''
                        if command -v newman &> /dev/null; then
                            echo "Running Newman/Postman tests..."
                            # newman run postman-collection.json --environment staging.json
                            echo "Newman tests would run here"
                        else
                            echo "Newman not installed, skipping Postman tests"
                        fi
                    '''
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                allOf {
                    anyOf {
                        branch 'main'
                        branch 'master'
                    }
                    expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
                }
            }
            steps {
                script {
                    // Manual approval for production deployment
                    input message: 'Deploy to Production?', ok: 'Deploy',
                          submitterParameter: 'DEPLOYER'
                    
                    echo "Deploying to production (approved by ${env.DEPLOYER})..."
                    
                    // Blue-Green deployment approach
                    def newProdContainer = "${PROD_CONTAINER}-new"
                    
                    try {
                        // Start new production container
                        sh """
                            docker run -d \
                                --name ${newProdContainer} \
                                --network ${DOCKER_NETWORK} \
                                -p ${PROD_PORT}:8080 \
                                -e SPRING_PROFILES_ACTIVE=prod \
                                -e JAVA_OPTS="-Xmx1g -Xms512m" \
                                --restart unless-stopped \
                                --health-cmd="curl -f http://localhost:8080/actuator/health || exit 1" \
                                --health-interval=30s \
                                --health-timeout=3s \
                                --health-retries=3 \
                                ${IMAGE_TAG}
                        """
                        
                        // Wait for new container to be healthy
                        sh """
                            echo "Waiting for new production container to be healthy..."
                            for i in {1..60}; do
                                if docker inspect --format='{{.State.Health.Status}}' ${newProdContainer} 2>/dev/null | grep -q "healthy"; then
                                    echo "New production container is healthy!"
                                    break
                                fi
                                echo "Waiting... (\$i/60)"
                                sleep 2
                            done
                        """
                        
                        // Test the new production container
                        sh """
                            curl -f http://localhost:${PROD_PORT}/actuator/health || {
                                echo "Production health check failed!"
                                docker logs ${newProdContainer}
                                exit 1
                            }
                        """
                        
                        // If everything is good, switch containers
                        sh """
                            # Stop old production container
                            docker stop ${PROD_CONTAINER} 2>/dev/null || true
                            docker rm ${PROD_CONTAINER} 2>/dev/null || true
                            
                            # Rename new container to production
                            docker rename ${newProdContainer} ${PROD_CONTAINER}
                            
                            echo "Production deployment completed successfully!"
                            docker ps | grep ${PROD_CONTAINER}
                        """
                        
                    } catch (Exception e) {
                        echo "Production deployment failed: ${e.getMessage()}"
                        
                        // Cleanup failed deployment
                        sh """
                            docker stop ${newProdContainer} 2>/dev/null || true
                            docker rm ${newProdContainer} 2>/dev/null || true
                        """
                        
                        throw e
                    }
                }
            }
        }
        
        stage('Cleanup Old Images') {
            steps {
                script {
                    echo 'Cleaning up old Docker images...'
                    
                    // Keep only the last 5 builds
                    sh """
                        # Remove old images (keep last 5)
                        docker images ${APP_NAME} --format "table {{.Tag}}" | grep -E '^[0-9]+\$' | sort -nr | tail -n +6 | while read tag; do
                            echo "Removing old image: ${APP_NAME}:\$tag"
                            docker rmi ${APP_NAME}:\$tag || true
                        done
                        
                        # Clean up dangling images
                        docker image prune -f
                        
                        echo "Remaining images:"
                        docker images | grep ${APP_NAME}
                    """
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo 'Pipeline cleanup...'
                
                // Show final container status
                sh """
                    echo "Final container status:"
                    docker ps -a | grep user-crud || echo "No user-crud containers found"
                    
                    echo "Docker images:"
                    docker images | grep ${APP_NAME} || echo "No ${APP_NAME} images found"
                    
                    echo "Docker network:"
                    docker network ls | grep ${DOCKER_NETWORK} || echo "Network ${DOCKER_NETWORK} not found"
                """
                
                // Archive container logs
                sh """
                    mkdir -p logs
                    docker logs ${STAGING_CONTAINER} > logs/staging.log 2>&1 || echo "No staging logs"
                    docker logs ${PROD_CONTAINER} > logs/production.log 2>&1 || echo "No production logs"
                """
                
                // Archive logs
                archiveArtifacts artifacts: 'logs/*.log', allowEmptyArchive: true
            }
            
            cleanWs()
        }
        success {
            echo 'Docker pipeline completed successfully!'
            script {
                sh """
                    echo "Deployment Summary:"
                    echo "- Image: ${IMAGE_TAG}"
                    echo "- Staging: http://localhost:${STAGING_PORT}"
                    echo "- Production: http://localhost:${PROD_PORT}"
                    echo "- Build: ${BUILD_NUMBER}"
                """
            }
        }
        failure {
            echo 'Docker pipeline failed!'
            script {
                // Show container logs for debugging
                sh """
                    echo "Debugging information:"
                    docker ps -a | grep user-crud || true
                    
                    echo "Staging container logs:"
                    docker logs ${STAGING_CONTAINER} 2>&1 || echo "No staging container"
                    
                    echo "Production container logs:"
                    docker logs ${PROD_CONTAINER} 2>&1 || echo "No production container"
                """
            }
        }
        unstable {
            echo 'Docker pipeline is unstable!'
        }
    }
}