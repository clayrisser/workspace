FROM frappe/bench:latest

RUN sudo apt-get update && \
    sudo apt-get install -y \
    bash \
    curl \
    git \
    git-lfs \
    jq \
    make \
    openssl \
    patch \
    rsync && \
    sudo rm -rf /var/lib/apt/lists/* && \
    sudo curl -Lo /usr/local/bin/yq \
    https://github.com/mikefarah/yq/releases/download/v4.25.2/yq_linux_amd64
