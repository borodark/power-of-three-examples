# Database Backup Guide

## Overview

This guide covers backing up the `pot_examples_dev` PostgreSQL database with the smallest possible storage size.

## Quick Backup (Smallest Size)

```bash
# Create backup with maximum compression
PGPASSWORD=postgres pg_dump \
  -h localhost \
  -p 7432 \
  -U postgres \
  -Fc \
  -Z 9 \
  -f backups/pot_examples_dev_$(date +%Y%m%d_%H%M%S).dump \
  pot_examples_dev
```

**Result**: ~510 MB compressed backup

## Backup Methods Comparison

### Method 1: Custom Format with Compression (RECOMMENDED ✅)

**Command**:
```bash
PGPASSWORD=postgres pg_dump -h localhost -p 7432 -U postgres \
  -Fc -Z 9 -f backups/pot_examples_dev.dump pot_examples_dev
```

**Flags**:
- `-Fc`: Custom format (binary, compressed)
- `-Z 9`: Maximum compression level (0-9)

**Advantages**:
- ✅ Smallest size: ~510 MB
- ✅ Parallel restore support
- ✅ Selective restore (tables, schemas)
- ✅ Faster restore than SQL

**Disadvantages**:
- ❌ Not human-readable
- ❌ Requires pg_restore (not psql)

---

### Method 2: SQL Dump with Gzip

**Command**:
```bash
PGPASSWORD=postgres pg_dump -h localhost -p 7432 -U postgres \
  pot_examples_dev | gzip -9 > backups/pot_examples_dev.sql.gz
```

**Advantages**:
- ✅ Human-readable (when uncompressed)
- ✅ Can be edited before restore
- ✅ Portable across PostgreSQL versions

**Disadvantages**:
- ❌ Larger size: ~525 MB (+15 MB vs custom format)
- ❌ Slower restore
- ❌ No parallel restore

---

### Method 3: Directory Format (For Large Databases)

**Command**:
```bash
PGPASSWORD=postgres pg_dump -h localhost -p 7432 -U postgres \
  -Fd -Z 9 -j 4 -f backups/pot_examples_dev_dir pot_examples_dev
```

**Flags**:
- `-Fd`: Directory format
- `-j 4`: Use 4 parallel jobs

**Advantages**:
- ✅ Parallel dump and restore
- ✅ Best for very large databases (>10 GB)

**Disadvantages**:
- ❌ Creates directory instead of single file
- ❌ Similar size to custom format

---

## Size Comparison

| Method | Size | Compression | Restore Speed |
|--------|------|-------------|---------------|
| Custom format (-Fc -Z 9) | **510 MB** | Best | Fast |
| SQL + gzip -9 | 525 MB | Good | Slow |
| Directory format | ~510 MB | Best | Fastest |
| Plain SQL (no compression) | ~3.2 GB | None | Slowest |

**Winner**: Custom format (`-Fc -Z 9`) for single-file backups

## Restore Instructions

### Restore Custom Format Backup

```bash
# Option 1: Drop and recreate database
PGPASSWORD=postgres dropdb -h localhost -p 7432 -U postgres pot_examples_dev
PGPASSWORD=postgres createdb -h localhost -p 7432 -U postgres pot_examples_dev
PGPASSWORD=postgres pg_restore -h localhost -p 7432 -U postgres \
  -d pot_examples_dev backups/pot_examples_dev_20251212_015911.dump

# Option 2: Clean restore (drop existing objects first)
PGPASSWORD=postgres pg_restore -h localhost -p 7432 -U postgres \
  -d pot_examples_dev --clean --if-exists \
  backups/pot_examples_dev_20251212_015911.dump
```

### Restore SQL Backup

```bash
# Uncompress and restore
gunzip -c backups/pot_examples_dev.sql.gz | \
  PGPASSWORD=postgres psql -h localhost -p 7432 -U postgres pot_examples_dev
```

### Restore Using Mix (Elixir)

```bash
# Drop and recreate
mix ecto.drop
mix ecto.create

# Restore data
PGPASSWORD=postgres pg_restore -h localhost -p 7432 -U postgres \
  -d pot_examples_dev backups/pot_examples_dev_20251212_015911.dump

# Run migrations (if schema changed)
mix ecto.migrate
```

## Selective Restore

Restore only specific tables or schemas:

```bash
# List contents of backup
pg_restore -l backups/pot_examples_dev.dump > backup_contents.txt

# Restore only specific table
PGPASSWORD=postgres pg_restore -h localhost -p 7432 -U postgres \
  -d pot_examples_dev -t orders backups/pot_examples_dev.dump

# Restore only specific schema
PGPASSWORD=postgres pg_restore -h localhost -p 7432 -U postgres \
  -d pot_examples_dev -n public backups/pot_examples_dev.dump
```

## Automated Backup Script

Create `scripts/backup_db.sh`:

```bash
#!/bin/bash

# Configuration
DB_NAME="pot_examples_dev"
DB_HOST="localhost"
DB_PORT="7432"
DB_USER="postgres"
DB_PASS="postgres"
BACKUP_DIR="backups"
RETENTION_DAYS=7

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.dump"

# Create backup
echo "Creating backup: $BACKUP_FILE"
PGPASSWORD="$DB_PASS" pg_dump \
  -h "$DB_HOST" \
  -p "$DB_PORT" \
  -U "$DB_USER" \
  -Fc \
  -Z 9 \
  -f "$BACKUP_FILE" \
  "$DB_NAME"

if [ $? -eq 0 ]; then
  echo "✅ Backup created successfully: $BACKUP_FILE"
  SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
  echo "   Size: $SIZE"
else
  echo "❌ Backup failed!"
  exit 1
fi

# Remove old backups
echo "Removing backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "${DB_NAME}_*.dump" -mtime +$RETENTION_DAYS -delete

# List remaining backups
echo ""
echo "Current backups:"
ls -lh "$BACKUP_DIR"/${DB_NAME}_*.dump
```

Make it executable:

```bash
chmod +x scripts/backup_db.sh
./scripts/backup_db.sh
```

## Scheduled Backups (Cron)

Add to crontab (`crontab -e`):

```cron
# Daily backup at 2 AM
0 2 * * * cd /home/io/projects/learn_erl/power-of-three-examples && ./scripts/backup_db.sh >> logs/backup.log 2>&1

# Weekly backup on Sunday at 3 AM
0 3 * * 0 cd /home/io/projects/learn_erl/power-of-three-examples && ./scripts/backup_db.sh && cp backups/pot_examples_dev_*.dump backups/weekly_backup.dump
```

## Backup Verification

Always verify backups after creation:

```bash
# Check backup integrity
pg_restore --list backups/pot_examples_dev.dump > /dev/null

if [ $? -eq 0 ]; then
  echo "✅ Backup is valid"
else
  echo "❌ Backup is corrupted!"
fi

# Test restore to a temporary database
PGPASSWORD=postgres createdb -h localhost -p 7432 -U postgres pot_examples_test
PGPASSWORD=postgres pg_restore -h localhost -p 7432 -U postgres \
  -d pot_examples_test backups/pot_examples_dev.dump
PGPASSWORD=postgres dropdb -h localhost -p 7432 -U postgres pot_examples_test
```

## Best Practices

### 1. Regular Backups

- **Daily**: Automated backups via cron
- **Pre-deployment**: Before any major changes
- **Pre-migration**: Before running `mix ecto.migrate`

### 2. Retention Policy

```bash
# Keep daily backups for 7 days
find backups/ -name "pot_examples_dev_*.dump" -mtime +7 -delete

# Keep weekly backups for 30 days
find backups/ -name "weekly_*.dump" -mtime +30 -delete

# Keep monthly backups for 1 year
find backups/ -name "monthly_*.dump" -mtime +365 -delete
```

### 3. Backup Storage

- **Local**: `backups/` directory (for quick restore)
- **Remote**: Sync to S3, Google Drive, or remote server
- **Offsite**: Critical for disaster recovery

### 4. Security

```bash
# Encrypt backup
PGPASSWORD=postgres pg_dump -h localhost -p 7432 -U postgres \
  -Fc -Z 9 pot_examples_dev | \
  gpg --encrypt --recipient your@email.com > backups/encrypted_backup.dump.gpg

# Decrypt and restore
gpg --decrypt backups/encrypted_backup.dump.gpg | \
  PGPASSWORD=postgres pg_restore -h localhost -p 7432 -U postgres -d pot_examples_dev
```

## Troubleshooting

### Backup Takes Too Long

```bash
# Use directory format with parallel jobs
PGPASSWORD=postgres pg_dump -h localhost -p 7432 -U postgres \
  -Fd -Z 9 -j 4 -f backups/pot_examples_dev_dir pot_examples_dev
```

### Restore Fails with Permission Errors

```bash
# Restore without ownership
PGPASSWORD=postgres pg_restore -h localhost -p 7432 -U postgres \
  -d pot_examples_dev --no-owner --no-acl backups/pot_examples_dev.dump
```

### Out of Disk Space

```bash
# Stream directly to remote server
PGPASSWORD=postgres pg_dump -h localhost -p 7432 -U postgres \
  -Fc -Z 9 pot_examples_dev | \
  ssh user@remote-server "cat > /backups/pot_examples_dev.dump"
```

### Backup Includes Unwanted Tables

```bash
# Exclude specific tables
PGPASSWORD=postgres pg_dump -h localhost -p 7432 -U postgres \
  -Fc -Z 9 -T 'logs_*' -T 'temp_*' \
  -f backups/pot_examples_dev.dump pot_examples_dev
```

## Remote Backup Sync

### Sync to S3

```bash
# Install AWS CLI: sudo apt install awscli
aws s3 cp backups/pot_examples_dev.dump s3://my-bucket/db-backups/
```

### Sync to Remote Server

```bash
# Using rsync
rsync -avz backups/ user@backup-server:/data/backups/pot_examples/
```

### Sync to Google Drive

```bash
# Install rclone: https://rclone.org/
rclone copy backups/pot_examples_dev.dump gdrive:backups/
```

## Current Backup

**Latest backup**: `backups/pot_examples_dev_20251212_015911.dump`
**Size**: 510 MB
**Created**: December 12, 2025 02:01
**Format**: PostgreSQL custom format (compressed, level 9)

## Database Configuration

**Database**: pot_examples_dev
**Host**: localhost
**Port**: 7432
**User**: postgres
**Password**: postgres (development only!)

⚠️ **Warning**: Never commit database credentials to version control. Use environment variables in production.

## Related Documentation

- **ADBC Setup**: `~/projects/learn_erl/adbc/CUBE_TESTING_STATUS.md`
- **Connection Pool**: `CUBE_POOL_SETUP.md`
- **Saturation Testing**: `SATURATION_TESTING.md`

## Summary

✅ **Best backup method**: Custom format with `-Fc -Z 9`
✅ **Smallest size**: ~510 MB
✅ **Fastest restore**: Directory format with `-Fd -j 4`
✅ **Most portable**: SQL dump with gzip

Use custom format for regular backups and SQL dumps for version control or cross-platform transfers.
