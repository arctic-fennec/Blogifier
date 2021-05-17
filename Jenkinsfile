pipeline {
    agent any

    stages {
        stage('Checkout project') {
            steps {
                git branch: 'main',
                    credentialsId: 'git-credentials',
                    url: 'https://github.com/arctic-fennec/Blogifier'

                sh "ls -lat"
            }
        }
        stage('Docker build') {
            steps {
                sh "docker build --network=host -t localhost:8083/jenkins_task ."
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}