#!/bin/bash

# Build and Deploy Script for User CRUD API

set -e

echo "🚀 Starting build and deployment process..."

# Build the application
echo "📦 Building Docker image..."
docker build -t user-crud-api:latest .

# Run tests in container
echo "🧪 Running tests..."
docker run --rm -v $(pwd):/app -w /app maven:3.9.4-openjdk-21-slim mvn clean test

# Start Jenkins if not running
echo "🔧 Starting Jenkins..."
if ! docker ps | grep -q jenkins; then
    docker-compose up -d jenkins
    echo "⏳ Waiting for Jenkins to start..."
    sleep 30
    echo "🌐 Jenkins is available at: http://localhost:8090"
    echo "📋 Default credentials: admin/admin123"
fi

# Start the application
echo "🚀 Starting application..."
docker-compose up -d user-crud-api

echo "✅ Deployment complete!"
echo "📱 Application is available at: http://localhost:8080"
echo "🔍 Health check: http://localhost:8080/actuator/health"
echo "🛠️ Jenkins: http://localhost:8090"

# Show running containers
echo "📊 Running containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"