# How install Python easily in Microsoft Windows even if you're not an administrator

> [!NOTE]
> This note allows you to use `EssencePy` even if Python can not be installed directly on system. Following steps below to create a **portable** version for your EPY project without touching Windows OS.
> <br>Contact your administrator if needed.

## 1. Download a `Python embeddable` version

*Source* : `https://www.python.org/downloads/`

1. Choose your Python version
2. Get en embeddable version file
3. Unarchive downloaded file (move it in final destination if necessary)
4. Open a 
Unarchive downloaded package and open a terminal session directly in folder

## 2. Get `PIP` module

### 2.1. From a terminal (without proxy)

```sh
# download get-pip script from official website
curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py
```
```sh
# launch install of pip module
python.exe get-pip.py
```
### 2.2. From a terminal (with proxy)

```sh
# download get-pip script from official website behind web proxy server
curl --proxy <your_web_proxy_url_here> -o get-pip.py https://bootstrap.pypa.io/get-pip.py
```
```sh
# launch install of pip module
python.exe get-pip.py --proxy <your_web_proxy_url_here>
```
### 2.3. Modify the `_pth` file
> [!WARNING]
> Without this step, `PIP` module do not work properly and you should stay with an error like: `python.exe: No module named pip`  

In current installation folder, **find** the `_pth` file and edit it.
```sh
# Add following line at the end of file
Lib\site-packages
```
**Example with python314._pth file**

```txt
python314.zip
.

# Uncomment to run site.main() automatically
#import site
Lib\site-packages
```

### 2.4. Check
```sh
# launch install of pip module
python.exe -m pip list

# output
pip 26.1.2 from C:\APPLICATIONS\python-3.14.4-embed-amd64\Lib\site-packages\pip (python 3.14)
```

## 3. Install packages
> [!TIP]
> Like installation step, you might add `--proxy <your_web_proxy_url_here>` argument to your command line if you computer is behind a proxy.

```sh
# install package manually (without proxy)
python.exe -m pip install <package_name>
```
```sh
# install package from a list of packages (example with a proxy)
python.exe -m pip install -r <requirements_file> --proxy <your_web_proxy_url_here>
```