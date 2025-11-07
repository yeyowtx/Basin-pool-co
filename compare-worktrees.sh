#!/bin/bash

# Compare Worktree Changes Script
# Usage: ./compare-worktrees.sh [worktree1] [worktree2]
# Example: ./compare-worktrees.sh roof-worktree-cards roof-worktree-maps

function show_usage() {
    echo "Usage: ./compare-worktrees.sh [worktree1] [worktree2]"
    echo ""
    echo "Available worktrees:"
    echo "  - main (master file)"
    echo "  - roof-worktree-cards"
    echo "  - roof-worktree-designing-tool"  
    echo "  - roof-worktree-leftpanel"
    echo "  - roof-worktree-maps"
    echo ""
    echo "Example:"
    echo "  ./compare-worktrees.sh main roof-worktree-cards"
    echo "  ./compare-worktrees.sh roof-worktree-cards roof-worktree-maps"
}

if [ $# -ne 2 ]; then
    show_usage
    exit 1
fi

WORKTREE1="$1"
WORKTREE2="$2"

# Set file paths
if [ "$WORKTREE1" = "main" ]; then
    FILE1="/Users/apple/index.html"
else
    FILE1="/Users/apple/$WORKTREE1/index.html"
fi

if [ "$WORKTREE2" = "main" ]; then
    FILE2="/Users/apple/index.html"
else
    FILE2="/Users/apple/$WORKTREE2/index.html"
fi

# Validate files exist
if [ ! -f "$FILE1" ]; then
    echo "❌ File not found: $FILE1"
    exit 1
fi

if [ ! -f "$FILE2" ]; then
    echo "❌ File not found: $FILE2"
    exit 1
fi

echo "🔍 Comparing worktrees:"
echo "📁 $WORKTREE1: $FILE1"
echo "📁 $WORKTREE2: $FILE2"
echo ""

# Check if files are identical
if cmp -s "$FILE1" "$FILE2"; then
    echo "✅ Files are IDENTICAL - no differences found!"
    exit 0
fi

echo "📊 DIFFERENCES DETECTED:"
echo ""

# Show basic file info
echo "📋 File Information:"
echo "  $WORKTREE1: $(wc -l < "$FILE1") lines, $(wc -c < "$FILE1") bytes"
echo "  $WORKTREE2: $(wc -l < "$FILE2") lines, $(wc -c < "$FILE2") bytes"
echo ""

# Show line-by-line differences
echo "📝 Detailed Differences:"
echo "----------------------------------------"
diff -u "$FILE1" "$FILE2" | head -50
echo "----------------------------------------"
echo ""

# Count differences
DIFF_LINES=$(diff "$FILE1" "$FILE2" | wc -l)
echo "📊 Total difference lines: $DIFF_LINES"
echo ""

# Search for specific features
echo "🔍 Feature Detection:"
echo ""

echo "Check Marks (✓):"
echo "  $WORKTREE1: $(grep -c "✓\|✔\|check.*mark" "$FILE1" || echo "0")"
echo "  $WORKTREE2: $(grep -c "✓\|✔\|check.*mark" "$FILE2" || echo "0")"
echo ""

echo "Emojis:"
echo "  $WORKTREE1: $(grep -c "🏠\|📏\|🔴\|💡" "$FILE1" || echo "0")"
echo "  $WORKTREE2: $(grep -c "🏠\|📏\|🔴\|💡" "$FILE2" || echo "0")"
echo ""

echo "Base64 Images:"
echo "  $WORKTREE1: $(grep -c "data:image\|base64" "$FILE1" || echo "0")"
echo "  $WORKTREE2: $(grep -c "data:image\|base64" "$FILE2" || echo "0")"
echo ""

echo "Material Calculator:"
echo "  $WORKTREE1: $(grep -c "material.*calculator\|Total.*Cost" "$FILE1" || echo "0")"
echo "  $WORKTREE2: $(grep -c "material.*calculator\|Total.*Cost" "$FILE2" || echo "0")"
echo ""

# Offer to save differences
read -p "💾 Save detailed differences to file? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    DIFF_FILE="/Users/apple/.backups/compare_${WORKTREE1}_vs_${WORKTREE2}_$(date '+%Y%m%d_%H%M%S').diff"
    mkdir -p "/Users/apple/.backups"
    diff -u "$FILE1" "$FILE2" > "$DIFF_FILE"
    echo "✅ Differences saved to: $DIFF_FILE"
fi

echo ""
echo "🔗 Next steps:"
echo "  • To merge: ./merge-worktrees.sh $WORKTREE1 $WORKTREE2"
echo "  • To backup: ./backup-script.sh 'Before merge comparison'"