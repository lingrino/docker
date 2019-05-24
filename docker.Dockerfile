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

COPY files/docker/hadolint.yaml /root/.config/hadolint.yaml

##########################
### Heroku             ###
##########################
RUN wget -q https://cli-assets.heroku.com/heroku-linux-x64.tar.gz -O /tmp/heroku.tar.gz && \
    mkdir /tmp/heroku && \
    tar -xzf /tmp/heroku.tar.gz -C /tmp/heroku && \
    cp -R /tmp/heroku/heroku /usr/local/lib && \
    ln -s /usr/local/lib/heroku/bin/heroku /usr/local/bin/heroku && \
    rm -rf /tmp/heroku.tar.gz /tmp/heroku

COPY files/docker/netrc ~/.netrc
