pipeline {
    agent {
        label 'Slave'
    }

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "auto_maven"
    }
    environment{
        IMAGE = readMavenPom().getArtifactId()
        VERSION = readMavenPom().getVersion()
    }

    stages {
        stage('Cleaning app'){
            steps{
                sh "docker rm -f pandaapp || true"
            }
        }
        stage('Get code'){
            steps{
                // Get some code from a GitHub repository
                checkout scm
            }
        }
        stage('Build application && JUnit') {
            steps {
                
                sh "mvn clean install"
            }
        }
        stage('Create Docker Image'){
            steps{
                sh "mvn package -Pdocker -Dmaven.test.skip=true"
            }
        }
        stage('Start application'){
            steps{
                sh "docker run -d --name pandaapp -p 0.0.0.0:8080:8080 -t ${IMAGE}:${VERSION}"
            }
        }
        stage('Selenium Test'){
            steps{
                sh "mvn test -Pselenium"
            }
        }
        stage('Artifactory'){
            steps{
                configFileProvider([configFile(fileId: 'ebeb99dd-ec84-4636-9595-5a7ebeb0ee01', variable: 'MAVEN_SETTINGS')]) {
                sh 'mvn -s $MAVEN_SETTINGS deploy -Dmaven.test.skip=true'
                }
            }
            post {
                always {
                    sh "docker stop pandaapp"
                    junit '**/target/surefire-reports/TEST-*.xml'
                    archiveArtifacts 'target/*.jar'
                    deleteDir()
                }
            }
        }
        stage('Run terraform') {
            steps {
                dir('infrastructure/terraform') { 
                sh 'terraform init && terraform apply -auto-approve'
                } 
            }
        }
        stage('Copy Ansible role') {
            steps {
                sh 'cp -r infrastructure/ansible/panda/ /etc/ansible/roles/'
            }
        }
        stage('Run Ansible') {
            steps {
                dir('infrastructure/ansible') { 
                sh 'chmod 600 ../moje_nowe_klucze.pem'
                sh 'ansible-playbook -i ./inventory playbook.yml'
                } 
            }
        }
    }
}