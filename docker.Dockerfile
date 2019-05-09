##########################
### Metadata           ###
##########################
FROM docker:latest
LABEL maintainer="srlingren@gmail.com"

##########################
### Versions           ###
##########################
# https://github.com/hadolint/hadolint/releases
ARG HADOLINT_VERSION=1.16.3

##########################
### Packages           ###
##########################
RUN apk -q add --no-cache \
    bash \
    curl \
    git \
    git-lfs \
    jq \
    wget

##########################
### Hadolint           ###
##########################
RUN wget -q https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64 -O /usr/local/bin/hadolint && \
    chown root:root /usr/local/bin/hadolint && \
    chmod 755 /usr/local/bin/hadolint

COPY files/ci/hadolint.yaml /root/.config/hadolint.yaml
