##########################
### Metadata           ###
##########################
FROM runatlantis/atlantis:latest
LABEL maintainer="srlingren@gmail.com"

##########################
### SCRIPTS            ###
##########################
COPY files/atlantis/docker-entrypoint-wrapper.sh /usr/local/bin/docker-entrypoint-wrapper.sh

##########################
### BOOT               ###
##########################
ENTRYPOINT ["docker-entrypoint-wrapper.sh"]
CMD ["server"]
