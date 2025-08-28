# EssencePy releases

## Version 2.1.0 (2025-08-XX)

### Releases - Description
Add function to load your own class more easily. Function is directly available in epy context. 
Add current date in log files name
Add scripts to load dependencies without virtualenv & Fix minor issues 

```textile
1) Upgrade 'README.md' and 'RELEASE.md'
2) Under './lib/bootstrap/' directory:
   + Add function 'load_cls' in 'init_code.py'
   + Declare function 'load_cls' in 'bootstrap.py'
   + Declare function signature 'context.py'
3) Under './lib' directory:
   + Add file 'my_dummy_class.py' for example
4) Under './notebooks' and ./app:
   > Update notebook and program with and example of this new function
5) Under '.scripts'
   > Rename 'project-init' script to 'venv_create'
   > Fix issue detecting python folder between parent_home or virtual env.
   > Update all scripts for adding current date in log files name (ex: win_setup_env.log -> win_setup_env_2025-08-25.log)
   > Enhance display of log files
   > Add scripts to deploy python dependencies (packages) without python virtualenv (or venv-create script)
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
