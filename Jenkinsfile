pipeline {
    agent any
    stages {
        stage('Build') {
            agent { 
                docker { 
                    image 'node:10.22'
                    reuseNode true 
                }
            }
            steps {
                sh 'node --version'
                sh 'npm --version'
                sh 'npm install -g gitbook-cli'
                sh 'gitbook install'
                sh 'gitbook build'
            }
        }
        stage('Deliver') {
            steps {
                sh './jenkins/deliver.sh'
            }
        }
    }
}