#!/bin/bash
#
# Database Restore Script
#
# Restores a database backup
# Usage: ./scripts/restore_db.sh [backup_file]
#        ./scripts/restore_db.sh  (uses latest backup)

set -e  # Exit on error

# Configuration
DB_NAME="pot_examples_dev"
DB_HOST="localhost"
DB_PORT="7432"
DB_USER="postgres"
DB_PASS="postgres"
BACKUP_DIR="backups"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to show usage
usage() {
  echo "Usage: $0 [backup_file]"
  echo ""
  echo "Examples:"
  echo "  $0                                           # Restore latest backup"
  echo "  $0 backups/pot_examples_dev_20251212.dump   # Restore specific backup"
  echo ""
  exit 1
}

# Determine backup file to restore
if [ -z "$1" ]; then
  # Use latest backup
  BACKUP_FILE=$(ls -t "$BACKUP_DIR"/${DB_NAME}_*.dump 2>/dev/null | head -1)
  if [ -z "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ No backup files found in $BACKUP_DIR${NC}"
    exit 1
  fi
  echo -e "${YELLOW}Using latest backup: $BACKUP_FILE${NC}"
else
  BACKUP_FILE="$1"
  if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Backup file not found: $BACKUP_FILE${NC}"
    exit 1
  fi
fi

# Verify backup file
echo -e "\n${YELLOW}Verifying backup file...${NC}"
pg_restore --list "$BACKUP_FILE" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Invalid or corrupted backup file!${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Backup file is valid${NC}"

# Get file info
SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo -e "   File: $BACKUP_FILE"
echo -e "   Size: $SIZE"

# Confirm restore
echo -e "\n${RED}⚠️  WARNING: This will DROP and recreate the database '$DB_NAME'${NC}"
echo -e "${RED}   All current data will be LOST!${NC}"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo -e "${YELLOW}Restore cancelled.${NC}"
  exit 0
fi

# Drop existing database
echo -e "\n${YELLOW}Dropping existing database...${NC}"
PGPASSWORD="$DB_PASS" dropdb \
  -h "$DB_HOST" \
  -p "$DB_PORT" \
  -U "$DB_USER" \
  --if-exists \
  "$DB_NAME"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Database dropped${NC}"
else
  echo -e "${RED}❌ Failed to drop database${NC}"
  exit 1
fi

# Create new database
echo -e "\n${YELLOW}Creating new database...${NC}"
PGPASSWORD="$DB_PASS" createdb \
  -h "$DB_HOST" \
  -p "$DB_PORT" \
  -U "$DB_USER" \
  "$DB_NAME"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Database created${NC}"
else
  echo -e "${RED}❌ Failed to create database${NC}"
  exit 1
fi

# Restore backup
echo -e "\n${YELLOW}Restoring backup...${NC}"
PGPASSWORD="$DB_PASS" pg_restore \
  -h "$DB_HOST" \
  -p "$DB_PORT" \
  -U "$DB_USER" \
  -d "$DB_NAME" \
  --no-owner \
  --no-acl \
  "$BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Restore completed successfully!${NC}"
else
  echo -e "${RED}❌ Restore failed!${NC}"
  exit 1
fi

# Verify restore
echo -e "\n${YELLOW}Verifying restore...${NC}"
TABLE_COUNT=$(PGPASSWORD="$DB_PASS" psql \
  -h "$DB_HOST" \
  -p "$DB_PORT" \
  -U "$DB_USER" \
  -d "$DB_NAME" \
  -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | xargs)

if [ ! -z "$TABLE_COUNT" ] && [ "$TABLE_COUNT" -gt 0 ]; then
  echo -e "${GREEN}✅ Restore verification passed${NC}"
  echo -e "   Tables restored: $TABLE_COUNT"
else
  echo -e "${YELLOW}⚠️  Warning: Could not verify table count${NC}"
fi

# Summary
echo -e "\n${GREEN}Database restore complete!${NC}"
echo -e "  Database: $DB_NAME"
echo -e "  Backup: $BACKUP_FILE"
echo -e "  Tables: $TABLE_COUNT"

exit 0
