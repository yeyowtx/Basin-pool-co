#!/bin/bash

# Sync script: Copy master file to all worktrees
# Usage: ./sync-worktrees.sh

MASTER_FILE="/Users/apple/index.html"
WORKTREES=(
    "/Users/apple/roof-worktree-cards"
    "/Users/apple/roof-worktree-designing-tool" 
    "/Users/apple/roof-worktree-leftpanel"
    "/Users/apple/roof-worktree-maps"
)

echo "🔄 Syncing master file to all worktrees..."
echo "📁 Master: $MASTER_FILE"

for worktree in "${WORKTREES[@]}"; do
    if [ -d "$worktree" ]; then
        echo "   → Copying to: $worktree/index.html"
        cp "$MASTER_FILE" "$worktree/index.html"
        echo "   ✅ Synced: $worktree"
    else
        echo "   ⚠️  Directory not found: $worktree"
    fi
done

# Also sync CLAUDE.md to worktrees
echo ""
echo "📝 Syncing CLAUDE.md to all worktrees..."
for worktree in "${WORKTREES[@]}"; do
    if [ -d "$worktree" ]; then
        cp "/Users/apple/CLAUDE.md" "$worktree/CLAUDE.md" 2>/dev/null || true
        echo "   ✅ CLAUDE.md synced to: $worktree"
    fi
done

echo ""
echo "🎯 All worktrees now use the same master file!"
echo "🖥️  Working URL: http://localhost:8104/index.html"
echo "📂 Master File: $MASTER_FILE"