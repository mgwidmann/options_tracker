#!/bin/bash

file=$1

if [[ -z "$file" ]]; then
    echo "Must provide file argument to restore!" 1>&2
    exit 1
fi

pg_url=postgres://options_tracker:yGs1NksUCb8vY5E@top2.nearest.of.options-tracker-db.internal:5432/options_tracker
pg_user=postgres
pg_database=options_tracker
pg_host=localhost
pg_port=5433

echo Restoring PROD $file to $pg_database as user $pg_user...

psql -U $pg_user -d $pg_database -h $pg_host -p $pg_port -f $file
