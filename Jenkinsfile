pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Deploy to IIS') {
            steps {
                script {
                    def sourcePath = "${WORKSPACE}"
                    def siteName = "back-test3"
                    def port = 8001
                    def destinationPath = "C:\\inetpub\\wwwroot\\"
                    
                    bat """
                    @echo off
                    :: Create a PowerShell script to run elevated
                    echo Import-Module WebAdministration > deploy.ps1
                    echo \$sourcePath = '${sourcePath}' >> deploy.ps1
                    echo \$destinationPath = '${destinationPath}' >> deploy.ps1
                    echo \$siteName = '${siteName}' >> deploy.ps1
                    echo \$port = ${port} >> deploy.ps1
                    echo >> deploy.ps1
                    echo "----- Copying files to IIS -----" >> deploy.ps1
                    echo Robocopy \$sourcePath \$destinationPath\\publish /MIR /NP /NDL /NJH /NJS >> deploy.ps1
                    echo >> deploy.ps1
                    echo "----- Creating App Pool -----" >> deploy.ps1
                    echo New-WebAppPool -Name \$siteName -Force >> deploy.ps1
                    echo Set-ItemProperty "IIS:\\\\AppPools\\\\\$siteName" -Name "managedRuntimeVersion" -Value "" >> deploy.ps1
                    echo >> deploy.ps1
                    echo "----- Adding IIS Site -----" >> deploy.ps1
                    echo New-Website -Name \$siteName -Port \$port -PhysicalPath "\$destinationPath\\publish" -ApplicationPool \$siteName -Force >> deploy.ps1
                    echo >> deploy.ps1
                    echo "----- Setting Permissions -----" >> deploy.ps1
                    echo \$acl = Get-Acl "\$destinationPath\\publish" >> deploy.ps1
                    echo \$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow") >> deploy.ps1
                    echo \$acl.AddAccessRule(\$rule) >> deploy.ps1
                    echo Set-Acl -Path "\$destinationPath\\publish" -AclObject \$acl >> deploy.ps1
                    echo >> deploy.ps1
                    echo "----- Starting Site -----" >> deploy.ps1
                    echo Start-Website -Name \$siteName >> deploy.ps1
                    echo >> deploy.ps1
                    echo "----- Verification -----" >> deploy.ps1
                    echo Get-Website -Name \$siteName ^| Select-Object Name, State, PhysicalPath, Bindings >> deploy.ps1
                    
                    :: Execute the PowerShell script elevated
                    powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%CD%\\deploy.ps1\"' -Wait"
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}