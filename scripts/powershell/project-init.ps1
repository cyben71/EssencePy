### FUNCTIONS ###
function LogMessage {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Write-Output $logEntry | Tee-Object -FilePath $LOG_FILE -Append
}

### SETTINGS ###
#$current_path = (Get-Item .)
$current_path = (Get-Item $MyInvocation.MyCommand.Path).Directory.FullName
Write-Output "current_path: $current_path"

#$APPLICATION_HOME = $current_path.Parent.FullName
$APPLICATION_HOME = (Get-Item (Join-Path $current_path "..\..")).FullName
Write-Output "APPLICATION_HOME: $APPLICATION_HOME"

$CONF_DIR = "{0}\{1}" -f $APPLICATION_HOME, "conf"
$CONF_FILE = "{0}\{1}" -f $APPLICATION_HOME, "conf\env.conf"
$LOG_DIR = "{0}\{1}" -f $APPLICATION_HOME, "log"
$LOG_FILE = "{0}\{1}" -f $LOG_DIR, "setup_env_win.log"

# create folder if not exists
if (!(Test-Path -Path $LOG_DIR -PathType Container)) {
    New-Item -Path $LOG_DIR -ItemType Directory
}

# loading config file "env.conf"
if (!(Test-Path -Path $CONF_FILE -PathType Leaf)){
    LogMessage "Error !!! File conf/env.conf not found."
    exit 1
}
else {
    LogMessage "Config file location is: $CONF_FILE"
}

# Reading for config file for Windows
Get-Content $CONF_FILE | ForEach-Object {
    # checking line with "WIN_"
    if ($_ -match "^WIN_") {
        # getting variable name only (without WIN_)
        $variableName = $_ -replace "^WIN_", "" -split "=" | Select-Object -First 1
        # getting value
        $value = $_ -split "=" | Select-Object -Last 1
        # creating variable with name and value
        Set-Variable -Name $variableName -Value $value.Trim()
    }
    $VENV_PYTHON_DIR = "{0}\{1}" -f $APPLICATION_HOME, "rt\python"
}
Set-Variable -Name "VENV_PYTHON_DIR" -Value $VENV_PYTHON_DIR
Set-Variable -Name "VENV_PYTHON_EXE" -Value $PARENT_PYTHON_EXE

# testing new variables
$variableNames = @("PARENT_PYTHON_HOME", "PARENT_PYTHON_EXE", "VENV_PYTHON_DIR", "VENV_PYTHON_EXE")

# displaying new variables values
foreach ($name in $variableNames) {
    $var = Get-Variable -Name $name -ValueOnly
    LogMessage "$name : $var"
}
# ======================================================================== #

# Checking Python exec
$python = "{0}\{1}" -f $PARENT_PYTHON_HOME, $PARENT_PYTHON_EXE
if (!(Test-Path -Path $python -PathType Leaf)){
    LogMessage "Error !!! Python exec not found"
}
else {
    LogMessage "Python exec: $python"
}
LogMessage

# creating python virtual env and enabling (after end of creating)
LogMessage "===== Python virtual env creating ====="
& $python -m venv $VENV_PYTHON_DIR      # launch command directly with args and get back return code
$status = $LASTEXITCODE
if ($status -eq 0){
    Invoke-Expression $VENV_PYTHON_DIR\Scripts\Activate.ps1
    $python_venv = "{0}\{1}" -f $VENV_PYTHON_DIR, "Scripts\python.exe"
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

# install dependances
LogMessage "Python dependances installation"
if (!(Test-Path -Path $CONF_DIR\requirements.txt -PathType Leaf)){
    LogMessage "No requirement.txt file found. Only Jupyter will be installed"
}
else {
    & $python_venv -m pip install -r $CONF_DIR\requirements.txt
    $status = $LASTEXITCODE
    if ($status -eq 0){
        LogMessage "Python dependances successully installed"
    }
    else {
        LogMessage "Error !!! Fail to install Python dependances"
        exit 1
    }
}

# testing
LogMessage "Checking..."
$jupyter = "{0}\{1}" -f $VENV_PYTHON_DIR, "Scripts\jupyter.exe"
if ((Test-Path -Path $jupyter -PathType Leaf)){
    & $jupyter --version
    $status = $LASTEXITCODE
    if ($status -eq 0){
        LogMessage "Jupyter  successfully installed"
        LogMessage "Python virtual env is ready!"
    }
    else {
        LogMessage "Error !!! Jupyter fail to be installed"
    }
}
else {
    LogMessage "Error !!! Jupyter exec not found"
    exit 1
}
LogMessage "--- END OF PROCESS ---"