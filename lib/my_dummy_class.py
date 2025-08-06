class Dummy:
    """
    Just a dummy python class outside of /bootstrap for example
    """

    def __init__(self, epy):
        self.app_home = epy.APPLICATION_HOME

    
    def dummy_function(self):
        print(f"Hello World from {self.app_home}")
        