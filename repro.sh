#!/usr/bin/env bash

set -euo pipefail

reset() {
    echo "Restting..."

    # Uninstall jfly and go back to an old version of setuptools (old enough
    # that pipenv will decide to upgrade it because there's a newer version in
    # Pipfile.lock)
    pip uninstall -y jfly setuptools &>/dev/null

    # This would be more analogous to what a fresh container looks like.
    # (list of packages from `apt-cache depends python3-setuptools`)
    # apt-get install --reinstall python3-setuptools python3-pkg-resources python3-distutils

    # But, this is more likely to make sense to Python folks who don't want to think about apt.
    pip install setuptools==45.2.0 &>/dev/null
}

reset

#<<< trying to repro inside a virtualenv
#<<< pip install -U wheel
#<<<

rm -f /tmp/jfly-setup.log
pipenv install --system --deploy --verbose
echo "------------ START OF /tmp/jfly-setup.log ------------------------"
cat /tmp/jfly-setup.log
echo "------------ END OF /tmp/jfly-setup.log ------------------------"

python3 -c "import jfly.BadMath as j; print(j)"
echo "success!"
