pipeline {
    agent any
    stages {
        stage ('Delete the workspace') {
            steps {
                sh "sudo rm -rf $WORKSPACE/*"
            }
        }
        stage('Installing ChefDK') {
            steps {
                sh 'export CHEF_LICENSE=accepted'
                sh 'sudo apt-get install -y wget'
                sh 'wget https://packages.chef.io/files/stable/chefdk/3.8.14/ubuntu/18.04/chefdk_3.8.14-1_amd64.deb'
                sh 'sudo dpkg -i chefdk_3.8.14-1_amd64.deb'   
            }
        }
        stage('Third Stage') {
            steps {
                echo "Third stage"
            }
        }
    }
}