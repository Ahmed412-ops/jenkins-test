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
                    def sourcePath_back = "${WORKSPACE}\\publish"  // Backend source
                    def sourcePath_front = "${WORKSPACE}\\qareep"  // Frontend source
                    def siteName_back = "back-test4"
                    def siteName_front = "front-test4"
                    def port_back = 8010
                    def port_front = 8012
                    def destinationPath = "C:\\inetpub\\wwwroot"
                    def publishPath_back = "${destinationPath}\\publish"
                    def publishPath_front = "${destinationPath}\\qareep"
                    
                    bat """
                    @echo off
                    :: Create a PowerShell script to run elevated
                    echo Import-Module WebAdministration > deploy.ps1
                    
                    // ===== BACKEND DEPLOYMENT =====
                    echo \$sourcePath_back = '${sourcePath_back}' >> deploy.ps1
                    echo \$publishPath_back = '${publishPath_back}' >> deploy.ps1
                    echo \$siteName_back = '${siteName_back}' >> deploy.ps1
                    echo \$port_back = ${port_back} >> deploy.ps1
                    
                    echo "----- BACKEND: Checking and removing existing site and folder -----" >> deploy.ps1
                    echo if (Test-Path \$publishPath_back) { >> deploy.ps1
                    echo     "Found existing backend folder - removing..." >> deploy.ps1
                    echo     Remove-Item \$publishPath_back -Recurse -Force >> deploy.ps1
                    echo } >> deploy.ps1
                    echo if (Get-Website -Name \$siteName_back -ErrorAction SilentlyContinue) { >> deploy.ps1
                    echo     "Found existing backend website - removing..." >> deploy.ps1
                    echo     Stop-Website -Name \$siteName_back >> deploy.ps1
                    echo     Remove-Website -Name \$siteName_back >> deploy.ps1
                    echo } >> deploy.ps1
                    echo if (Get-WebAppPool -Name \$siteName_back -ErrorAction SilentlyContinue) { >> deploy.ps1
                    echo     "Found existing backend app pool - removing..." >> deploy.ps1
                    echo     Remove-WebAppPool -Name \$siteName_back >> deploy.ps1
                    echo } >> deploy.ps1
                    
                    echo "----- BACKEND: Copying files to IIS -----" >> deploy.ps1
                    echo Robocopy \$sourcePath_back \$publishPath_back /MIR /NP /NDL /NJH /NJS >> deploy.ps1
                    
                    echo "----- BACKEND: Creating App Pool -----" >> deploy.ps1
                    echo New-WebAppPool -Name \$siteName_back -Force >> deploy.ps1
                    echo Set-ItemProperty "IIS:\\\\AppPools\\\\\$siteName_back" -Name "managedRuntimeVersion" -Value "" >> deploy.ps1
                    
                    echo "----- BACKEND: Adding IIS Site -----" >> deploy.ps1
                    echo New-Website -Name \$siteName_back -Port \$port_back -PhysicalPath \$publishPath_back -ApplicationPool \$siteName_back -Force >> deploy.ps1
                    
                    echo "----- BACKEND: Setting Permissions -----" >> deploy.ps1
                    echo \$acl = Get-Acl \$publishPath_back >> deploy.ps1
                    echo \$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow") >> deploy.ps1
                    echo \$acl.AddAccessRule(\$rule) >> deploy.ps1
                    echo Set-Acl -Path \$publishPath_back -AclObject \$acl >> deploy.ps1
                    
                    echo "----- BACKEND: Starting Site -----" >> deploy.ps1
                    echo Start-Website -Name \$siteName_back >> deploy.ps1
                    
                    // ===== FRONTEND DEPLOYMENT =====
                    echo \$sourcePath_front = '${sourcePath_front}' >> deploy.ps1
                    echo \$publishPath_front = '${publishPath_front}' >> deploy.ps1
                    echo \$siteName_front = '${siteName_front}' >> deploy.ps1
                    echo \$port_front = ${port_front} >> deploy.ps1
                    
                    echo "----- FRONTEND: Checking and removing existing site and folder -----" >> deploy.ps1
                    echo if (Test-Path \$publishPath_front) { >> deploy.ps1
                    echo     "Found existing frontend folder - removing..." >> deploy.ps1
                    echo     Remove-Item \$publishPath_front -Recurse -Force >> deploy.ps1
                    echo } >> deploy.ps1
                    echo if (Get-Website -Name \$siteName_front -ErrorAction SilentlyContinue) { >> deploy.ps1
                    echo     "Found existing frontend website - removing..." >> deploy.ps1
                    echo     Stop-Website -Name \$siteName_front >> deploy.ps1
                    echo     Remove-Website -Name \$siteName_front >> deploy.ps1
                    echo } >> deploy.ps1
                    echo if (Get-WebAppPool -Name \$siteName_front -ErrorAction SilentlyContinue) { >> deploy.ps1
                    echo     "Found existing frontend app pool - removing..." >> deploy.ps1
                    echo     Remove-WebAppPool -Name \$siteName_front >> deploy.ps1
                    echo } >> deploy.ps1
                    
                    echo "----- FRONTEND: Copying files to IIS -----" >> deploy.ps1
                    echo Robocopy \$sourcePath_front \$publishPath_front /MIR /NP /NDL /NJH /NJS >> deploy.ps1
                    
                    echo "----- FRONTEND: Creating App Pool -----" >> deploy.ps1
                    echo New-WebAppPool -Name \$siteName_front -Force >> deploy.ps1
                    echo Set-ItemProperty "IIS:\\\\AppPools\\\\\$siteName_front" -Name "managedRuntimeVersion" -Value "" >> deploy.ps1
                    
                    echo "----- FRONTEND: Adding IIS Site -----" >> deploy.ps1
                    echo New-Website -Name \$siteName_front -Port \$port_front -PhysicalPath \$publishPath_front -ApplicationPool \$siteName_front -Force >> deploy.ps1
                    
                    echo "----- FRONTEND: Setting Permissions -----" >> deploy.ps1
                    echo \$acl = Get-Acl \$publishPath_front >> deploy.ps1
                    echo \$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow") >> deploy.ps1
                    echo \$acl.AddAccessRule(\$rule) >> deploy.ps1
                    echo Set-Acl -Path \$publishPath_front -AclObject \$acl >> deploy.ps1
                    
                    echo "----- FRONTEND: Starting Site -----" >> deploy.ps1
                    echo Start-Website -Name \$siteName_front >> deploy.ps1
                    
                    // ===== VERIFICATION =====
                    echo "----- Verification -----" >> deploy.ps1
                    echo "Backend Site:" >> deploy.ps1
                    echo Get-Website -Name \$siteName_back ^| Select-Object Name, State, PhysicalPath, Bindings >> deploy.ps1
                    echo "Frontend Site:" >> deploy.ps1
                    echo Get-Website -Name \$siteName_front ^| Select-Object Name, State, PhysicalPath, Bindings >> deploy.ps1
                    
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