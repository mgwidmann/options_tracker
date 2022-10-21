#!/bin/bash

pg_url=`gigalixir pg -a options-tracker | jq '.[0].url' -M -c -r`
pg_user=`gigalixir pg -a options-tracker | jq '.[0].username' -M -c -r`

echo Connecting to $pg_url

pg_dump $pg_url --format=plain --no-owner --no-privileges --no-acl --data-only --column-inserts > options-tracker-prod-$pg_user-migrate.sql