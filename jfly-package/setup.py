#!/usr/bin/env python

try:
    with open("/tmp/jfly.log", "a") as f:
        import sys
        import traceback
        traceback.print_stack(file=f)
        print(f"BEFORE IMPORTING SETUPTOOLS {sys.path}", file=f)#<<<

    import setuptools

    with open("/tmp/jfly.log", "a") as f:
        print(f"successfully imported SETUPTOOLS: {setuptools.__version__} {setuptools.__path__}", file=f)#<<<

    setuptools.setup(
        name='jfly',
        version='0.42.0',
        install_requires=['six>=1.7.2'],
        packages=[
            'jfly',
        ],
      )
except Exception as e:
    import traceback
    with open("/tmp/jfly.log", "a") as f:
        print(f"catch-all found {e}", file=f)#<<<
        traceback.print_exc(file=f)
    raise e
