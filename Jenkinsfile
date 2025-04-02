pipeline {
    agent any

    environment {
        BACKEND_IMAGE = 'your-dockerhub-username/stock-predictions-backend'
        FRONTEND_IMAGE = 'your-dockerhub-username/stock-predictions-frontend'
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
    }

    stages {
        stage('Build Backend Docker Image') {
            steps {
                script {
                    dir('Stock-predictions-backend') {
                        sh 'docker build -t $BACKEND_IMAGE .'
                    }
                }
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                script {
                    dir('Stock-predictions-frontend') {
                        sh 'docker build -t $FRONTEND_IMAGE .'
                    }
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_CREDENTIALS_ID) {
                        sh 'docker push $BACKEND_IMAGE'
                        sh 'docker push $FRONTEND_IMAGE'
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
        }
    }
}