#!/bin/bash

psql -U postgres -c "SELECT * FROM pg_shadow" | grep "havetodouser"; \
if [ "$?" -ne 0 ]; then \
  psql -U postgres -c "CREATE ROLE havetodouser WITH LOGIN SUPERUSER CREATEDB CREATEROLE INHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD 'havetodopass'"; \
fi

psql -f /sql/init.sql -U postgres -d postgres