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

$CONF_FILE = "{0}\{1}" -f $APPLICATION_HOME, "conf\env.conf"
$LOG_DIR = "{0}\{1}" -f $APPLICATION_HOME, "log"
$LOG_FILE = "{0}\{1}" -f $LOG_DIR, "convert_win.log"
$NOTEBOOK_DIR = "{0}\{1}" -f $APPLICATION_HOME, "notebooks"
$APP_DIR = "{0}\{1}" -f $APPLICATION_HOME, "app"

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


# Checking argument for execution
if ($args.Count -lt 1) {
    LogMessage "Error !!! Usage: .\notebook-converter.ps1 <notebook.ipynb>"
    exit 1
}

# Get notebook file path
$Notebook = $args[0]

# Checking notebook file exists
$NotebookPath = [string]"$NOTEBOOK_DIR\$Notebook"
if (-not (Test-Path -Path $NotebookPath -PathType Leaf)) {
    LogMessage "Error !!! Notebook file to convert is missing : $NotebookPath"
    exit 1
}
LogMessage "Notebook to convert : $NotebookPath"

# create APP_DIR if not exists
if (-not (Test-Path -Path $APP_DIR -PathType Container)) {
    New-Item -ItemType Directory -Path $APP_DIR | Out-Null
}

# Converting notebook
LogMessage "Converting notebook..."
$python_venv = "{0}\{1}" -f $VENV_PYTHON_DIR, "Scripts\python.exe"
& $python_venv -m jupyter nbconvert "$NotebookPath" --to script --output-dir "$APP_DIR"

# Checking converting
$notebookName = [System.IO.Path]::GetFileNameWithoutExtension($NotebookPath)
$convertedFile = Join-Path $APP_DIR "$notebookName.py"

if (Test-Path -Path $convertedFile -PathType Leaf) {
    LogMessage "Notebook successfully converted to python. File available : $convertedFile"
} else {
    LogMessage "Error !!! Notebook converting failed. $notebookName.py not found in: $APP_DIR"
    exit 1
}
LogMessage "--- END OF PROCESS ---"