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
                    def sourcePath = "${WORKSPACE}\\publish"  // Pointing to the publish folder in repo
                    def siteName = "back-test4"
                    def port = 8004
                    def destinationPath = "C:\\inetpub\\wwwroot"
                    def publishPath = "${destinationPath}\\publish"
                    
                    bat """
                    @echo off
                    :: Create a PowerShell script to run elevated
                    echo Import-Module WebAdministration > deploy.ps1
                    echo \$sourcePath = '${sourcePath}' >> deploy.ps1
                    echo \$publishPath = '${publishPath}' >> deploy.ps1
                    echo \$siteName = '${siteName}' >> deploy.ps1
                    echo \$port = ${port} >> deploy.ps1
                    echo >> deploy.ps1
                    echo "----- Checking and removing existing site and folder -----" >> deploy.ps1
                    echo if (Test-Path \$publishPath) { >> deploy.ps1
                    echo     "Found existing folder - removing..." >> deploy.ps1
                    echo     Remove-Item \$publishPath -Recurse -Force >> deploy.ps1
                    echo } >> deploy.ps1
                    echo if (Get-Website -Name \$siteName -ErrorAction SilentlyContinue) { >> deploy.ps1
                    echo     "Found existing website - removing..." >> deploy.ps1
                    echo     Stop-Website -Name \$siteName >> deploy.ps1
                    echo     Remove-Website -Name \$siteName >> deploy.ps1
                    echo } >> deploy.ps1
                    echo if (Get-WebAppPool -Name \$siteName -ErrorAction SilentlyContinue) { >> deploy.ps1
                    echo     "Found existing app pool - removing..." >> deploy.ps1
                    echo     Remove-WebAppPool -Name \$siteName >> deploy.ps1
                    echo } >> deploy.ps1
                    echo >> deploy.ps1
                    echo "----- Copying files to IIS -----" >> deploy.ps1
                    echo Robocopy \$sourcePath \$publishPath /MIR /NP /NDL /NJH /NJS >> deploy.ps1
                    echo >> deploy.ps1
                    echo "----- Creating App Pool -----" >> deploy.ps1
                    echo New-WebAppPool -Name \$siteName -Force >> deploy.ps1
                    echo Set-ItemProperty "IIS:\\\\AppPools\\\\\$siteName" -Name "managedRuntimeVersion" -Value "" >> deploy.ps1
                    echo >> deploy.ps1
                    echo "----- Adding IIS Site -----" >> deploy.ps1
                    echo New-Website -Name \$siteName -Port \$port -PhysicalPath \$publishPath -ApplicationPool \$siteName -Force >> deploy.ps1
                    echo >> deploy.ps1
                    echo "----- Setting Permissions -----" >> deploy.ps1
                    echo \$acl = Get-Acl \$publishPath >> deploy.ps1
                    echo \$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow") >> deploy.ps1
                    echo \$acl.AddAccessRule(\$rule) >> deploy.ps1
                    echo Set-Acl -Path \$publishPath -AclObject \$acl >> deploy.ps1
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