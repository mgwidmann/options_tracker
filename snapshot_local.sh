#!/bin/bash

pg_dump options_tracker_prod --format=custom --no-owner --no-privileges --no-acl > options-tracker-prod-local.sql