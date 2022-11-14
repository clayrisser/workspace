ARG ERPNEXT_VERSION
FROM frappe/erpnext-worker:${ERPNEXT_VERSION}

COPY apps ../_apps

USER root

RUN apt-get update && apt-get install -y \
    bind9-host \
    curl \
    git \
    git-lfs \
    iputils-ping \
    make \
    procps \
    vim && \
    rm -rf /var/lib/apt/lists/*

RUN APPS=$(ls ../_apps) && mv ../_apps/* ../apps && rm -rf ../_apps && \
    for a in $APPS; do \
    install-app $a; \
    done

USER frappe
