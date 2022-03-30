Demonstration of a weird race condition in pipenv: if your Pipfile.lock
specifies a different version of setuptools than your system has installed,
*and* you go onto actually try to build a package, you can end up in a
situation where that package build fails because setuptools files are
disappearing out from underneath it.

Bizarrely, this results in `pipenv install` exiting 0 (no error), but a package
you'd expect to have installed is NOT INSTALLED. In the example, we expect a
package called `jfly` (which provides a `jfly.BadMath` module we hope to be
able to import) to be installed, but it doesn't always get installed.

To reproduce the issue:

    $ docker run $(docker build -q .)
    ...
    ****************************
    Resetting...
    Installing deps with pipenv...
    Successfully imported jfly.BadMath! <module 'jfly.BadMath' from '/usr/local/lib/python3.8/dist-packages/jfly/BadMath.py'>
    ****************************
    Runs: 37
    Successes: 3
    Failures: 34
    ****************************
    Resetting...
    Installing deps with pipenv...
    Traceback (most recent call last):
      File "<string>", line 1, in <module>
    ModuleNotFoundError: No module named 'jfly'
    ****************************
    Runs: 38
    Successes: 3
    Failures: 35
    ****************************

To get more information, try passing `--verbose`:

    $ docker run $(docker build -q .) --verbose

You'll see evidence of setuptools getting uninstalled and re-installed:

    Installing collected packages: setuptools
      Attempting uninstall: setuptools
        Found existing installation: setuptools 45.2.0
        Uninstalling setuptools-45.2.0:
          Removing file or directory /usr/local/bin/easy_install
          Removing file or directory /usr/local/bin/easy_install-3.8
          Removing file or directory /usr/local/lib/python3.8/dist-packages/__pycache__/easy_install.cpython-38.pyc
          Removing file or directory /usr/local/lib/python3.8/dist-packages/easy_install.py
          Removing file or directory /usr/local/lib/python3.8/dist-packages/pkg_resources/
          Removing file or directory /usr/local/lib/python3.8/dist-packages/setuptools-45.2.0.dist-info/
          Removing file or directory /usr/local/lib/python3.8/dist-packages/setuptools/
          Successfully uninstalled setuptools-45.2.0
    Successfully installed setuptools-61.2.0

And you'll see errors like:

- `No module named 'setuptools.command.install'`
- `AttributeError: type object 'Distribution' has no attribute '_finalize_feature_opts'`

It feels like there are 2 things going on here:

1. Speculation: Maybe there's a race condition where pipenv (indirectly) triggers this setuptools upgrade and simultaneously goes on to (inderectly) evaluate our package's setup.py file, which randomly fails to import things because the filesystem is in the process of changing.
2. Speculation: Maybe pipenv (or even pip) is invoking the setup.py in a way where it swallows errors? Or maybe there's some funky bug in setuptools itself? This sounds crazy, but I can't think of a better explanation for why pipenv itself exits successfully.
