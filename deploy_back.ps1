param (
    [string]$SourcePath,
    [string]$SiteName,
    [int]$Port,
    [string]$DestinationPath,
    [bool]$CleanPublishFolder = $true
)

$PublishPath = Join-Path $DestinationPath "publish"
$excludedFolder = Join-Path $PublishPath "wwwroot"

Write-Host "==== Deploying Backend: $SiteName ===="

Import-Module WebAdministration

# Stop and remove existing site and app pool
if (Get-Website -Name $SiteName -ErrorAction SilentlyContinue) {
    Write-Host "Removing existing IIS site: $SiteName"
    Stop-Website -Name $SiteName -ErrorAction SilentlyContinue
    Remove-Website -Name $SiteName -ErrorAction SilentlyContinue
}

if (Get-WebAppPool -Name $SiteName -ErrorAction SilentlyContinue) {
    Write-Host "Removing existing App Pool: $SiteName"
    Remove-WebAppPool -Name $SiteName -ErrorAction SilentlyContinue
}

# Delete or preserve existing folder
if ($CleanPublishFolder) {
    if (Test-Path $PublishPath) {
        Write-Host "Deleting existing folder: $PublishPath"
        Remove-Item $PublishPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $PublishPath | Out-Null
    Write-Host "Copying files from $SourcePath to $PublishPath (FULL CLEAN)"
    Robocopy $SourcePath $PublishPath /MIR /NP /NDL /NJH /NJS
}
else {
    if (-not (Test-Path $PublishPath)) {
        Write-Host "Target folder doesn't exist, creating: $PublishPath"
        New-Item -ItemType Directory -Path $PublishPath | Out-Null
    }
    Write-Host "Copying files from $SourcePath to $PublishPath (SAFE UPDATE, keeping App_Data)"
    Robocopy $SourcePath $PublishPath /E /XO /XD "$excludedFolder" /NP /NDL /NJH /NJS
}

# Create App Pool
Write-Host "Creating App Pool: $SiteName"
New-WebAppPool -Name $SiteName -Force | Out-Null
Set-ItemProperty "IIS:\\AppPools\\$SiteName" -Name "managedRuntimeVersion" -Value ""

# Create Website
Write-Host "Creating IIS Site: $SiteName on port $Port"
New-Website -Name $SiteName -Port $Port -PhysicalPath $PublishPath -ApplicationPool $SiteName -Force | Out-Null

# Set permissions
Write-Host "Setting permissions on $PublishPath"
$acl = Get-Acl $PublishPath
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)
Set-Acl -Path $PublishPath -AclObject $acl

# Start site
Write-Host "Starting website: $SiteName"
Start-Website -Name $SiteName

Write-Host "`n✅ Backend '$SiteName' deployed successfully on port $Port"
