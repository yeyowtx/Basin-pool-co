#!/bin/bash

# Basin Pool Co. - Auto Deploy Script
# This script automatically deploys changes to Netlify via GitHub

set -e  # Exit on any error

echo "🚀 Basin Pool Co. - Auto Deploy to Netlify"
echo "=========================================="

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Check if there are any changes to commit
if [[ -n $(git status --porcelain) ]]; then
    echo "📝 Changes detected, staging files..."
    git add .
    
    # Get commit message from user or use default
    if [[ -z "$1" ]]; then
        COMMIT_MSG="Auto-deploy: Updates to Basin Pool inventory app

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    else
        COMMIT_MSG="$1

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    fi
    
    echo "💾 Committing changes..."
    git commit -m "$COMMIT_MSG"
else
    echo "ℹ️  No uncommitted changes detected"
fi

# Check if there are commits to push
if [[ $(git rev-list --count HEAD ^origin/main 2>/dev/null || echo "1") -gt 0 ]]; then
    echo "⬆️  Pushing to GitHub..."
    git push origin main
    
    echo "✅ Successfully deployed to GitHub!"
    echo "🌐 Netlify will automatically build and deploy your changes"
    echo "📱 Your app will be live at: https://neon-kheer-4be3e9.netlify.app"
    echo "⏱️  Deployment typically takes 2-5 minutes"
    
    # Optional: Open the site (uncomment if desired)
    # echo "🔗 Opening site in browser..."
    # open "https://neon-kheer-4be3e9.netlify.app"
    
else
    echo "ℹ️  No new commits to push"
    echo "🌐 Your app is already up to date at: https://neon-kheer-4be3e9.netlify.app"
fi

echo "✨ Deploy complete!"