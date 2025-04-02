pipeline {
    agent any

    environment {
        BACKEND_IMAGE = 'ashanwijesinghe/stock-predictions-backend'
        FRONTEND_IMAGE = 'ashanwijesinghe/stock-predictions-frontend'
        FRONTEND_IMAGE_NAME= 'stock-predictions-frontend'
        BACKEND_IMAGE_NAME= 'stock-predictions-backend'
        BACKEND_CONTAINER_NAME = 'backendcontainer'
        FRONTEND_CONTAINER_NAME = 'frontendcontainer'
        DOCKERHUB_NAMESPACE = 'ashanwijesinghe'
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

        // stage('Deploy to AWS ECS') {
        //     steps {
        //         script {
        //             withCredentials([
        //                 [$class: 'AmazonWebServicesCredentialsBinding',
        //                 credentialsId: AWS_CREDENTIALS_ID,
        //                 accessKeyVariable: 'AWS_ACCESS_KEY_ID',
        //                 secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']
        //             ]) {
        //                 sh '''
        //                     aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
        //                     aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
        //                     aws configure set region $AWS_REGION
                            
        //                     echo "Registering new ECS task definition..."
        //                     aws ecs register-task-definition \
        //                         --family $ECS_TASK_DEFINITION \
        //                         --container-definitions '[
        //                             {"name":"backend","image":"'$BACKEND_IMAGE'","memory":512,"cpu":256,"essential":true},
        //                             {"name":"frontend","image":"'$FRONTEND_IMAGE'","memory":512,"cpu":256,"essential":true}
        //                         ]'
                            
        //                     echo "Updating ECS service..."
        //                     aws ecs update-service \
        //                         --cluster $ECS_CLUSTER \
        //                         --service $ECS_SERVICE \
        //                         --force-new-deployment
        //                 '''
        //             }
        //         }
        //     }
        // }
            stage('Pull Latest Docker Images on AWS') {
                steps {
                    script {
                        def pemFilePath = "/var/lib/jenkins/.ssh/projserverpem.pem"
                        def publicIP = "44.204.36.222"
                        
                        sh """
                        ssh -o StrictHostKeyChecking=no -i "${pemFilePath}" ubuntu@${publicIP} '
                            echo "Pulling latest Docker images...";
                            sudo docker pull ${DOCKERHUB_NAMESPACE}/${BACKEND_IMAGE_NAME}:latest
                            sudo docker pull ${DOCKERHUB_NAMESPACE}/${FRONTEND_IMAGE_NAME}:latest
                            echo "Docker images updated successfully!"
                        '
                        """
                    }
                }
            }

            stage('Deploy to AWS') {
            steps {
                script {
                    def pemFilePath = "/var/lib/jenkins/.ssh/projserverpem.pem"
                    def publicIP = "44.204.36.222"
                    def dockernetwork = "mynet"

                    sh """
                    ssh -o StrictHostKeyChecking=no -i "${pemFilePath}" ubuntu@${publicIP} '
                        echo "Checking Docker network...";
                        if ! sudo docker network ls | grep -q ${dockernetwork}; then
                            sudo docker network create ${dockernetwork};
                        fi

                        echo "Stopping and removing old containers...";
                        sudo docker stop ${BACKEND_CONTAINER_NAME} ${FRONTEND_CONTAINER_NAME} || true
                        sudo docker rm ${BACKEND_CONTAINER_NAME} ${FRONTEND_CONTAINER_NAME} || true

                        echo "Starting updated containers...";
                        sudo docker run -d --name ${BACKEND_CONTAINER_NAME} --network ${dockernetwork} -p 8000:8000 \\
                            -e DATABASE_NAME=Stock_Predictor -e DATABASE_USER=postgres \\
                            -e DATABASE_PASSWORD=Tha12345 -e DATABASE_HOST=db \\
                            ${DOCKERHUB_NAMESPACE}/${BACKEND_IMAGE_NAME}:latest

                        sudo docker run -d --name ${FRONTEND_CONTAINER_NAME} --network ${dockernetwork} -p 5173:5173 \\
                            -e VITE_BACKEND_URL=http://${publicIP}:8000 \\
                            ${DOCKERHUB_NAMESPACE}/${FRONTEND_IMAGE_NAME}:latest

                        echo "Cleaning up old images...";
                        sudo docker image prune -af --filter "until=24h"

                        echo "Deployment completed successfully!"
                    '
                    """
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