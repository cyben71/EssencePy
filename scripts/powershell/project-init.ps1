# project-init.ps1
param()

function Log-Message {
    param($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Tee-Object -FilePath $LOG_FILE -Append
}

# ================================================================

# Trouver APPLICATION_HOME
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
$LOG_FILE = Join-Path $env:APPLICATION_HOME "log/setup_env_win.log"
New-Item -ItemType Directory -Path (Split-Path $LOG_FILE) -Force | Out-Null

# Chargement du fichier env.conf
$envFile = Join-Path $CONF_DIR "env.conf"
Get-Content $envFile | ForEach-Object {
    # Vérifier si la ligne commence par "WIN_"
    if ($_ -match "^WIN_") {
        # recupération du nom de variable uniquement (sans WIN_)
        $variableName = $_ -replace "^WIN_", "" -split "=" | Select-Object -First 1
        # recupération de la valeur uniquement
        $value = $_ -split "=" | Select-Object -Last 1
        # Créer la variable avec le nom et la valeur
        #Set-Variable -Name $variableName -Value $value.Trim()
        Set-Variable -Name $variableName -Value $value.Trim('"').Trim()
    }
    #$VENV_PYTHON_DIR = "{0}\{1}" -f $APPLICATION_HOME, "rt\python"
    $VENV_PYTHON_DIR = Join-Path $env:APPLICATION_HOME "rt"
}
Set-Variable -Name "VENV_PYTHON_DIR" -Value $VENV_PYTHON_DIR
Set-Variable -Name "VENV_PYTHON_EXE" -Value $PARENT_PYTHON_EXE

# Tester les variables créées
$variableNames = @("PARENT_PYTHON_HOME", "PARENT_PYTHON_EXE", "VENV_PYTHON_DIR", "VENV_PYTHON_EXE")

Log-Message "# ============================== #"
Log-Message "# === Initialisation project === #"
Log-Message "# ============================== #"

# Afficher les valeurs des variables créées
foreach ($name in $variableNames) {
    $var = Get-Variable -Name $name -ValueOnly
    Log-Message "$name : $var"
}
Log-Message ""
# ================================================================

# Vérifier l'exécutable Python parent
#$pythonPath = Join-Path "$env:PARENT_PYTHON_HOME" $env:PARENT_PYTHON_EXE
$pythonPath = Join-Path "$PARENT_PYTHON_HOME" $PARENT_PYTHON_EXE
Log-Message "$pythonPath"
if (-not (Test-Path $pythonPath)) {
    Log-Message "[ERROR] : Python not found at: $pythonPath"
    exit 1
}

# Créer l'environnement virtuel
Log-Message "Creating Python virtual env..."
& $pythonPath -m venv $VENV_PYTHON_DIR

# Activer l'environnement virtuel
$activateScript = Join-Path $VENV_PYTHON_DIR "Scripts\Activate.ps1"
. $activateScript

# Mise à jour pip
Log-Message "[PIP-UPGRADE] Updating Pip..."
#pip install --upgrade pip
#$pipScript = Join-Path $VENV_PYTHON_DIR "Scripts\python.exe -m pip install --upgrade pip"
$pythonVenv = Join-Path $VENV_PYTHON_DIR "Scripts\python.exe"
& $pythonVenv -m pip install --upgrade pip


# Installation des dépendances
$requirements = Join-Path $CONF_DIR "requirements.txt"
if (Test-Path $requirements) {
    Log-Message "[SETUP] Installing Python dependencies..."
    pip install -r $requirements
    #& $pythonPath -m pip install -r $requirements

} else {
    Log-Message "[WARNING] No requirements.txt found. Installing Jupyter only"
    pip install jupyter
    #& $pythonPath -m pip install jupyter
}

# Vérification Jupyter
try {
    jupyter-console.exe --version | Out-Null
    Log-Message "[OK] Jupyter successfully installed"
} catch {
    Log-Message "[ERROR] : Jupyter installation failed"
    exit 1
}

Log-Message "[DONE] Python virtual environment is ready!"
Log-Message "=== END OF PROCESS ==="
