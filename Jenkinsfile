pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Deploy Backend') {
            steps {
                bat """
                powershell -NoProfile -ExecutionPolicy Bypass -File deploy_back.ps1 `
                    -SourcePath "${WORKSPACE}\\publish" `
                    -SiteName "back-test4" `
                    -Port 8011 `
                    -DestinationPath "C:\\inetpub\\wwwroot"
                """
            }
        }

        stage('Deploy Frontend') {
            steps {
                bat """
                powershell -NoProfile -ExecutionPolicy Bypass -File deploy_front.ps1 `
                    -SourcePath "${WORKSPACE}\\qareep" `
                    -SiteName "front-test4" `
                    -Port 8020 `
                    -DestinationPath "C:\\inetpub\\wwwroot"
                """
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
