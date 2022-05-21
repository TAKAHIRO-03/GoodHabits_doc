#!/bin/bash

psql -U postgres -c "SELECT * FROM pg_shadow" | grep "ghuser"; \
if [ "$?" -ne 0 ]; then \
  psql -U postgres -c "CREATE ROLE ghuser WITH LOGIN SUPERUSER CREATEDB CREATEROLE INHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD 'ghpass'"; \
fi

psql -f /sql/init.sql -U postgres -d postgres