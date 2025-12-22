# lib/doc/doc_generator.py

import sys
import inspect
import importlib.util
from pathlib import Path
from textwrap import dedent

# from lib.bootstrap.init_code import load_module_for_doc


class DocGenerator:
    """
    Générateur de documentation technique EssencePy.

    Conventions :
    - lib/bootstrap : modules EPY (déjà chargés)
    - lib/          : modules utilisateurs (chargés pour documentation)
    """

    def __init__(self, app_home, output_file):
        self.application_home = Path(app_home).resolve()
        self.output_file = Path(output_file)

        self.lib_dir = self.application_home / "lib"
        self.bootstrap_dir = self.lib_dir / "bootstrap"

    # ------------------------------------------------------------------ #
    # Collecte des modules
    # ------------------------------------------------------------------ #

    def _load_module_for_doc(self, module_name, search_paths):
        """
        Charge un module uniquement pour introspection documentaire.
        """
        for base_path in search_paths:
            module_path = Path(base_path) / f"{module_name}.py"
            if module_path.exists():
                spec = importlib.util.spec_from_file_location(
                    module_name,
                    module_path
                )
                module = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(module)
                return module

        raise ModuleNotFoundError(module_name)

    def _collect_epy_modules(self):
        """Modules EPY déjà chargés (lib/bootstrap)"""
        modules = {}

        for module in sys.modules.values():
            file = getattr(module, "__file__", None)
            if not file:
                continue

            path = Path(file).resolve()

            if self.bootstrap_dir in path.parents:
                modules[module.__name__] = module

        return modules

    def _collect_user_modules(self, existing):
        """Modules utilisateurs situés dans lib/ (hors bootstrap)"""
        modules = {}

        for py in self.lib_dir.glob("*.py"):
            name = py.stem

            if name in existing:
                continue

            try:
                module = self._load_module_for_doc(
                    module_name=name,
                    search_paths=[self.lib_dir]
                )
                modules[name] = module
            except Exception as e:
                print(f"[DOC] Module ignoré {py}: {e}")

        return modules

    # ------------------------------------------------------------------ #
    # Introspection
    # ------------------------------------------------------------------ #

    def _extract_module_api(self, module):
        api = {
            "module": module.__name__,
            "file": getattr(module, "__file__", ""),
            "doc": inspect.getdoc(module),
            "functions": [],
            "classes": [],
        }

        for name, obj in inspect.getmembers(module):
            if inspect.isfunction(obj) and obj.__module__ == module.__name__:
                api["functions"].append({
                    "name": name,
                    "signature": str(inspect.signature(obj)),
                    "doc": inspect.getdoc(obj),
                })

            elif inspect.isclass(obj) and obj.__module__ == module.__name__:
                methods = []
                for m_name, m_obj in inspect.getmembers(obj, inspect.isfunction):
                    if m_obj.__qualname__.startswith(obj.__name__):
                        methods.append({
                            "name": m_name,
                            "signature": str(inspect.signature(m_obj)),
                            "doc": inspect.getdoc(m_obj),
                        })

                api["classes"].append({
                    "name": name,
                    "doc": inspect.getdoc(obj),
                    "methods": methods,
                })

        return api

    # ------------------------------------------------------------------ #
    # Markdown
    # ------------------------------------------------------------------ #

    def _to_markdown(self, apis):
        md = []
        md.append("# Documentation technique – EssencePy\n")
        md.append("_Générée automatiquement_\n")

        for api in sorted(apis, key=lambda x: x["module"]):
            md.append(f"\n## Module `{api['module']}`\n")
            md.append(f"*Source* : `{api['file']}`\n")

            if api["doc"]:
                md.append(dedent(api["doc"]) + "\n")

            for cls in api["classes"]:
                md.append(f"\n### Classe `{cls['name']}`\n")
                if cls["doc"]:
                    md.append(dedent(cls["doc"]) + "\n")

                for m in cls["methods"]:
                    md.append(f"- **{m['name']}{m['signature']}**")
                    if m["doc"]:
                        md.append(f"\n  {dedent(m['doc'])}")

            if api["functions"]:
                md.append("\n### Fonctions\n")
                for fn in api["functions"]:
                    md.append(f"- **{fn['name']}{fn['signature']}**")
                    if fn["doc"]:
                        md.append(f"\n  {dedent(fn['doc'])}")

        return "\n".join(md)

    # ------------------------------------------------------------------ #
    # API publique
    # ------------------------------------------------------------------ #

    def generate(self):
        epy_modules = self._collect_epy_modules()
        user_modules = self._collect_user_modules(epy_modules)

        all_modules = {**epy_modules, **user_modules}

        apis = [
            self._extract_module_api(m)
            for m in all_modules.values()
        ]

        self.output_file.write_text(
            self._to_markdown(apis),
            encoding="utf-8"
        )
