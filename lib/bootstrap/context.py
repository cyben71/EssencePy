__version__ = "1.0.0"

from types import SimpleNamespace
from lib.bootstrap.cfgyaml import ConfigYaml        # Use real name of Class (not filename !)
from lib.bootstrap.cfgproperties import ConfigProperties
from lib.bootstrap.appenv import AppEnv
from lib.bootstrap.logger import Logger

class Context(SimpleNamespace):
    """_summary_
    """

    APPLICATION_HOME: str
    APPLICATION_NAME: str
    cfgyaml: ConfigYaml  # Add here all classes needed
    cfgprops: ConfigProperties
    appenv: AppEnv
    log: Logger
    CFGYAML_FILE: str
    CFGENV_FILE: str
    CFGPROPS_FILE: str

# Unique instance of global context
context = Context()