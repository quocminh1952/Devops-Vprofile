def COLOR_MAP = [
    'SUCCESS' : 'good',
    'FAILURE' : 'danger',
    'ABORTED': 'warning',
]

pipeline{ 
    // Agent chỉ định nơi pipeline sẽ chạy
    agent any  
    
    
    // tools : các tools mà pipline sẽ sử dụng trong các steps
    tools {
        maven "MAVEN3.9"
        jdk "JDK17"
    }

    environment{
        ECR_REGISTRY = '183631326219.dkr.ecr.us-east-1.amazonaws.com/vprofileapp' // URI registry
        ECR_REPOSITORY ="https://183631326219.dkr.ecr.us-east-1.amazonaws.com/vprofileapp"
        IMAGE_TAG = "${env.BUILD_NUMBER}" // Tag image bằng số build
        AWS_CREDENTIALS = 'ecr:us-east-1:AWS-Credentials' // ID của aws credentials
    }

    // stage : các giai đoạn của pipeline
    stages {
        // giai đoạn 1 : Fetch code
        stage('Fetch code'){
            steps{
                git url: 'https://github.com/hkhcoder/vprofile-project.git', branch: 'docker' 
            }
        }

        stage('Unit Test'){
            steps{
                sh 'mvn test'
            }
        }
        
         stage('SonarQube Analysis') {
            environment {
                SONAR_SCANNER_HOME = tool 'sonar7.1' 
            }
            steps {
                withSonarQubeEnv('sonar') { // Tên server đã khai báo ở trong system
                    sh "${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=vprofile \
                        -Dsonar.sources=src \
                        -Dsonar.java.binaries=target/classes"
                }
            }
        }

        stage('Quanlity Gate Sonar'){
            steps {
                // Giới hạn thời gian thực thi :10p => nếu quá build -> FALSE
                timeout(time: 10, unit: 'MINUTES') {
                    // Nếu kết quả QuanlityGate k đủ tiêu chuẩn => build -> FALSE
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build'){
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

       
        // stage('Upload artifact'){
        //   steps{
        //       nexusArtifactUploader(
        //         nexusVersion: 'nexus3',
        //         protocol: 'http',
        //         nexusUrl: '172.31.29.76:8081',
        //         groupId: 'com.InkDevops',
        //         version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
        //         repository: 'Vprofile-repo',
        //         credentialsId: 'nexus-credentials',
        //         artifacts: [
        //             [artifactId: "Vprofile",
        //             classifier: '',
        //             file: 'target/vprofile-v2.war',
        //             type: 'war']
        //         ]
        //     )
        //   }
        // }

        stage('Build Image'){
            steps{
                script{
                    // docker.build(image_name, [context_path])
                    dockerImage = docker.build( "${ECR_REGISTRY}:${IMAGE_TAG}")
                }
            }
        }

        stage('Upload Image TO ECR') {
            steps{
                script {
                    docker.withRegistry( ECR_REPOSITORY, AWS_CREDENTIALS ) {
                    dockerImage.push(IMAGE_TAG)
                    dockerImage.push('latest')
                    }
                }
            }

            post {
                always {
                    sh "docker rmi ${ECR_REGISTRY}:${IMAGE_TAG} || true" // Xóa image sau khi đẩy
                    sh "docker rmi ${ECR_REGISTRY}:latest || true" // Xóa image tag latest
                }
            }   
        }
    }

    // post sau khi pipeline hoàn thành
    post {
        // always : luôn thực thi dù job có success hay false
        always {
            //Add channel name
            slackSend channel: '#devopscicd',
            // currentBuild.currenResult = trạng thái trả về sau khi build
            color: COLOR_MAP[currentBuild.currentResult],
            message: "Find Status of Pipeline:- ${currentBuild.currentResult} ${env.JOB_NAME} ${env.BUILD_NUMBER} ${BUILD_URL}"
        }
    }
}
