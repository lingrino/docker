##########################
### Metadata           ###
##########################
FROM ubuntu:latest
LABEL maintainer="srlingren@gmail.com"

##########################
### Versions           ###
##########################
# https://github.com/hadolint/hadolint/releases
ARG HADOLINT_VERSION=1.16.3

##########################
### Packages           ###
##########################
RUN apt-get update && apt-get install -y -qq \
    curl \
    docker \
    git \
    jq \
    wget \
    && rm -rf /var/lib/apt/lists/*

##########################
### Hadolint           ###
##########################
RUN wget -q https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64 -O /usr/local/bin/hadolint && \
    chown root:root /usr/local/bin/hadolint && \
    chmod 755 /usr/local/bin/hadolint

COPY files/docker/hadolint.yml ~/.config/hadolint.yml

ENTRYPOINT ["/bin/bash"]
