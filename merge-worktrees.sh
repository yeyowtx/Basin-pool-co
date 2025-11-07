#!/bin/bash

# Safe Worktree Merge Script
# Usage: ./merge-worktrees.sh [source_worktree] [target_worktree]
# Example: ./merge-worktrees.sh roof-worktree-cards roof-worktree-maps

set -e  # Exit on any error

MAIN_FILE="/Users/apple/index.html"
BACKUP_DIR="/Users/apple/.merge-backups"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# Create backup directory
mkdir -p "$BACKUP_DIR"

function show_usage() {
    echo "Usage: ./merge-worktrees.sh [source_worktree] [target_worktree]"
    echo ""
    echo "Available worktrees:"
    echo "  - roof-worktree-cards"
    echo "  - roof-worktree-designing-tool"  
    echo "  - roof-worktree-leftpanel"
    echo "  - roof-worktree-maps"
    echo ""
    echo "Example:"
    echo "  ./merge-worktrees.sh roof-worktree-cards roof-worktree-maps"
    echo ""
    echo "This will merge changes FROM cards INTO maps, with full backup protection."
}

if [ $# -ne 2 ]; then
    show_usage
    exit 1
fi

SOURCE_WORKTREE="$1"
TARGET_WORKTREE="$2"
SOURCE_PATH="/Users/apple/$SOURCE_WORKTREE/index.html"
TARGET_PATH="/Users/apple/$TARGET_WORKTREE/index.html"

# Validate paths
if [ ! -f "$SOURCE_PATH" ]; then
    echo "❌ Source file not found: $SOURCE_PATH"
    exit 1
fi

if [ ! -f "$TARGET_PATH" ]; then
    echo "❌ Target file not found: $TARGET_PATH"
    exit 1
fi

echo "🔄 Starting SAFE merge process..."
echo "📁 Source: $SOURCE_PATH"
echo "📁 Target: $TARGET_PATH"
echo ""

# Step 1: Create comprehensive backups
echo "💾 Step 1: Creating backups..."
cp "$MAIN_FILE" "$BACKUP_DIR/main_${TIMESTAMP}.html"
cp "$SOURCE_PATH" "$BACKUP_DIR/source_${SOURCE_WORKTREE}_${TIMESTAMP}.html"  
cp "$TARGET_PATH" "$BACKUP_DIR/target_${TARGET_WORKTREE}_${TIMESTAMP}.html"

# Git backup
git add index.html
git commit -m "Pre-merge backup: $SOURCE_WORKTREE → $TARGET_WORKTREE

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>" || echo "No changes to commit"

echo "✅ Backups created in: $BACKUP_DIR"
echo ""

# Step 2: Analyze differences
echo "📊 Step 2: Analyzing differences..."
echo "Differences between source and target:"
if diff -u "$SOURCE_PATH" "$TARGET_PATH" > "$BACKUP_DIR/differences_${TIMESTAMP}.diff"; then
    echo "✅ Files are identical - no merge needed!"
    exit 0
else
    echo "📝 Differences saved to: $BACKUP_DIR/differences_${TIMESTAMP}.diff"
    echo ""
    echo "Preview of key differences:"
    head -20 "$BACKUP_DIR/differences_${TIMESTAMP}.diff"
    echo ""
fi

# Step 3: User confirmation
echo "⚠️  Step 3: Merge Confirmation"
echo "This will merge FROM: $SOURCE_WORKTREE"
echo "             INTO: $TARGET_WORKTREE"
echo ""
read -p "Continue with merge? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Merge cancelled by user"
    exit 1
fi

# Step 4: Perform merge using git merge-file
echo "🔀 Step 4: Performing smart merge..."

# Create temporary files for 3-way merge
TEMP_DIR=$(mktemp -d)
cp "$MAIN_FILE" "$TEMP_DIR/base.html"
cp "$SOURCE_PATH" "$TEMP_DIR/source.html"
cp "$TARGET_PATH" "$TEMP_DIR/target.html"

# Attempt automatic merge
if git merge-file "$TEMP_DIR/target.html" "$TEMP_DIR/base.html" "$TEMP_DIR/source.html"; then
    echo "✅ Automatic merge successful!"
    
    # Copy merged result
    cp "$TEMP_DIR/target.html" "$TARGET_PATH"
    echo "✅ Merged file saved to: $TARGET_PATH"
    
else
    echo "⚠️  Merge conflicts detected!"
    echo "📝 Manual resolution needed in: $TEMP_DIR/target.html"
    echo ""
    echo "Conflict markers:"
    echo "  <<<<<<< your version"
    echo "  ======= "
    echo "  >>>>>>> their version"
    echo ""
    read -p "Open merge file in VS Code for manual resolution? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        code "$TEMP_DIR/target.html"
        echo ""
        read -p "After resolving conflicts, press Enter to continue..."
        cp "$TEMP_DIR/target.html" "$TARGET_PATH"
        echo "✅ Manually merged file saved to: $TARGET_PATH"
    else
        echo "❌ Merge incomplete - manual resolution required"
        echo "📁 Temp files preserved in: $TEMP_DIR"
        exit 1
    fi
fi

# Step 5: Update main file and sync
echo ""
echo "🔄 Step 5: Updating main file and syncing..."
cp "$TARGET_PATH" "$MAIN_FILE"

# Run sync to propagate changes
./sync-worktrees.sh

# Final commit
git add index.html
git commit -m "Merged $SOURCE_WORKTREE → $TARGET_WORKTREE

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

echo ""
echo "🎉 MERGE COMPLETED SUCCESSFULLY!"
echo ""
echo "📋 Summary:"
echo "  ✅ Backups created in: $BACKUP_DIR"
echo "  ✅ Merged: $SOURCE_WORKTREE → $TARGET_WORKTREE" 
echo "  ✅ Main file updated: $MAIN_FILE"
echo "  ✅ All worktrees synchronized"
echo "  ✅ Git commits created"
echo ""
echo "🖥️  View result: http://localhost:8104/index.html"

# Cleanup temp directory
rm -rf "$TEMP_DIR"