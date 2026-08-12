# EssencePy
![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python)
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![Python](https://img.shields.io/badge/Python-3.14-blue?logo=python)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20Apple-lightgrey)

**EssencePy** is a lightweight and modular Python project designed to serve as a modular foundation for technical projects and automation workflows.
It brings together reusable utilities, structured code organization, and cross-platform compatibility (Linux & Windows), making it ideal for building reliable tools quickly.

> EssencePy is the *core essence* of many future tools — minimal yet extensible.

---

## 🚀 Key Features

- 🔧 **Modular Design** — Clean separation of concerns, designed for easy customization and extension.
- 🖥️ **Cross-Platform** — Compatible with both Linux and Windows environments.
- 🗂️ **Structured Setup** — Includes standard directories for logs, scripts, notebooks, configs, and reusable libraries.
- 📦 **Utilities Included** — Config reader, environment info loader, and more.
- 🧪 **Notebook/Script Ready** — Load and execute code from Jupyter or as standalone Python scripts.

---

## 📁 Project Structure (Sample)
```shell
EssencePy/ 
├── app/            # Python applications folder
├── conf/           # Configuration files (.yaml, .properties, etc.) 
├── docs/           # Documentation files (.md) 
├── lib/            # Core Python libraries
│ └── bootstrap/    # Autoloaded main classes (e.g., bootstrap, init_code, AppEnv, ConfigYaml... etc.)
├── logs/           # Application logs  (folder automatically created if not existing)
├── notebooks/      # Jupyter notebooks for development or analysis 
├── scripts/        # Core executable scripts
│ ├── shell/        # Scripts for Linux OS
│ └── powershell/   # Scripts for Windows OS
├── RELEASE.md      # Follow updates
└── README.md
```

## 📌 Goals

- Provide a reusable starting point for scripting, automation or other cool stuff
- Maintain simplicity while allowing for scalability
- Ensure portability and easy setup across environments

## 📣 About

This project started as a personal toolkit to accelerate scripting and automation tasks across various technical contexts.
Now open-sourced to share its benefits, and evolve through real-world usage.

Feel free to fork, extend, and adapt EssencePy to your own workflows. 💡

## 🛠️ How to use EssencePy
1. First of all, clone the project. 😉
2. Edit `conf/env.conf` file and **setup** location for Python binaries in **PARENT_PYTHON_HOME** (for Linux) or **WIN_PARENT_PYTHON_HOME** (for Windows).
3. Fulfill `conf/requirements.txt` file to add your required Python packages used by your project.
4. Launch the script `venv-create` (with correct extension for your system).

This last action will create a **Python virtual environment** and load your required python packages. 

If you want to **dev with notebooks**, you have to deploy `Jupyter` package into your Python parent folder or into your virtual env. (with the requirements script for example).

### Main functions
```shell
# Converting a Jupyter notebook (example with a Windows OS)
# Notebook is called myNotebook.ipynb and stored in "notebooks" folder 
cd <APPLICATION_HOME>/scripts/powershell
.\notebook-converter.ps1 myNotebook.ipynb
```

```shell
# Launching my Python program manually (example with a Windows OS)
# Program is called myNotebook.py and stored in "app" folder 
cd <APPLICATION_HOME>/scripts/powershell>
.\app-start.ps1 myNotebook.py
```
## 💡 Some use cases
```md
> Tip: I want to use my own Python lib. 

Put your Python lib in "lib/" folder, then:

# instanciate your class and use it
from lib.my_class_file import MyClass
my_cls: MyClass = epy.load_cls(module_name='my_class_file', class_name='MyClass', args=[*args], cls_type=MyClass)

foo = my_class.function()

```

```md
> Tip: I already have a Python program.

Put your Python program in "app" folder and launch it with the `app-start` script
```

```md
> Tip: VScode do not allow me to use my virtual env.

VScode could be a little bit ennoying and can not detect your fresh Python virtual env. 
You have to set "python.defaultInterpreterPath" with your Python virtual env in VScode settings
By default with value like: "rt/python/bin/python3"
```

```md
> Tip: Should I always use a Python virtualenv ?

It is not necessary if you already have your required dependencies loaded in parent Python home or if you do not have need to isolate your program and packages. 

However Python virtualenv is better for security reasons or professionnal workflow. You should use it without hesitate.
```

```md
> Tip: Can I use a dotenv (.env) file to add variables without keeping them in project repository ?

Since version 2.3.0, EssencePy handles dotenv files. 
You just have to put your .env into project folder (it will be discovered by bootstrap). All variables from this file will be injected into Python Environment. You should get them from CfgYaml/CfgProperties Classes or `os.environ` calls.

Notice: By default, `.env` files are ignored for publishing into EssencePy repository (.gitignore)
```
### Currently working with

- Windows 10            | Powershell 5.1    | Python 3.12.8 / Python 3.14.6
- ~~Centos 7            | Bash 4.2.46       | Python 3.11.11~~ (Centos7 is deprecated. I'm stopping tests on this OS)
- MacOS 26 (Intel)      | Zsh 5.9           | Python 3.12 (installed by brew)
- MacOS 26 (Silicon)    | Zsh 5.9           | Python 3.14
- Ubuntu 24.04          | Bash 5.2.21       | Python 3.11.11

---
Made with ❤️ for curious developers and pragmatic engineers.
