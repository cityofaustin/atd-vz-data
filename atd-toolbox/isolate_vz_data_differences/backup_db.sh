#!/bin/bash

# Use a regular expression to parse the URL components
if [[ $DATABASE_CONNECTION =~ postgresql://([^:]+):([^@]+)@([^:]+):([^/]+)/(.+) ]]; then
  USERNAME=${BASH_REMATCH[1]}
  PASSWORD=${BASH_REMATCH[2]}
  HOST=${BASH_REMATCH[3]}
  PORT=${BASH_REMATCH[4]}
  DATABASE=${BASH_REMATCH[5]}
else
  echo "Invalid DATABASE_CONNECTION format"
  exit 1
fi

# Execute the pg_dump command using the extracted components
PGPASSWORD=$PASSWORD pg_dump -U $USERNAME -h $HOST -p $PORT -F c -b -v -f ${DATABASE}_backup.backup $DATABASE
