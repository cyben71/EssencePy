# EssencePy releases

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
