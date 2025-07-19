pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
    }
    tools {
        maven 'maven_3.9.10'
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
                sh "docker build -t satyam88/booking-ms:latest -t booking-ms:latest ."
                echo 'Docker Image Build Completed!'
            }
        }
        stage('Docker Image Scanning') {
            steps {
                echo 'Scanning Docker Image with Trivy...'
                sh 'trivy image satyam88/booking-ms:latest || echo "Scan Failed - Proceeding with Caution"'
                echo 'Docker Image Scanning Completed!'
            }
        }
        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'dockerhubCred', variable: 'dockerhubCred')]) {
                        sh 'docker login docker.io -u satyam88 -p ${dockerhubCred}'
                        echo 'Pushing Docker Image to Docker Hub...'
                        sh 'docker push satyam88/booking-ms:latest'
                        echo 'Docker Image Pushed to Docker Hub Successfully!'
                    }
                }
            }
        }
        stage('Push Docker Image to Amazon ECR') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'ecr:ap-south-1:ecr-upload-credentials', url: "https://533267238276.dkr.ecr.ap-south-1.amazonaws.com"]) {
                        echo 'Tagging and Pushing Docker Image to ECR...'
                        sh '''
                            docker images
                            docker tag booking-ms:latest 533267238276.dkr.ecr.ap-south-1.amazonaws.com/booking-ms:latest
                            docker push 533267238276.dkr.ecr.ap-south-1.amazonaws.com/booking-ms:latest
                        '''
                        echo 'Docker Image Pushed to Amazon ECR Successfully!'
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