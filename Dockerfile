FROM ubuntu:20.04

WORKDIR /app

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        jq \
        python3 \
        python3-pip

# Upgrading setuptools before pipenv tries to makes the race go away.
# RUN pip install --upgrade setuptools==61.2.0

# Just install some recent version of pip.
RUN pip install --upgrade pip==22.0.4

# The behavior doesn't seem to change between recent versions of pipenv.
# RUN pip install --upgrade pipenv==2022.1.8
RUN pip install --upgrade pipenv==2022.3.28

COPY jfly-package ./jfly-package
COPY Pipfile .
COPY Pipfile.lock .

COPY stress .
COPY repro.sh .
ENTRYPOINT ["./stress", "./repro.sh"]
