pipeline {
    agent any
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
                            sh '''
                               export CHEF_LICENSE=accept
                               sudo apt-get install -y wget
                               wget https://packages.chef.io/files/stable/chefdk/4.8.23/ubuntu/20.04/chefdk_4.8.23-1_amd64.deb
                               sudo dpkg -i chefdk_4.8.23-1_amd64.deb
                            '''                         
                    }
                }
            }
        }
        
        stage('Download Apache Cookbook') {
            steps {
                git credentialsId: '', url: 'https://github.com/devopsabcs/Chef-GitHub-Jenkins.git'
            }
        }
        stage('Install Docker') {
            steps {
                script {
                    def dockerExists = fileExists '/usr/bin/docker'
                    if (dockerExists) {
                        echo "Skipping Docker install - already installed"
                    } else {                             
                            sh '''                               
                               wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/containerd.io_1.2.13-2_amd64.deb
                               wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce-cli_19.03.12~3-0~ubuntu-focal_amd64.deb
                               wget https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/docker-ce_19.03.12~3-0~ubuntu-focal_amd64.deb
                               sudo dpkg -i containerd.io_1.2.13-2_amd64.deb
                               sudo dpkg -i docker-ce-cli_19.03.12~3-0~ubuntu-focal_amd64.deb
                               sudo dpkg -i docker-ce_19.03.12~3-0~ubuntu-focal_amd64.deb
                               sudo usermod -aG root,docker ubuntu
                            '''                         
                    }
                    sh 'sudo docker run hello-world'
                }
            }
        }
        stage('Install Ruby and Test Kitchen Docker Gem') {
            steps {
                sh '''
                    sudo apt-get install -y rubygems ruby-dev
                    export CHEF_LICENSE=accept
                    chef gem install kitchen-docker
                '''
            }
        }
        stage('Run Test kitchen') {
            steps {
                sh '''
                  gem env
                  sudo kitchen test
                '''
            }
        }
        stage('Send Slack Notification') {
            steps {
                slackSend color: 'warning', message: "DevOps Engineer 3 PLease approve ${env.JOB_NAME} ${env.BUILD_NUMBER} (<{$env.JOB_URL} | Open>)"
            }
        }
        stage('Request input') {
            steps {
                input 'Please approve or deny this request'
            }    
        }
        stage('upload to chef server, converge nodes') {
            steps {
                withCredentials([zip(credentialsId: 'chef-starter-onprem-zip', variable: 'CHEFREPO')]) {
                    sh "mkdir -p $CHEFREPO/chef-repo/cookbooks/apache"
                    sh "sudo rm -rf $WORKSPACE/Berksfile.lock"
                    sh "mv $WORKSPACE/* $CHEFREPO/chef-repo/cookbooks/apache"                                        
                    sh "knife cookbook upload apache --force -o $CHEFREPO/chef-repo/cookbooks -c $CHEFREPO/chef-repo/.chef/knife.rb"
                    withCredentials([sshUserPrivateKey(credentialsId: 'agent-key-jenkins', keyFileVariable: 'AGENT_SSHKEY', passphraseVariable: '', usernameVariable: '')]) {
                        sh "cat $AGENT_SSHKEY"
                        sh "cat /var/lib/jenkins/.ssh/id_rsa"
                        //sh "knife ssh 'role:webserver' -x emmanuel -i $AGENT_SSHKEY 'ls -a' -c $CHEFREPO/chef-repo/.chef/knife.rb"
                        sh "knife ssh 'role:webserver' -x emmanuel -i /var/lib/jenkins/.ssh/id_rsa 'ls -a' -c $CHEFREPO/chef-repo/.chef/knife.rb"
                        //sh "knife ssh 'role:webserver' -x jenkins -i $AGENT_SSHKEY 'ls -a' -c $CHEFREPO/chef-repo/.chef/knife.rb"
                        //sh "knife ssh 'role:webserver' -x emmanuel -i $AGENT_SSHKEY 'sudo chef-client' -c $CHEFREPO/chef-repo/.chef/knife.rb"
                        //CHEATING by doing passwordless sudo on client nodes:
                        //sudo visudo
                        //emmanuel ALL=(ALL) NOPASSWD:ALL
                        //double check emmanuel is a sudoer:
                        //getent group sudo
                        sh "knife ssh 'role:webserver' -x emmanuel -i /var/lib/jenkins/.ssh/id_rsa 'sudo chef-client' -c $CHEFREPO/chef-repo/.chef/knife.rb"
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
            mail  body: "Build ${env.JOB_NAME} ${env.BUILD_NUMBER} failed. Please check the build at ${env.JOB_URL}", from: 'emmanuelknafo@gmail.com', subject: 'Build Failure', to: 'emmanuelknafo@gmail.com'
        }
    }
}