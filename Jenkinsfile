pipeline {
    agent { label "agentfarm"}
    stages {
        stage('Delete the workspace') {
            steps {
                sh "sudo rm -rf $WORKSPACE/*"
            }
        }
        stage('Installing ChefDK') {
            steps {
                script {
                    def exists = fileExists '/usr/bin/chef-client'
                    if (exists) {
                        echo "Skipping ChefDK install - already installed"
                    } else {
                            sh 'export CHEF_LICENSE=accept'
                            sh 'sudo apt-get install -y wget'
                            sh 'wget https://packages.chef.io/files/stable/chefdk/3.8.14/ubuntu/16.04/chefdk_3.8.14-1_amd64.deb'
                            sh 'sudo dpkg -i chefdk_3.8.14-1_amd64.deb'                           
                    }
                }
            }
        }
        
        stage('Download Apache Cookbook') {
            steps {
                git credentialsId: 'git-repo-creds', url: 'git@github.com:operationstt/apache-16july.git'
            }
        }
        stage('Install Kitchen Docker Gem') {
            steps {
                sh 'chef gem install kitchen-docker'
            }
        }
        stage('Run Test kitchen') {
            steps {
                sh 'sudo kitchen test'
            }
        }
        stage('Send Slack Notification') {
            steps {
                slackSend color: 'warning', message: "Student-16 PLease approve ${env.JOB_NAME} ${env.BUILD_NUMBER} (<{$env.JOB_URL} | Open>)"
            }
        }
        stage('Request input') {
            steps {
                input 'Please approve or deny this request'
            }    
        }
        stage('upload to chef server, converge nodes') {
            steps {
                withCredentials([zip(credentialsId: 'chef-starter-zip', variable: 'CHEFREPO')]) {
                    sh "mkdir -p $CHEFREPO/chef-repo/cookbooks/apache"
                    sh "mv $WORKSPACE/* $CHEFREPO/chef-repo/cookbooks/apache"
                    sh "sudo rm -rf $CHEFREPO/chef-repo/cookbooks/apache/Berksfile.lock"
                    sh "knife cookbook upload apache --force -o $CHEFREPO/chef-repo/cookbooks -c $CHEFREPO/chef-repo/.chef/knife.rb"
                    withCredentials([sshUserPrivateKey(credentialsId: 'agent-key', keyFileVariable: 'agentKey', passphraseVariable: '', usernameVariable: '')]) {
                        sh "knife ssh 'role:webserver' -x ubuntu -i $agentKey 'sudo chef-client' -c $CHEFREPO/chef-repo/.chef/knife.rb"
                    }
                }
            }
        }
    }
    post {
        success {
            slackSend color: 'warning', message: "Build ${env.JOB_NAME} ${env.BUILD_NUMBER} Successful!"    
        }
        failure {
            echo "Build failed"
            mail  body: "Build ${env.JOB_NAME} ${env.BUILD_NUMBER} failed. Please check the build at ${env.JOB_URL}", from: 'admin@myclass.email', subject: 'Build Failure', to: 'elon@technotrainer.com'
        }
    }
}