__version__ = "1.0.0"


class Dummy:
    """
    Just a dummy python class outside of /bootstrap for example
    """

    def __init__(self, epy, app_name):
        self.app_home = epy.APPLICATION_HOME
        self.app_name = f"{app_name}_test"

    
    def dummy_function(self):
        print(f"Hello World from {self.app_home}")

# class Foo:

#     def __init__(self):
#         return None

    
#     def dummy_function(self):
#         print(f"Bye Bye")