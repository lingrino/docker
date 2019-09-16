##########################
### Metadata           ###
##########################
FROM ubuntu:latest
LABEL maintainer="sean@lingrino.com"

# https://github.com/hadolint/hadolint/releases
ARG HADOLINT_VERSION=1.17.2

##########################
### Packages           ###
##########################
RUN apt-get update && apt-get install --no-install-recommends -y -qq \
    curl \
    jq \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

##########################
### Hadolint           ###
##########################
RUN wget -q https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64 -O /usr/local/bin/hadolint && \
    chown root:root /usr/local/bin/hadolint && \
    chmod 755 /usr/local/bin/hadolint

COPY files/ci/hadolint.yaml /root/.config/hadolint.yaml
