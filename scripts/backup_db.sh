#!/bin/bash
#
# Database Backup Script
#
# Creates a compressed backup of pot_examples_dev database
# Usage: ./scripts/backup_db.sh

set -e  # Exit on error

# Configuration
DB_NAME="pot_examples_dev"
DB_HOST="localhost"
DB_PORT="7432"
DB_USER="postgres"
DB_PASS="postgres"
BACKUP_DIR="backups"
RETENTION_DAYS=7

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.dump"

# Create backup
echo -e "${YELLOW}Creating backup: $BACKUP_FILE${NC}"
PGPASSWORD="$DB_PASS" pg_dump \
  -h "$DB_HOST" \
  -p "$DB_PORT" \
  -U "$DB_USER" \
  -Fc \
  -Z 9 \
  -f "$BACKUP_FILE" \
  "$DB_NAME"

if [ $? -eq 0 ]; then
  SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
  echo -e "${GREEN}✅ Backup created successfully!${NC}"
  echo -e "   File: $BACKUP_FILE"
  echo -e "   Size: $SIZE"

  # Verify backup integrity
  echo -e "\n${YELLOW}Verifying backup integrity...${NC}"
  pg_restore --list "$BACKUP_FILE" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Backup verification passed${NC}"
  else
    echo -e "${RED}❌ Backup verification failed!${NC}"
    exit 1
  fi
else
  echo -e "${RED}❌ Backup failed!${NC}"
  exit 1
fi

# Remove old backups
if [ "$RETENTION_DAYS" -gt 0 ]; then
  echo -e "\n${YELLOW}Removing backups older than $RETENTION_DAYS days...${NC}"
  DELETED=$(find "$BACKUP_DIR" -name "${DB_NAME}_*.dump" -mtime +$RETENTION_DAYS -print -delete | wc -l)
  if [ "$DELETED" -gt 0 ]; then
    echo -e "${GREEN}✅ Removed $DELETED old backup(s)${NC}"
  else
    echo -e "${GREEN}No old backups to remove${NC}"
  fi
fi

# List remaining backups
echo -e "\n${YELLOW}Current backups:${NC}"
ls -lh "$BACKUP_DIR"/${DB_NAME}_*.dump 2>/dev/null | awk '{printf "  %s  %s\n", $9, $5}' || echo "  No backups found"

# Summary
TOTAL_BACKUPS=$(ls "$BACKUP_DIR"/${DB_NAME}_*.dump 2>/dev/null | wc -l)
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
echo -e "\n${GREEN}Summary:${NC}"
echo -e "  Total backups: $TOTAL_BACKUPS"
echo -e "  Total size: $TOTAL_SIZE"

exit 0
