##########################
### Metadata           ###
##########################
FROM ubuntu:latest
LABEL maintainer="srlingren@gmail.com"

##########################
### Versions           ###
##########################
# https://golang.org/dl/
ARG GO_VERSION=1.12.5
# https://github.com/goreleaser/goreleaser/releases
ARG GORELEASER_VERSION=0.106.0
# https://github.com/hadolint/hadolint/releases
ARG HADOLINT_VERSION=1.16.3
# https://www.packer.io/downloads.html
ARG PACKER_VERSION=1.4.0
# https://www.terraform.io/downloads.html
ARG TERRAFORM_VERSION=0.12.0-rc1
# https://www.vaultproject.io/downloads.html
ARG VAULT_VERSION=1.1.1

##########################
### Packages           ###
##########################
RUN apt-get update && apt-get install -y -qq \
    curl \
    docker \
    git \
    jq \
    nmap \
    npm \
    python3 \
    python3-dev \
    python3-pip \
    shellcheck \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

##########################
### Golang             ###
##########################
RUN wget -q https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -xzf /tmp/go.tar.gz -C /tmp && \
    cp -r /tmp/go /usr/local && \
    rm -rf /tmp/go.tar.gz /tmp/go

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
RUN pip3 install --upgrade --no-input --no-cache-dir pip && \
    pip install --upgrade --no-input --no-cache-dir \
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
### Goreleaser         ###
##########################
RUN wget -q https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_Linux_x86_64.tar.gz -O /tmp/goreleaser.tar.gz && \
    mkdir /tmp/goreleaser && \
    tar -xzf /tmp/goreleaser.tar.gz -C /tmp/goreleaser && \
    cp /tmp/goreleaser/goreleaser /usr/bin/ && \
    rm -rf /tmp/goreleaser.tar.gz /tmp/goreleaser

##########################
### Hadolint           ###
##########################
RUN wget -q https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64 -O /usr/local/bin/hadolint && \
    chown root:root /usr/local/bin/hadolint && \
    chmod 755 /usr/local/bin/hadolint

COPY files/ci/hadolint.yml ~/.config/hadolint.yml

##########################
### Packer             ###
##########################
RUN wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip -O /tmp/packer.zip && \
    unzip /tmp/packer.zip -d /usr/local/bin && \
    chown root:root /usr/local/bin/packer && \
    chmod 755 /usr/local/bin/packer && \
    rm -f /tmp/packer.zip

##########################
### Terraform          ###
##########################
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    chown root:root /usr/local/bin/terraform && \
    chmod 755 /usr/local/bin/terraform && \
    rm -f /tmp/terraform.zip

RUN mkdir -p "$HOME/.terraform.d/plugin-cache"
COPY files/ci/terraformrc ~/.terraformrc

##########################
### Vault              ###
##########################
RUN wget -q https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -O /tmp/vault.zip && \
    unzip /tmp/vault.zip -d /usr/local/bin && \
    chown root:root /usr/local/bin/vault && \
    chmod 755 /usr/local/bin/vault && \
    rm -f /tmp/vault.zip
