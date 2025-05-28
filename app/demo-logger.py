#!/usr/bin/env python
# coding: utf-8

# In[1]:


APPLICATION_NAME = "DEMO_LoggerClass"


# In[2]:


import sys
from pathlib import Path

# Remonter les dossiers jusqu'à trouver lib/init/init_code.py
def find_app_home(sentinel: str ="lib/bootstrap/bootstrap.py"):
    current = Path.cwd().resolve()
    root = current.root
    while current != root:
        if (current / sentinel).is_file():
            return current
        current = current.parent
    raise FileNotFoundError(f"Impossible de trouver le fichier sentinelle : {sentinel}")

# Trouver et ajouter APPLICATION_HOME au sys.path
APPLICATION_HOME = find_app_home()
sys.path.insert(0, str(APPLICATION_HOME))
#print(f"APPLICATION_HOME set to: {APPLICATION_HOME}")

from lib.bootstrap.bootstrap import init_env
epy = init_env()


# ## Testing log functions

# In[3]:


epy.log.info(f"Testing INFO message : {epy.appenv.get_current_date()} {epy.appenv.get_current_time()}")


# In[4]:


epy.log.warning(f"Testing WARNING message : {epy.appenv.get_current_date()} {epy.appenv.get_current_time()}")


# In[5]:


epy.log.error(f"Testing ERROR message : {epy.appenv.get_current_date()} {epy.appenv.get_current_time()}")


# ## Testing other functions

# In[6]:


epy.log.get_log_file


# In[7]:


epy.log.get_log_folder

