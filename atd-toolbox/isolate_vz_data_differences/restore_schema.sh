#!/bin/bash

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

# Path to the backup file
BACKUP_FILE="data_model_dump.backup"

# Drop the existing data_model schema if it exists
PGPASSWORD=$PASSWORD psql -U $USERNAME -h $HOST -p $PORT -d $DATABASE -c "DROP SCHEMA IF EXISTS data_model CASCADE;"

# Create the data_model schema
PGPASSWORD=$PASSWORD psql -U $USERNAME -h $HOST -p $PORT -d $DATABASE -c "CREATE SCHEMA data_model;"

# Restore the data_model schema from the backup file
PGPASSWORD=$PASSWORD pg_restore -U $USERNAME -h $HOST -p $PORT -d $DATABASE -n data_model --clean -v $BACKUP_FILE
