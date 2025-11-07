pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9.0'
        jdk 'JDK-21'
    }
    
    stages {
        stage('Verify Tools') {
            steps {
                sh 'java -version'
                sh 'mvn -version'
                sh 'echo "JAVA_HOME: $JAVA_HOME"'
                sh 'echo "PATH: $PATH"'
            }
        }
    }
}