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
                sh "docker build --network=host -t localhost:8082/blogifier ."
            }
        }
        stage('Push') {
            steps {
                sh "docker login localhost:8082 -u admin -p ADMIN"
				sh "docker push localhost:8082/blogifier"
            }
        }
    }
}