pipeline {
    agent any

    environment {
        BACKEND_IMAGE = 'ashanwijesinghe/stock-predictions-backend'
        FRONTEND_IMAGE = 'ashanwijesinghe/stock-predictions-frontend'
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        AWS_CREDENTIALS_ID = 'aws-credentials'
        AWS_REGION = 'us-east-1'
        ECS_CLUSTER = 'stock-predictions-cluster'
        ECS_SERVICE = 'stock-predictions-service'
        ECS_TASK_DEFINITION = 'stock-predictions-task'
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

        stage('Deploy to AWS ECS') {
            steps {
                script {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: AWS_CREDENTIALS_ID,
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']
                    ]) {
                        sh '''
                            aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                            aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                            aws configure set region $AWS_REGION
                            
                            echo "Registering new ECS task definition..."
                            aws ecs register-task-definition \
                                --family $ECS_TASK_DEFINITION \
                                --container-definitions '[
                                    {"name":"backend","image":"'$BACKEND_IMAGE'","memory":512,"cpu":256,"essential":true},
                                    {"name":"frontend","image":"'$FRONTEND_IMAGE'","memory":512,"cpu":256,"essential":true}
                                ]'
                            
                            echo "Updating ECS service..."
                            aws ecs update-service \
                                --cluster $ECS_CLUSTER \
                                --service $ECS_SERVICE \
                                --force-new-deployment
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