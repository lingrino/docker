#!/bin/sh

# The whole point of this file is to set the ATLANTIS_PORT variable to the
# dynamic port that Heroku provides at $PORT at runtime
export ATLANTIS_PORT=${PORT:=4141}

exec /usr/local/bin/docker-entrypoint.sh "$@"
