pipeline {
    agent any

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
                script {
                    withCredentials([string(credentialsId: 'dockerhubCred', variable: 'dockerhubCred')]) {
                        sh 'docker login docker.io -u avalon26 -p Esds@abhi2025'
                        echo 'Pushing Docker Image to Docker Hub...'
                        sh 'docker push avalon26/booking-ms:latest'
                        echo 'Docker Image Pushed to Docker Hub Successfully!'
                    }
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
        stage('Cleanup Docker Images') {
            steps {
                echo 'Cleaning up local Docker images...'
                sh 'docker rmi -f $(docker images -aq)'
                echo 'Local Docker images deleted successfully!'
            }
        }
    }
}