#!/bin/bash

# Exit on any error
set -e

# Aiven connection details
AIVEN_HOST=""
AIVEN_PORT=""
AIVEN_DB=""
AIVEN_USER=""
AIVEN_PASSWORD=""

# RDS connection details
RDS_HOST=""
RDS_PORT=""
RDS_DB=""
RDS_USER=""
RDS_PASSWORD=""

# Set SSL mode for the connection
export PGSSLMODE=require

echo "Starting database migration..."

# Export data from Aiven
echo "Exporting data from Aiven..."
PGPASSWORD=$AIVEN_PASSWORD pg_dump \
  -h $AIVEN_HOST \
  -p $AIVEN_PORT \
  -U $AIVEN_USER \
  -d $AIVEN_DB \
  -F c \
  -b \
  -v \
  --no-owner \
  --no-privileges \
  -f "database_backup.dump"

if [ $? -ne 0 ]; then
    echo "Error: pg_dump failed"
    exit 1
fi

# Check if dump file exists
if [ ! -f "database_backup.dump" ]; then
    echo "Error: Backup file was not created"
    exit 1
fi

# Import data to RDS
echo "Importing data to RDS..."
PGPASSWORD=$RDS_PASSWORD pg_restore \
  -h $RDS_HOST \
  -p $RDS_PORT \
  -U $RDS_USER \
  -d $RDS_DB \
  -v \
  --clean \
  --no-owner \
  --no-privileges \
  "database_backup.dump"

# Clean up
echo "Cleaning up temporary files..."
rm -f database_backup.dump

echo "Migration completed!"
