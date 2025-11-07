#!/bin/bash

# Auto-backup script for roof measurement tool
# Usage: ./backup-script.sh "description of changes"

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_DIR="/Users/apple/.backups"
DESCRIPTION="${1:-Auto-backup}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Copy current file with timestamp
cp index.html "$BACKUP_DIR/index_${TIMESTAMP}.html"

# Git commit with description
git add index.html
git commit -m "$DESCRIPTION

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

echo "✅ Backup created: $BACKUP_DIR/index_${TIMESTAMP}.html"
echo "✅ Git commit created with message: $DESCRIPTION"