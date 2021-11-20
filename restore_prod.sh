#!/bin/bash

file=$1

if [[ -z "$file" ]]; then
    echo "Must provide file argument to restore!" 1>&2
    exit 1
fi

pg_url=`gigalixir pg -a options-tracker | jq '.[0].url' -M -c -r`
pg_user=`gigalixir pg -a options-tracker | jq '.[0].username' -M -c -r`
pg_database=`gigalixir pg -a options-tracker | jq '.[0].database' -M -c -r`
pg_host=`gigalixir pg -a options-tracker | jq '.[0].host' -M -c -r`
pg_password=`gigalixir pg -a options-tracker | jq '.[0].password' -M -c -r`

echo Restoring PROD $file to $pg_database as user $pg_user...
echo Password is $pg_password

pg_restore -U $pg_user -W -h $pg_host -p 5432 --format=custom --no-owner --no-privileges --no-acl -d $pg_database $file