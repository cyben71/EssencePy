<#
    .SYNOPSIS
    Intializing project

    .DESCRIPTION
    Create a Python virtualenv with dependencies stored to 'conf/requirements.txt'. Python package 'jupyter' is loaded by default to allow you to start to dev and run.

    .INPUTS
    List of Python packages stored in 'conf/requirements.txt'

    .OUTPUTS
    A new folder 'rt/' is created in this tree and contains all executables files for dev and run Python program

    .EXAMPLE
    ./scripts/powershell/venv_create.ps1
#>

#################
### FUNCTIONS ###
#################
function LogMessage {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Write-Output $logEntry | Tee-Object -FilePath $LOG_FILE -Append
}

################
### SETTINGS ###
################

# ------------------------------------------------------------------------ #
# Encoding: forces the console to decode using UTF-8, regardless of the
# terminal used (cmd, native PowerShell, VSCode). Without this,
# accented characters/emojis written by Python (PYTHONUTF8=1, below)
# are decoded incorrectly by the console -> mojibake.
# ------------------------------------------------------------------------ #
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ------------------------------------------------------------------------ #
# Prevents the "error" formatting (red text) that PowerShell 7.3+ applies
# by default to any native command writing to stderr with a non-zero
# exit code (Python tracebacks trigger this behavior).
# Has no effect on PowerShell 5.1, which does not recognize this variable.
# ------------------------------------------------------------------------ #
$PSNativeCommandUseErrorActionPreference = $false

# Finding APPLICATION_HOME by going up folders until we find bootstrap.py in lib/bootstrap/ directory
$currentDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
while ($true) {
    $candidate = Join-Path $currentDir "lib/bootstrap/bootstrap.py"
    if (Test-Path $candidate) {
        $env:APPLICATION_HOME = $currentDir
        Write-Host "APPLICATION_HOME: $env:APPLICATION_HOME"
        break
    }

    $parentDir = Split-Path $currentDir -Parent
    if ($parentDir -eq $currentDir) {
        Write-Host "[ERROR] : Fail to find bootstrap.py"
        exit 1
    }
    $currentDir = $parentDir
}

$CONF_DIR = Join-Path $env:APPLICATION_HOME "conf"
$CONF_FILE = Join-Path $CONF_DIR "env.conf"
$LOG_DIR = Join-Path $env:APPLICATION_HOME "log"
$CUR_DATE = $timestamp = Get-Date -Format "yyyy-MM-dd"
$LOG_FILE = Join-Path $LOG_DIR "win_setup_env_$CUR_DATE.log"

# ------------------------------------------------------------------------ #

LogMessage "# ==================================== #"
LogMessage "# === CREATING PYTHON VIRTUAL ENV ===  #"
LogMessage "# ==================================== #"
LogMessage ""

# create log folder if not exists and log file
if (!(Test-Path -Path $LOG_DIR -PathType Container)) {
    New-Item -Path $LOG_DIR -ItemType Directory
}
New-Item -ItemType Directory -Path (Split-Path $LOG_FILE) -Force | Out-Null

# Check config file "env.conf" exists
if (!(Test-Path -Path $CONF_FILE -PathType Leaf)){
    LogMessage "Error !!! File conf/env.conf not found."
    exit 1
}
else {
    LogMessage "Config file location is: $CONF_FILE"
}
LogMessage ""

# Loading config file "env.conf"
Get-Content $CONF_FILE | ForEach-Object {
    # Check line starting with "WIN_"
    if ($_ -match "^WIN_") {
        # Get variable name only without prefix "WIN_"
        $variableName = $_ -replace "^WIN_", "" -split "=" | Select-Object -First 1
        # Get variable values
        $value = $_ -split "=" | Select-Object -Last 1
        # Create variable with name and value (deleting "" caracters and trim)
        Set-Variable -Name $variableName -Value $value.Trim('"').Trim()
    }
    $VENV_PYTHON_DIR = Join-Path $env:APPLICATION_HOME "rt"
}
Set-Variable -Name "VENV_PYTHON_DIR" -Value $VENV_PYTHON_DIR
Set-Variable -Name "VENV_PYTHON_EXE" -Value $PARENT_PYTHON_EXE

# ------------------------------------------------------------------------ #
# CA bundle optionnel : si le projet definit WIN_CA_BUNDLE dans conf/env.conf
# (chemin absolu, ou relatif a APPLICATION_HOME) et que le fichier existe,
# on l'utilise comme CA additionnel pour pip/Python (SSL_CERT_FILE /
# REQUESTS_CA_BUNDLE / PIP_CERT). Reste inactif si la variable n'est pas
# definie : ne concerne que les projets qui en ont besoin (ex: proxy
# d'inspection SSL d'entreprise) sans rien imposer aux autres.
# ------------------------------------------------------------------------ #
if ($CA_BUNDLE) {
    $caBundlePath = $CA_BUNDLE
    if (-not [System.IO.Path]::IsPathRooted($caBundlePath)) {
        $caBundlePath = Join-Path $env:APPLICATION_HOME $caBundlePath
    }
    if (Test-Path -Path $caBundlePath -PathType Leaf) {
        $env:SSL_CERT_FILE = $caBundlePath
        $env:REQUESTS_CA_BUNDLE = $caBundlePath
        $env:PIP_CERT = $caBundlePath
        LogMessage "CA bundle applique : $caBundlePath"
    } else {
        LogMessage "Attention : WIN_CA_BUNDLE defini mais fichier introuvable : $caBundlePath"
    }
}

# Checking variables
$variableNames = @("PARENT_PYTHON_HOME", "PARENT_PYTHON_EXE", "VENV_PYTHON_DIR", "VENV_PYTHON_EXE")

# Display variables 
foreach ($name in $variableNames) {
    $var = Get-Variable -Name $name -ValueOnly
    LogMessage "$name : $var"
}
LogMessage ""

# ======================================================================== #
# ======================================================================== #

# Checking parent python exec
$python = Join-Path $PARENT_PYTHON_HOME $PARENT_PYTHON_EXE
if (!(Test-Path -Path $python -PathType Leaf)){
    LogMessage "Error !!! Python exec not found"
}
else {
    LogMessage "Python exec: $python"
}
LogMessage

# creating python virtual env and enabling (after end of creating)
LogMessage "-----------------------------------------------"
LogMessage "---- Creating of virtual python environment ---"
LogMessage "-----------------------------------------------"

# launch command directly with args and get back return code
& $python -m venv $VENV_PYTHON_DIR      
$status = $LASTEXITCODE
if ($status -eq 0){
    Invoke-Expression $VENV_PYTHON_DIR\Scripts\Activate.ps1
    $python_venv = Join-Path $VENV_PYTHON_DIR "Scripts\python.exe"
    LogMessage "Python virtual env successfully created and enabled"
}
else {
    LogMessage "Error !!! Python virtual env fail to created and enabled"
    exit 1
}

# pip update
LogMessage "Updating PIP..."
& $python_venv -m pip install --upgrade pip
$status = $LASTEXITCODE
if ($status -eq 0){
    LogMessage "PIP update successfully done"
}
else {
    LogMessage "Error !!! Fail to update PIP"
}

# install dependencies
LogMessage "Python dependencies installation"
if (!(Test-Path -Path $CONF_DIR\requirements.txt -PathType Leaf)){
    LogMessage "No requirement.txt file found"
}
else {
    & $python_venv -m pip install -r $CONF_DIR\requirements.txt
    $status = $LASTEXITCODE
}

# checking result of installation
if ($status -eq 0){
    LogMessage "Python dependencies successully installed"
    LogMessage ""
}
else {
    LogMessage "Error !!! Fail to install Python dependencies"
    exit 1
}

# # testing
# LogMessage "Checking Jupyter..."
# $jupyter = Join-Path $VENV_PYTHON_DIR "Scripts\jupyter.exe"
# if ((Test-Path -Path $jupyter -PathType Leaf)){
#     & $jupyter --version
#     $status = $LASTEXITCODE
#     if ($status -eq 0){
#         LogMessage "Jupyter successfully installed"
#         LogMessage "Python virtual env is ready!"
#     }
#     else {
#         LogMessage "Error !!! Jupyter fail to be installed"
#     }
# }
# else {
#     LogMessage "Error !!! Jupyter exec not found"
#     exit 1
# }

LogMessage "Python virtual environment is ready !"

LogMessage ""
LogMessage "# === END OF PROCESS === #"
LogMessage ""