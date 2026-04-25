# Technical documentation – DEMO_DocGenerator

> [!NOTE]
> _This file was automatically created by EssencePy_

## Module `lib.bootstrap.appenv`

*Source* : `C:\cyben71\PYTHON_PROJECT\EssencePy\lib\bootstrap\appenv.py`


### Class `AppEnv`

A tool class to get information about the execution environment.
Handles OS detection, date/time utilities, file system helpers,
and user environment variable loading for any context:
local, remote, interactive or non-interactive (JupyterLab, VS Code remote, systemd).

On Linux  : parses ~/.bash_env, ~/.bashrc, ~/.bash_profile, ~/.profile
and injects ALL exported variables into os.environ (overwrite enabled).
On Windows: captures full os.environ snapshot (already populated by the OS).

Calling load() or relaunching init_env() always produces a fresh, complete snapshot.

- **get_current_date(pattern: Optional[str] = None) -> str**

    Return current date (default format: %Y-%m-%d).



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `pattern (str, optional)` | Pattern for displaying date. |


    **Returns**

    - str: Current date with chosen pattern.

    **Example**

    ```python
    date1 = epy.appenv.get_current_date(pattern='%Y-%m-%d')
    date2 = epy.appenv.get_current_date(pattern='%d/%m/%Y')
    ```
- **get_current_time(pattern: Optional[str] = None) -> str**

    Return current time (default format: %H:%M:%S).



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `pattern (str, optional)` | Pattern for displaying time. |

    **Returns**

    - str: Current time with chosen pattern.
- **get_hostname() -> str**

    Return hostname.
- **get_system() -> str**

    Return type of system.
- **is_file_exists(location: str) -> bool**

    Check if a file exists at specified location.



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `location (str)` | File location. |

    **Returns**

    - bool: True if file exists, False otherwise.
- **is_folder_exists(location: str) -> bool**

    Check if a folder exists at specified location.



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `location (str)` | Folder location. |

    **Returns**

    - bool: True if folder exists, False otherwise.
- **load(self) -> Dict[str, str]**

    Load (or reload) all environment variables into os.environ.

    Always performs a full reload — existing values in os.environ
    are overwritten if a newer value is found in the profile files.
    Call this after modifying ~/.bash_env or any shell profile,
    without restarting the kernel.



    **Returns**

    - Dict[str, str]: Full snapshot of loaded variables.

    **Example**

    ```python
    # Initial load (called automatically at init)
    epy = init_env()

    # After modifying ~/.bash_env in your terminal:
    epy.appenv.load()
    print(epy.appenv.loaded_vars)
    ```
- **mkdir(location: str) -> bool**

    Create a folder at specified location.



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `location (str)` | Folder location to create. |

    **Returns**

    - bool: True if successfully created, False otherwise.
- **rm_file(location: str) -> bool**

    Delete a file if it exists.



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `location (str)` | File location. |

    **Returns**

    - bool: True if successfully deleted, False otherwise.

## Module `lib.bootstrap.cfgproperties`

*Source* : `C:\cyben71\PYTHON_PROJECT\EssencePy\lib\bootstrap\cfgproperties.py`


### Class `ConfigProperties`

Class for handling config files application.properties and env.conf.
Allow to load config files, replace placeholders behind ${VAR} by OS env vars values or from other config keys included in config files.
A recurse method is set to solve all crossed references from ${VAR}.

Config files used by this class:
- conf/env.conf : mainly storing python environment variables like python executer location.
- conf/application.properties : contains properties used par application.

- **get(self, key: str, default: Optional[str] = None, strip_values: bool = True) -> Any**

    Getting value from a specified key with handling of environment variables and empty string stripping.



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `key (str)` | Key to find in current config context |
    | `default (str, optionnal)` | Default string to return if searched key is not found |
    | `strip_values (bool, optionnal)` | Enabling string stripping (True by default) |

    **Returns**

    - str: Value associated to searched key. Default value if key is not found.

## Module `lib.bootstrap.cfgyaml`

*Source* : `C:\cyben71\PYTHON_PROJECT\EssencePy\lib\bootstrap\cfgyaml.py`


### Class `ConfigYaml`

Class for handling config files application.yaml.

Config files used by this class:
- conf/application.yaml : contains properties used by application

- **get(self, key: str, default: Optional[str] = None, root: Optional[Dict[str, Any]] = None, strip_values: Optional[bool] = None) -> Any**

    Get value from a specified key coming from a yaml file.
    Can handled:
    - imbricated path (ex: customer.given)
    - string stripping



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `key (str)` | Path of key to look for (ex: 'customer.given') |
    | `default (str, optional)` | Default value if key is not found (by default = None) |
    | `root (dict, optional)` | Data root for internal solving (by default: self._config) |
    | `strip_values (bool, optional)` | Enabling string stripping (True by default) |

    **Returns**

    - Associated value from a key

## Module `lib.bootstrap.context`

*Source* : `C:\cyben71\PYTHON_PROJECT\EssencePy\lib\bootstrap\context.py`


### Class `Context`

Allow to display properly modules or main variables into a context called 'epy'.
Usefull for IDE like Vscode.

- **load_class(self, module_name: str, class_name: str, args: list[typing.Any] = []) -> Any**

    Allow to load and instanciate your own python class (outside of lib/bootstrap).



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `module_name (str)` | Module name (without extension) to load. Ex: module_name = 'my_dummy_class' |
    | `class_name (str, optional)` | Class name to load. Defaults to None. |
    | `args (list, optional)` | List of arguments required by module. Defaults to []. |


    **Returns**

    - cls (object): a properly loaded module with its class

    **Example**

    ```python
    # Load my custom class
    cls = epy.load_class(module_name='my_dummy_class', args=[epy, APPLICATION_NAME])
    ```

## Module `lib.bootstrap.docgenerator`

*Source* : `C:\cyben71\PYTHON_PROJECT\EssencePy\lib\bootstrap\docgenerator.py`


### Class `DocGenerator`

EPY service responsible for generating technical documentation.
Class for handling documentation about Python modules in current project

This class introspects both EssencePy internal modules (bootstrap)
and user-defined modules (lib/) to extract:
- public classes
- public methods
- associated docstrings

The output is a Markdown file.

- **generate(self, target_module=None, output_filename=None) -> None**

    Generate the technical documentation of current project or a specified module/class.
    Output files will be stored into `<application_home>/docs`.



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `target_module (str, optional)` | module or class name (None for document everything) |
    | `output_filename (str, optional)` | Output filename (None = <application_name>_technical_doc.md) |

    **Example**

    ```python
    # Generate full project documentation with default output name 
    epy.doc.generate()

    # Generate full project documentation with custom output name
    epy.doc.generate(output_filename='my_custom_doc.md')

    # Generate module documentation with custom output name
    epy.doc.generate(target_module='my_dummy_class', output_filename='my_dummy_class.md')
    ```

## Module `lib.bootstrap.logger`

*Source* : `C:\cyben71\PYTHON_PROJECT\EssencePy\lib\bootstrap\logger.py`


### Class `Logger`

Class for handling application logging using Python stdlib logging module.
Writes to both a rotating log file and the console (configurable).

Log file is automatically created in <app_home>/log/ folder.
File rotation is triggered when file size exceeds max_bytes (default: 5MB),
keeping up to backup_count previous files.

- **debug(self, message: str) -> None**

    Output a debug message (only visible when log level is DEBUG).



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `message (str)` | Message to output. |

    **Example**

    ```python
    epy.log.debug("Variable x = 42")
    ```
- **error(self, message: str) -> None**

    Output a message with 'ERROR' prefix.



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `message (str)` | Message to output. |

    **Example**

    ```python
    epy.log.error("Failed to connect to database")
    ```
- **info(self, message: str) -> None**

    Output a message with 'INFO' prefix.



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `message (str)` | Message to output. |

    **Example**

    ```python
    epy.log.info("Application started")
    ```
- **log(self, message: str) -> None**

    Output a message in log file without prefix.



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `message (str)` | Message to output. |

    **Example**

    ```python
    epy.log.log("Simple message, no prefix")
    ```
- **set_level(self, level: str) -> None**

    Change the log level at runtime.



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `level (str)` | Log level. Accepted values: 'DEBUG', 'INFO', 'WARNING', 'ERROR'. |

    **Example**

    ```python
    epy.log.set_level("DEBUG")
    ```
- **warning(self, message: str) -> None**

    Output a message with 'WARNING' prefix.



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `message (str)` | Message to output. |

    **Example**

    ```python
    epy.log.warning("Config file not found, using defaults")
    ```

## Module `my_dummy_class`

*Source* : `C:\cyben71\PYTHON_PROJECT\EssencePy\lib\my_dummy_class.py`


### Class `Dummy`

Just a dummy python class outside of /bootstrap for example.

- **dummy_function(self, arg1: str) -> str**

    Just a dummy function.



    **Arguments**

    | Name | Description |
    |------|-------------|
    | `arg1 (str)` | A very simple argument attended as function's input |

    **Returns**

    - str: Result of function