ARG ERPNEXT_VERSION
FROM frappe/erpnext-worker:${ERPNEXT_VERSION}

COPY apps ../_apps

USER root

RUN APPS=$(ls ../_apps) && mv ../_apps/* ../apps && rm -rf ../_apps && \
    for a in $APPS; do \
    install-app $a; \
    done && exit 1

USER frappe
