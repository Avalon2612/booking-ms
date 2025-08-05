pipeline {
    agent { label 'Java' }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
    }
    tools {
        maven 'maven_3.9.11'
    }
    stages {
        stage('Code Compilation') {
            steps {
                echo 'Starting Code Compilation...'
                sh 'mvn clean compile'
                echo 'Code Compilation Completed Successfully!'
            }
        }
        stage('Code QA Execution') {
            steps {
                echo 'Running JUnit Test Cases...'
                sh 'mvn clean test'
                echo 'JUnit Test Cases Completed Successfully!'
            }
        }
        stage('Code Package') {
            steps {
                echo 'Creating WAR Artifact...'
                sh 'mvn clean package'
                echo 'WAR Artifact Created Successfully!'
            }
        }
        stage('Build & Tag Docker Image') {
            steps {
                echo 'Building Docker Image with Tags...'
                sh "docker build -t avalon26/booking-ms:latest -t booking-ms:latest ."
                echo 'Docker Image Build Completed!'
            }
        }
        stage('Docker Image Scanning') {
            steps {
                echo 'Scanning Docker Image with Trivy...'
                sh 'trivy image avalon26/booking-ms:latest || echo "Scan Failed - Proceeding with Caution"'
                echo 'Docker Image Scanning Completed!'
            }
        }
        stage('Push Docker Image to Docker Hub') {
			steps {
				withCredentials([usernamePassword(credentialsId: 'dockerhubCred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh """
                echo 'Logging in to Docker Hub...'
                echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                echo 'Pushing Docker Image to Docker Hub...'
                docker push avalon26/booking-ms:latest
                echo 'Docker Image Pushed to Docker Hub Successfully!'
            """
				}
			}
		}
        stage('Push Docker Image to Amazon ECR') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'ecr:ap-south-1:ecr-upload-credentials', url: "https://334602887177.dkr.ecr.ap-south-1.amazonaws.com/booking-ms"]) {
                        echo 'Tagging and Pushing Docker Image to ECR...'
                        sh '''
                            docker images
                            docker tag booking-ms:latest 334602887177.dkr.ecr.ap-south-1.amazonaws.com/booking-ms:latest
                            docker push 334602887177.dkr.ecr.ap-south-1.amazonaws.com/booking-ms:latest
                        '''
                        echo 'Docker Image Pushed to Amazon ECR Successfully!'
                    }
                }
            }
		}
		 stage('Upload Docker Image to Nexus') {
                     steps {
                         script {
                             withCredentials([usernamePassword(credentialsId: 'nexuscred', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                                 sh '''
                                     echo 'Logging in to Nexus Docker Registry...'
                                     echo $PASSWORD | docker login http://3.109.181.34:8085 -u $USERNAME --password-stdin
                                     echo 'Push Docker Image to Nexus In Progress'
                                     docker tag booking-ms:latest 3.109.181.34:8085/booking-ms:latest
                                     docker push 3.109.181.34:8085/booking-ms:latest
                                     echo 'Push Docker Image to Nexus: Completed'
                                 '''
                             }
                         }
                     }
                 }

        stage('Cleanup Docker Images') {
            steps {
                echo 'Cleaning up local Docker images...'
                sh 'docker rmi -f $(docker images -aq)'
                echo 'Local Docker images deleted successfully!'
            }
        }
    }
}