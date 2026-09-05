# ==========================================
# Library Management System - Run Script
# ==========================================

$Project = "C:\Users\user\OneDrive\Desktop\Library  Management"
$Tomcat = "C:\Program Files\Apache Software Foundation\Tomcat 10.1"
$Deploy = "$Tomcat\webapps\LibraryManagementSystem"

Write-Host ""
Write-Host "=========================================="
Write-Host "   LIBRARY MANAGEMENT SYSTEM"
Write-Host "=========================================="
Write-Host ""

# Go to project
Set-Location $Project

# Set Java
$env:JAVA_HOME = "C:\Program Files\Java\jdk-25.0.2"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

# ------------------------------------------
# 1. Clean compiled classes
# ------------------------------------------

Write-Host "[1/6] Cleaning old compiled classes..."

Remove-Item ".\WEB-INF\classes\*" -Recurse -Force -ErrorAction SilentlyContinue

# ------------------------------------------
# 2. Compile Java Servlets
# ------------------------------------------

Write-Host "[2/6] Compiling Java Servlets..."

javac -cp "$Tomcat\lib\servlet-api.jar;$Tomcat\lib\mysql-connector-j-*.jar" `
      -d ".\WEB-INF\classes" `
      .\src\*.java

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "COMPILATION FAILED" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "Compilation successful" -ForegroundColor Green

# ------------------------------------------
# 3. Deploy complete WEB-INF
# ------------------------------------------

Write-Host "[3/6] Deploying WEB-INF..."

$DeployClasses = "$Deploy\WEB-INF\classes"

# Make sure deployment folders exist
New-Item -ItemType Directory -Force "$Deploy\WEB-INF" | Out-Null
New-Item -ItemType Directory -Force $DeployClasses | Out-Null

# Copy compiled classes
Copy-Item ".\WEB-INF\classes\*" `
          $DeployClasses `
          -Recurse `
          -Force

# Copy web.xml
if (Test-Path ".\WEB-INF\web.xml") {

    Copy-Item ".\WEB-INF\web.xml" `
              "$Deploy\WEB-INF\web.xml" `
              -Force

    Write-Host "web.xml deployed successfully" -ForegroundColor Green
}
else {
    Write-Host "web.xml NOT FOUND" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# ------------------------------------------
# 4. Deploy HTML files
# ------------------------------------------

Write-Host "[4/6] Deploying HTML files..."

Get-ChildItem $Project -Filter "*.html" | ForEach-Object {

    Copy-Item $_.FullName `
              "$Deploy\$($_.Name)" `
              -Force

}

Write-Host "HTML files deployed successfully" -ForegroundColor Green

# ------------------------------------------
# 5. Start Tomcat
# ------------------------------------------

Write-Host "[5/6] Starting Tomcat..."

Set-Location "$Tomcat\bin"

# Stop old Tomcat instance
.\shutdown.bat

Start-Sleep -Seconds 3

# Start fresh Tomcat
.\startup.bat

Write-Host ""
Write-Host "Waiting for Tomcat..." -ForegroundColor Yellow

Start-Sleep -Seconds 7

# ------------------------------------------
# 6. Open browser
# ------------------------------------------

Write-Host "[6/6] Opening Library Management System..."

Start-Process "http://localhost:8080/LibraryManagementSystem/"

Write-Host ""
Write-Host "=========================================="
Write-Host "       PROJECT STARTED SUCCESSFULLY"
Write-Host "=========================================="
Write-Host ""

Read-Host "Press Enter to close"