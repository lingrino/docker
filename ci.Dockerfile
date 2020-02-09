##########################
### Metadata           ###
##########################
FROM ubuntu:eoan
LABEL maintainer="sean@lingrino.com"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

##########################
### Versions           ###
##########################
# Notes
# Update the ubuntu version in the FROM tag when needed
# update the node version and distribution name in files/ci/node.list when needed

# https://golang.org/dl/
ARG GO_VERSION=1.13.7
# https://github.com/golangci/golangci-lint/releases
ARG GOLANGCILINT_VERSION=1.23.3
# https://github.com/goreleaser/goreleaser/releases
ARG GORELEASER_VERSION=0.126.0
# https://github.com/hadolint/hadolint/releases
ARG HADOLINT_VERSION=1.17.5
# https://www.packer.io/downloads.html
ARG PACKER_VERSION=1.5.1
# https://www.terraform.io/downloads.html
ARG TERRAFORM_VERSION=0.12.20
# https://www.vaultproject.io/downloads.html
ARG VAULT_VERSION=1.3.2
# https://github.com/cloudflare/wrangler/releases
ARG WRANGLER_VERSION=1.7.0

##########################
### Repositories       ###
##########################
RUN apt-get update \
    && apt-get install --no-install-recommends -y -qq \
    gpg-agent \
    software-properties-common \
    && add-apt-repository ppa:git-core/ppa

COPY files/ci/node_gpg.key /tmp/node_gpg.key
COPY files/ci/yarn_gpg.key /tmp/yarn_gpg.key
COPY files/ci/yarn.list    /etc/apt/sources.list.d/yarn.list
COPY files/ci/node.list    /etc/apt/sources.list.d/nodesource.list

RUN apt-key add /tmp/node_gpg.key \
    && apt-key add /tmp/yarn_gpg.key

##########################
### Packages           ###
##########################
RUN apt-get update && apt-get install --no-install-recommends -y -qq \
    curl \
    docker \
    gcc \
    git \
    jq \
    make \
    nmap \
    nodejs \
    python3 \
    python3-dev \
    python3-pip \
    shellcheck \
    ssh \
    unzip \
    wget \
    yarn \
    && rm -rf /var/lib/apt/lists/*

##########################
### Golang             ###
##########################
RUN wget -q https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz \
    && tar -xzf /tmp/go.tar.gz -C /tmp \
    && cp -r /tmp/go /usr/local \
    && rm -rf /tmp/go.tar.gz /tmp/go

ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV PATH /usr/local/go/bin:/go/bin:$PATH
RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

RUN go get -u \
    github.com/lingrino/vaku

##########################
### NPM                ###
##########################
RUN npm install --global \
    npm \
    serverless \
    markdownlint-cli

##########################
### Python             ###
##########################
RUN pip3 install --upgrade --no-input --no-cache-dir pip \
    && pip install --upgrade --no-input --no-cache-dir setuptools \
    && pip install --upgrade --no-input --no-cache-dir \
    ansible \
    ansible-lint \
    awscli \
    boto \
    boto3

##########################
### Ansible            ###
##########################
COPY files/ci/ansible.cfg /etc/ansible/ansible.cfg

##########################
### Markdownlint       ###
##########################
COPY files/ci/markdownlintrc /.markdownlintrc

##########################
### Shellcheck         ###
##########################
COPY files/ci/shellcheckrc ~/.shellcheckrc

##########################
### GolangCI Lint      ###
##########################
RUN wget -q https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCILINT_VERSION}/golangci-lint-${GOLANGCILINT_VERSION}-linux-amd64.tar.gz -O /tmp/golangci-lint.tar.gz \
    && mkdir /tmp/golangci-lint \
    && tar -xzf /tmp/golangci-lint.tar.gz -C /tmp/golangci-lint \
    && cp /tmp/golangci-lint/golangci-lint-${GOLANGCILINT_VERSION}-linux-amd64/golangci-lint /usr/local/bin/golangci-lint \
    && rm -rf /tmp/golangci-lint.tar.gz /tmp/golangci-lint

COPY files/ci/golangci.yml /.golangci.yml

##########################
### Goreleaser         ###
##########################
RUN wget -q https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_Linux_x86_64.tar.gz -O /tmp/goreleaser.tar.gz \
    && mkdir /tmp/goreleaser \
    && tar -xzf /tmp/goreleaser.tar.gz -C /tmp/goreleaser \
    && cp /tmp/goreleaser/goreleaser /usr/local/bin/goreleaser \
    && rm -rf /tmp/goreleaser.tar.gz /tmp/goreleaser

##########################
### Hadolint           ###
##########################
RUN wget -q https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64 -O /usr/local/bin/hadolint \
    && chown root:root /usr/local/bin/hadolint \
    && chmod 755 /usr/local/bin/hadolint

COPY files/ci/hadolint.yaml /root/.config/hadolint.yaml

##########################
### Packer             ###
##########################
RUN wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip -O /tmp/packer.zip \
    && unzip /tmp/packer.zip -d /usr/local/bin \
    && chown root:root /usr/local/bin/packer \
    && chmod 755 /usr/local/bin/packer \
    && rm -f /tmp/packer.zip

##########################
### Terraform          ###
##########################
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && chown root:root /usr/local/bin/terraform \
    && chmod 755 /usr/local/bin/terraform \
    && rm -f /tmp/terraform.zip

RUN mkdir -p "$HOME/.terraform.d/plugin-cache"
COPY files/ci/terraformrc ~/.terraformrc

##########################
### Vault              ###
##########################
RUN wget -q https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -O /tmp/vault.zip \
    && unzip /tmp/vault.zip -d /usr/local/bin \
    && chown root:root /usr/local/bin/vault \
    && chmod 755 /usr/local/bin/vault \
    && rm -f /tmp/vault.zip

##########################
### Wrangler           ###
##########################
RUN wget -q https://github.com/cloudflare/wrangler/releases/download/v${WRANGLER_VERSION}/wrangler-v${WRANGLER_VERSION}-x86_64-unknown-linux-musl.tar.gz -O /tmp/wrangler.tar.gz \
    && mkdir /tmp/wrangler \
    && tar -xzf /tmp/wrangler.tar.gz -C /tmp/wrangler \
    && cp /tmp/wrangler/wrangler-v${WRANGLER_VERSION}-x86_64-unknown-linux-musl/wrangler /usr/local/bin/wrangler \
    && rm -rf /tmp/wrangler.tar.gz /tmp/wrangler
