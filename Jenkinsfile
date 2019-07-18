pipeline {
    agent any
    stages {
        stage('Delete the workspaces') {
            steps {
                sh "sudo rm -rf $WORKSPACE/*"
            }
        }
        stage('Installing ChefDK') {
            steps {
                script {
                    def exists = fileExists '/usr/bin/chef-client'
                    if (exists) {
                        echo "Skipping CheDk install - allready installed"
                    } else {
                        sh 'export CHEF_LICENSE=accepted'
                        sh 'sudo apt-get install wget -y'
                        sh 'wget https://packages.chef.io/files/stable/chefdk/3.8.14/ubuntu/18.04/chefdk_3.8.14-1_amd64.deb'
                        sh 'sudo dpkg -i chefdk_3.8.14-1_amd64.deb'  
                    }
                }
            }
        }
        stage('Download Apache Cookbook') {
            steps {
                git credentialsId: 'f846bf41-a11e-4d16-9547-c75ee73a9acf', url: 'git@github.com:tverdich/apache.git'
            }
        }
        stage("Install Kitchen Docker gem")    
            steps {
                    sh 'chef gem install kitchen-docker'
            }
        stage("Run test Kitchen")    
            steps {
                    sh 'sudo kitchen test'
            } 
        }
    }
}