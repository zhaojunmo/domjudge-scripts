#!/bin/sh
# Script to update the DOMjudge demo webinterface
# at:    https://www.domjudge.org/demoweb/

set -e

MYSQLOPTS=''
DBNAME='domjudge_demo'

cd ~/demoweb

# Temporarily stick with pre-revamped user authentication (commit 6991a9a27f4abea)
git stash -q && git pull -q && git stash pop -q

# Rebuild in-place to also make configuration updates visible:
make QUIET=1 maintainer-clean
make QUIET=1 MAINT_CXFLAGS='-g -O2 -Wall -fPIE -Wformat -Wformat-security' \
	maintainer-conf || true
make QUIET= maintainer-install >/dev/null 2>&1

# Reset database to known good state:
mysql $MYSQLOPTS "$DBNAME" < domjudge_demo_remove.sql
mysql $MYSQLOPTS "$DBNAME" < domjudge_demo.sql

# Check that Git code and SQL dumpfile DB structures are in sync:
~/bin/check_db-struct.sh -o "$MYSQLOPTS" -d "$DBNAME" -l sql/mysql_db_structure.sql
