#!/bin/sh
sqlite3 Animal_Shelter.db <<EOF
.read MySQL.sql
.quit
EOF