pipeline {
    agent any

    environment {
        BACKEND_IMAGE = 'ashanwijesinghe/stock-predictions-backend'
        FRONTEND_IMAGE = 'ashanwijesinghe/stock-predictions-frontend'
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
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
                            echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                            docker push $BACKEND_IMAGE
                            docker push $FRONTEND_IMAGE
                        '''
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