#!/bin/bash
set -e  # Stop the script on error

#############
# FUNCTIONS #
#############
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" | tee -a "${LOG_FILE}"
}

###############################
# APPLICATION_HOME AND CONFIG #
###############################

# starting point. current script is launched from this folder
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# going up folders until we find bootstrap.py in lib/bootstrap/ directory
while [ "$current_dir" != "/" ]; do
    candidate="$current_dir/lib/bootstrap/bootstrap.py"
    if [ -f "$candidate" ]; then
        export APPLICATION_HOME="$current_dir"
        echo "APPLICATION_HOME: $APPLICATION_HOME"
        break
    fi
    current_dir="$(dirname "$current_dir")"
done

# Checking
if [ -z "${APPLICATION_HOME:-}" ]; then
    echo "❌  Error : Fail to find init_code.py"
    exit 1
fi

CONF_DIR="${APPLICATION_HOME}/conf"

LOG_FILE="${APPLICATION_HOME}/log/setup_env.log"
mkdir -p "$(dirname "${LOG_FILE}")"

# ------------------------------------------------------------------------ #

log_message "# ============================= #"
log_message "# === INITIALIZING PROJECT ==== #"
log_message "# ============================= #"
log_message ""

# Chargement du fichier env.conf
if [ -f "${CONF_DIR}/env.conf" ]; then
    source "${CONF_DIR}/env.conf"
    log_message "Config file location is : ${CONF_DIR}/env.conf"
else
    log_message "❌  Error : Config file '${CONF_DIR}/env.conf' not found."
    exit 1
fi

# Set Virtual Python env variables
VENV_PYTHON_DIR="${APPLICATION_HOME}/rt"
VENV_PYTHON_EXE="${PARENT_PYTHON_EXE}"

# Display variables
log_message "PARENT_PYTHON_HOME : ${PARENT_PYTHON_HOME}"
log_message "PARENT_PYTHON_EXE : ${PARENT_PYTHON_EXE}"
log_message "VENV_PYTHON_DIR : ${VENV_PYTHON_DIR}"
log_message "VENV_PYTHON_EXE : ${PARENT_PYTHON_EXE}"

# ======================================================================== #
# ======================================================================== #

# Checking Python exec
if ! command -v ${PARENT_PYTHON_HOME}/bin/${PARENT_PYTHON_EXE} &> /dev/null; then
    log_message "❌  Python program not found in: (${PARENT_PYTHON_HOME}/bin/${PARENT_PYTHON_EXE})."
    exit 1
fi

log_message "-----------------------------------------------"
log_message "---- Creating of virtual python environment ---"
log_message "-----------------------------------------------"

# Creating virtual env for Python
log_message "🔧  Creating Python virtual env..."
${PARENT_PYTHON_HOME}/bin/${PARENT_PYTHON_EXE} -m venv ${VENV_PYTHON_DIR}

# Enabling virtual env
source "${VENV_PYTHON_DIR}/bin/activate"

# Pip updating
log_message "🔄  Updating Pip..."
pip install --upgrade pip

# Installation of Jupyter and dependances
if [ -f "${CONF_DIR}/requirements.txt" ]; then
    log_message "📦  Python dependences installation..."
    pip install -r "${CONF_DIR}/requirements.txt"
else
    log_message "🟠  No requirement.txt file found. Only Jupyter will be installed"
    pip install jupyter
fi

# Test
if ! jupyter --version &> /dev/null; then
    log_message "❌  Error : Jupyter installation failed"
    exit 1
else
    log_message "✅  Jupyter installation successfully installed"
fi

log_message "🎉  Python virtual environment is ready !"

log_message ""
log_message "# === END OF PROCESS === #"
log_message ""
