__version__ = "1.0.1"

import importlib.util
import inspect
import platform
import sys
from pathlib import Path
from lib.bootstrap.context import context, Context
from lib.bootstrap import cfgyaml
from lib.bootstrap import cfgproperties
from lib.bootstrap import logger
from lib.bootstrap import appenv

def init() -> None:
    # load and instanciate classes in context
    context.cfgyaml = cfgyaml.ConfigYaml(app_home=context.APPLICATION_HOME)
    context.cfgprops = cfgproperties.ConfigProperties(app_home=context.APPLICATION_HOME)
    context.appenv = appenv.AppEnv()
    context.log = logger.Logger(app_home=context.APPLICATION_HOME, app_name=context.APPLICATION_NAME)


# load classes included in /lib/bootstrap
# safe version. introspection of class arguments
def load_all(epy: Context, app_home: Path , app_name: str) -> None:
    init_dir = Path(app_home) / "lib/bootstrap"

    for file in init_dir.glob("*.py"):
        if file.name in {"__init__.py", "init_code.py", "bootstrap.py", "context.py"}:
            continue

        module_name = f"lib.bootstrap.{file.stem}"
        spec = importlib.util.spec_from_file_location(module_name, file)
        if not spec or not spec.loader:
            print(f"[load_all] - No specs found for {file.name}")
            continue

        try:
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
        except Exception as e:
            print(f"[load_all] - Error on loading module {module_name}: {e}")
            continue

        # Nom de classe par défaut : CamelCase du nom du fichier
        default_class_name = ''.join(part.capitalize() for part in file.stem.split('_'))
        cls = getattr(module, default_class_name, None)

        # Si non trouvé, chercher la première classe définie dans le module
        if cls is None:
            for attr in dir(module):
                obj = getattr(module, attr)
                if isinstance(obj, type):
                    cls = obj
                    break

        if cls is None:
            print(f"[load_all] - No class found in {file.name}")
            continue

        # Instanciation sécurisée si possible
        try:
            sig = inspect.signature(cls)
            params = sig.parameters
            if 'app_home' in params and 'app_name' in params:
                instance = cls(app_home=app_home, app_name=app_name)
                alias = getattr(cls, 'alias', file.stem)
                setattr(epy, alias, instance)
            #else:
            #    print(f"[load_all] Classe {cls.__name__} ne supporte pas app_home/app_name")
        except (ValueError, TypeError):
            print(f"[load_all] - Class {cls.__name__} can not be introspected (built-in ?)")
        except Exception as e:
            print(f"[load_all] - Error on instanciating of {cls.__name__}: {e}")


def summarize_context() -> None:
    """
    Summurizing content of context
    """
    def supports_color() -> bool:
        if sys.stdout.isatty():
            return True
        if 'ipykernel' in sys.modules:
            return True  # Notebook Jupyter
        return False

    def color(text: str, code: str) -> str:
        return f"\033[{code}m{text}\033[0m" if supports_color() else text

    python_version = platform.python_version()
    interpreter_path = sys.executable
    is_venv = sys.prefix != sys.base_prefix
    venv_info = "✅ Virtualenv actif" if is_venv else "❌ Pas de virtualenv"

    # Modules dynamically loaded in context
    module_names = [
        name for name in dir(context)
        if not name.startswith("_")
        and name not in {"app_home", "app_name"}
        and not isinstance(getattr(context, name), (str, type(None)))
    ]

    separator = "─" * 50
    print()
    print(color("🔧  Application Context Initialized", "96"))  # cyan clair
    print(color(separator, "90"))  # gris

    print(f"{color('🖥️  SYSTEM', '91')} : {platform.system()} ({platform.platform()})")
    print(f"{color('🐍  PYTHON_VERSION', '92')} : {python_version}")
    print(f"{color('🧪  INTERPRETER_PATH', '92')} : {interpreter_path}")
    print(f"{color('📦  ENVIRONMENT', '92')} : {venv_info}")
    print(f"{color('📦  EPY_MODULES', '92')} : {', '.join(sorted(module_names)) or 'None'}")

    print(f"{color('📁  APPLICATION_HOME', '93')} : {context.APPLICATION_HOME}")
    print(f"{color('📛  APPLICATION_NAME', '93')} : {context.APPLICATION_NAME}")

    # Config files dynamically loaded in context
    if hasattr(context, 'CFGENV_FILE'):
        print(f"📘  ENV file loaded : {context.CFGENV_FILE}")
    if hasattr(context, 'CFGPROPS_FILE'):
        print(f"📘  PROPERTIES file loaded : {context.CFGPROPS_FILE}")
    if hasattr(context, 'CFGYAML_FILE'):
        print(f"📘  YAML file loaded : {context.CFGYAML_FILE}")
    
    print()
    print(color("✅  Context is ready.", "92"))  # vert
    print(color(separator, "90"))