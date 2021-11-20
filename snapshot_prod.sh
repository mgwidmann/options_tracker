#!/bin/bash

pg_url=`gigalixir pg -a options-tracker | jq '.[0].url' -M -c -r`
pg_user=`gigalixir pg -a options-tracker | jq '.[0].username' -M -c -r`

echo Connecting to $pg_url

pg_dump $pg_url --format=custom --no-owner --no-privileges --no-acl > options-tracker-prod-$pg_user.sql