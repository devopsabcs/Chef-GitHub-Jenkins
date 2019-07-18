pipeline {
    agent any
    stages {
        stage ('Delete the workspace') {
            steps {
                sh "sudo rm -rf $WORKSPACE/*"
            }
        }
        stage('Second stage') {
            steps {
                echo "Second stage"
            }
        }
        stage('Third Stage') {
            steps {
                echo "Third stage"
            }
        }
    }
}