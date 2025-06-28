pipeline {
    agent any

    environment {
        // Define any variables you need here
        PORT_BACK = '8011'
        PORT_FRONT = '8021'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Deploy Backend') {
            steps {
                bat "powershell -NoProfile -ExecutionPolicy Bypass -File deploy_back.ps1 -SourcePath \"${WORKSPACE}\\publish\" -SiteName \"back-test4\" -Port ${PORT_BACK} -DestinationPath \"C:\\inetpub\\wwwroot\""
            }
        }

        stage('Deploy Frontend') {
            steps {
                bat "powershell -NoProfile -ExecutionPolicy Bypass -File deploy_front.ps1 -SourcePath \"${WORKSPACE}\\qareep\" -SiteName \"front-test4\" -Port ${PORT_FRONT} -DestinationPath \"C:\\inetpub\\wwwroot\""
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
