pipeline{ 
    // Agent chỉ định nơi pipeline sẽ chạy
    agent any  
    
    environment {
        // Sonar
        SONAR_SCANNER_HOME = tool 'sonar7.1'
        // Nexus
        NEXUS_URL = '54.227.80.162:8081'

    }
    // tools : các tools mà pipline sẽ sử dụng trong các steps
    tools {
        maven "MAVEN3.9"
        jdk "JDK17"
    }

    // stage : các giai đoạn của pipeline
    stages {
        // giai đoạn 1 : Fetch code
        stage('Fetch code'){
            steps{
                git url: 'https://github.com/hkhcoder/vprofile-project.git', branch: 'atom' 
            }
        }

        stage('Unit Test'){
            steps{
                sh 'mvn test'
            }
        }


        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') { // Tên server đã khai báo ở trong system
                    sh "${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=vprofile \
                        -Dsonar.sources=src \
                        -Dsonar.java.binaries=target/classes"
                }
            }
        }

        stage('Build') {
            steps{
                sh 'mvn install -DskipTests'
            }
            //Khối post : định nghĩa hàn động sẽ chạy sau khi stage hoàn thành
            post { 
                success{
                    echo "Archiving artifact"
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }

        //Upload artifact lên Nexus
        stage('Upload artifact'){
          steps{
              nexusArtifactUploader(
                nexusVersion: 'nexus3',
                protocol: 'http',
                nexusUrl: '${NEXUS_URL}',
                groupId: 'com.InkDevops',
                version: "${env.BUILD_ID}",
                repository: 'Vprofile-repo',
                credentialsId: 'nexus-credentials',
                artifacts: [
                    [artifactId: "Vprofile",
                    classifier: '',
                    file: 'target/vprofile-v2.war',
                    type: 'war']
                ]
            )
          }
        }

    }
}