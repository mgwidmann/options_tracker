#!/bin/bash

file=$1

createdb options_tracker_prod

echo Restoring $file...
pg_restore -U postgres -W -h localhost -p 5432 --format=custom --no-owner --no-privileges --no-acl -d options_tracker_prod $file