pipeline {
    agent any

    environment {
        BACKEND_IMAGE = 'ashanwijesinghe/stock-predictions-backend'
        FRONTEND_IMAGE = 'ashanwijesinghe/stock-predictions-frontend'
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        AWS_CREDENTIALS_ID = 'aws-credentials'
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

        stage('Terraform Init and Plan') {
            steps {
                script {
                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: AWS_CREDENTIALS_ID,
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]
                    ]) {
                        dir('terraform') {
                            sh 'terraform init'
                            sh 'terraform plan -out=tfplan'
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: AWS_CREDENTIALS_ID,
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]
                    ]) {
                        dir('terraform') {
                            sh 'terraform apply -auto-approve tfplan'
                            sh '''
                                echo "[app_servers]" > ../ansible/inventory.ini
                                echo "$(terraform output -raw public_ip) ansible_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/ec2-key.pem" >> ../ansible/inventory.ini
                            '''
                        }
                    }
                }
            }
        }  

        stage('Deploy with Ansible') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'ec2-ssh-key-file', variable: 'SSH_KEY_FILE')]) {
                        dir('ansible') {
                            // Copy SSH key to a location Ansible can use
                            sh '''
                                mkdir -p /var/lib/jenkins/.ssh
                                cp "$SSH_KEY_FILE" /var/lib/jenkins/.ssh/ec2-key.pem
                                chmod 400 /var/lib/jenkins/.ssh/ec2-key.pem
                            '''
                            
                            // Wait for SSH to be available
                            sh 'sleep 60'
                            
                            // Run Ansible playbook
                            sh '''
                                export ANSIBLE_HOST_KEY_CHECKING=False
                                ansible-playbook -i inventory.ini playbook.yml
                            '''
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
            
            // Clean up SSH key
            sh 'rm -f /var/lib/jenkins/.ssh/ec2-key.pem'
            
            // Clean up Terraform files
            dir('terraform') {
                deleteDir()
            }
        }
    }
}