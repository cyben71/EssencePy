#!/bin/bash
set -e  # Stop the script on error

#############
# FUNCTIONS #
#############
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" | tee -a "${LOG_FILE}"
}

############
# SETTINGS #
############
APPLICATION_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONF_DIR="${APPLICATION_HOME}/conf"

LOG_FILE="${APPLICATION_HOME}/log/setup_env.log"
mkdir -p "$(dirname "${LOG_FILE}")"

# Chargement du fichier env.conf
if [ -f "${CONF_DIR}/env.conf" ]; then
    . "${CONF_DIR}/env.conf"
else
    log_message "❌ Error : Config file '${CONF_DIR}/env.conf' not found."
fi

# ======================================================================== #

# Checking Python exec
if ! command -v ${PARENT_PYTHON_HOME}/bin/${PARENT_PYTHON_EXE} &> /dev/null; then
    log_message "❌ Python program not found in: (${PARENT_PYTHON_HOME}/bin/${PARENT_PYTHON_EXE})."
    exit 1
fi

# Creating virtual env for Python
log_message "🔧 Creating Python virtual env..."
${PARENT_PYTHON_HOME}/bin/${PARENT_PYTHON_EXE} -m venv "${VENV_PYTHON_DIR}"

# Enabling virtual env
source "${VENV_PYTHON_DIR}/bin/activate"

# Pip updating
log_message "🔄 Updating Pip..."
pip install --upgrade pip

# Installation of Jupyter and dependances
if [ -f "${CONF_DIR}/requirements.txt" ]; then
    log_message "📦 Python dependences installation..."
    pip install -r "${CONF_DIR}/requirements.txt"
else
    log_message "🟠 No requirement.txt file found. Only Jupyter will be installed"
    pip install jupyter
fi

# Test
if ! jupyter --version &> /dev/null; then
    log_message "❌ Error : Jupyter installation failed"
    exit 1
else
    log_message "✅ Jupyter installation successfully installed"
fi

log_message "🎉 Python virtual environment is ready !"
log_message "--- END OF PROCESS ---"
