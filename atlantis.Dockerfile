##########################
### Metadata           ###
##########################
FROM runatlantis/atlantis:latest
LABEL maintainer="srlingren@gmail.com"

##########################
### Packages           ###
##########################
RUN apt-get update && apt-get install --no-install-recommends -y -qq \
    jq \
    python3 \
    python3-dev \
    python3-pip \
    wget \
    && rm -rf /var/lib/apt/lists/*

##########################
### Python             ###
##########################
RUN pip3 install --upgrade --no-input --no-cache-dir pip && \
    pip install --upgrade --no-input --no-cache-dir \
    awscli

##########################
### SCRIPTS            ###
##########################
COPY files/atlantis/assume-role                  /usr/local/bin/assume-role
COPY files/atlantis/docker-entrypoint-wrapper.sh /usr/local/bin/docker-entrypoint-wrapper.sh

##########################
### CONFIG             ###
##########################
ENV  ATLANTIS_CONFIG /usr/local/lib/atlantis/server-config.yml
COPY files/atlantis/server-config.yml /usr/local/lib/atlantis/server-config.yml
COPY files/atlantis/repo-config.yml   /usr/local/lib/atlantis/repo-config.yml

##########################
### BOOT               ###
##########################
ENTRYPOINT ["docker-entrypoint-wrapper.sh"]
CMD ["server"]
