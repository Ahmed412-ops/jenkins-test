param(
    [string]$SourcePath = "C:\Users\Algorithm\AppData\Local\Jenkins\.jenkins\workspace\jenkins-test\qareep",
    [string]$SiteName = "front-test4",
    [int]$Port = 8020,
    [string]$DestinationPath = "C:\inetpub\wwwroot"
)

Import-Module WebAdministration

$PublishPath = Join-Path $DestinationPath "qareep"

Write-Host "==== Deploying Frontend: $SiteName ====" -ForegroundColor Green

# Remove existing folder
if (Test-Path $PublishPath) {
    Write-Host "Removing existing folder: $PublishPath"
    Remove-Item $PublishPath -Recurse -Force
}

# Remove existing site
if (Get-Website -Name $SiteName -ErrorAction SilentlyContinue) {
    Write-Host "Removing existing IIS site: $SiteName"
    Stop-Website -Name $SiteName
    Remove-Website -Name $SiteName
}

# Remove existing app pool
if (Get-WebAppPoolState -Name $SiteName -ErrorAction SilentlyContinue) {
    Write-Host "Removing existing App Pool: $SiteName"
    Remove-WebAppPool -Name $SiteName
}

# Copy files
Write-Host "Copying files from $SourcePath to $PublishPath"
robocopy $SourcePath $PublishPath /MIR /NP /NDL /NJH /NJS > $null

# Create app pool
Write-Host "Creating App Pool: $SiteName"
New-WebAppPool -Name $SiteName
Set-ItemProperty "IIS:\AppPools\$SiteName" -Name "managedRuntimeVersion" -Value ""

# Create site
Write-Host "Creating IIS Site: $SiteName on port $Port"
New-Website -Name $SiteName -Port $Port -PhysicalPath $PublishPath -ApplicationPool $SiteName

# Set permissions
Write-Host "Setting permissions on $PublishPath"
$acl = Get-Acl $PublishPath
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)
Set-Acl -Path $PublishPath -AclObject $acl

# Start site
Start-Website -Name $SiteName

# Verify
$site = Get-Website -Name $SiteName
Write-Host "Frontend '$SiteName' deployed at port $Port"
$site | Select-Object Name, State, PhysicalPath, Bindings
