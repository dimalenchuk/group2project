pipeline {
    environment {
        registryPHP = "dimalenchuk/apache-php"
        registrySQL = "dimalenchuk/mysql"
        registryCredential = "dockerhub"
        imagePHP = "$registryPHP:$BUILD_NUMBER"
        imageSQL = "$registrySQL:$BUILD_NUMBER"
    }
    agent {
        node {
            label 'slave1'
        }
    }
    tools {
        terraform 'terraform'
    }
    stages {
        stage('Clone git') {
            steps {
                git credentialsId: 'git', url: 'https://github.com/dimalenchuk/group2project'
            }
        }
        stage('Build and push images to private repo') {
            steps {
                script {
                    docker.withRegistry( '', registryCredential ) {
                    docker.build(imagePHP, "images/").push()
                    docker.build(imageSQL, "-f=images/Dockerfile-mysql images/").push()
                }
                }
            }
        }
        // stage('Terraform Apply') {
        //     steps {
        //         sh 'terraform apply --auto-approve'
        //     }
        // }
    }
}
