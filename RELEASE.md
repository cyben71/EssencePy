# EssencePy releases

## Version 2.2.1 (2026-MM-DD)

### Releases - Description
Add a new class in EPY for generating technical documentation of current project or a specific class/module. <br>

```textile
1) Upgrade 'RELEASE.md' & 'README.md'
2) Under './lib/bootstrap/' directory:
   > Enhancing `CfgProperties` class by handling dotenv file (version 1.1.0)
   > Enhancing `CfgYaml` class by handling dotenv file (version 1.1.0)
   > Adding new functions to copy and move files in `AppEnv` class (version 1.0.3)
3) Under './notebooks/' directory:
   + Adding explainations for environment variable resolution order
4) Under './docs/' directory:
   + Adding document for deploying Python without administrator's rights 
5) Under './scripts/' directory:
   > Translating comments (FR -> US) on all powershell scripts
   > Enhancing 'app-start.ps1' to be called by a run.bat regardless of where the script was called from (batch file, scheduler, etc.)
   > Enhancing powershell scripts for better displaying and handling CA_BUNDLE file for corporate SSL inspection proxies (ex: Zscaler)
   + Adding 'run.bat' script which can be used by Windows scheduler
```

## Version 2.2.0 (2026-04-21)

### Releases - Description
Add a new class in EPY for generating technical documentation of current project or a specific class/module. <br>
Fix security problem from subprocess. <br>
Refactoring Logger class. <br>
Improving retrieval of environment variables under Windows & Linux (cfgProperties & cfgYaml)

```textile
1) Upgrade 'RELEASE.md'
2) Under './lib/bootstrap/' directory:
   + Add new module file 'docgenerator.py' with class 'DocGenerator' (version 1.0.0)
   > Declare new modules files in 'init_code.py' and 'context.py'
   > Refactoring `Logger` class using stdlib and adding set_level and debug functions (version 2.0.0)
   > Enhancing `CfgProperties` class by deleting subprocess call (version 1.0.2)
   > Enhancing `CfgYaml` class by adding recursive search for environment's variables (version 1.0.2)
   > Enhancing `AppEnv` class to being more efficient for retreieving environment's variables (version 1.0.2)
3) > Fix tipo in docstrings for all module files
```

## Version 2.1.0 (2025-08-28)

### Releases - Description
Add function to load your own class more easily. Function is directly available in epy context. 
Add current date in log files name
Add scripts to load dependencies without virtualenv & Fix minor issues 

```textile
1) Upgrade 'README.md' and 'RELEASE.md'
2) Under './lib/bootstrap/' directory:
   + Add function 'log' (without prefix) in 'logger.py'
   + Add function 'load_cls' in 'init_code.py'
   + Declare function 'load_cls' in 'bootstrap.py'
   + Declare function signature 'context.py'
3) Under './lib' directory:
   + Add file 'my_dummy_class.py' for example
4) Under './notebooks' and ./app:
   > Update notebook and program with and example of this new function
5) Under '.scripts'
   > Rename 'project-init' scripts to 'venv_create' (both powershell & shell)
   > Update all scripts for adding current date in log files name (ex: win_setup_env.log -> win_setup_env_2025-08-25.log)
   > Enhance display of log files
   > Add scripts to deploy python dependencies (packages) without python virtualenv (or venv-create script)
   > Fix issue using 'pip' exec on Linux OS (pip -> pip3)
   > Fix issue detecting python folders between parent_home or virtual_env.
```

## Version 2.0.0 (2025-08-06)

### Releases - Description
Add a bootstrap and python context mecanisms 

```textile
1) Upgrade 'README.md'
2) Add 'RELEASES.md' files       # follow updates 
3) Under './lib/':
    + Add 'bootstrap' subdirectory
    + Add 'my_dummy_class.py'    # for testing a new class outside of bootstrap
4) Under './lib/bootstrap/' directory
    + Add file 'bootstrap.py'    # contains methods and functions to create and load a Python context
    + Add file 'context.py'      # defines context
    + Rebuild complete 'init_code.py' to use bootstrap mecanism and add a summarize function
    -/+ Move files [cfgyaml.py, cfgproperties.py, appenv.py, logger.py] from './lib/init/' to './lib/bootstrap/'
    > Fix all moved files to use bootstrap and context
    - Cleaning deprecated methods and functions from 'appenv.py'
    - Add get_system() function in 'appenv.py
    > Fix encoding caracters for log files in logger.py
5) Under './notebooks':
   > Fix all init cells from notebooks to use bootstrap and context
6) Under './scripts/shell':
   > Fix all scripts to use bootstrap and recursive search for APPLICATION_HOME
7) Under './scripts/powershell':
   > Fix all scripts to use bootstrap and recursive search for APPLICATION_HOME 
```

## Version 1.0.0 (2025-04-29)

### Releases - Description

Initial commit

```
EssencePy/ 
├── app/            # Python applications folder
├── config/         # Configuration files (.yaml, .properties, etc.) 
├── lib/            # Core Python libraries 
│ └── init/         # Autoloaded classes (e.g., ConfigLoader, AppEnv, etc.) 
├── logs/           # Application logs  (folder automatically created if not existing)
├── notebooks/      # Jupyter notebooks for development or analysis 
├── scripts/        # Core executable scripts
│ ├── shell/        # Scripts for Linux OS
│ └── powershell/   # Scripts for Windows OS
└── README.md
```
