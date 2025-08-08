#!/bin/bash

# Quick Deploy - Simple script to commit and push changes automatically
# Usage: ./quick-deploy.sh "Your commit message"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Basin Pool Co. Quick Deploy${NC}"
echo -e "${BLUE}==============================${NC}"

# Get commit message from parameter or use default
COMMIT_MSG=${1:-"Quick deploy: Basin Pool inventory updates"}

# Add Claude Code signature
FULL_MSG="$COMMIT_MSG

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Check for changes
if [[ -n $(git status --porcelain) ]]; then
    echo -e "${YELLOW}📝 Changes detected, committing...${NC}"
    git add .
    git commit -m "$FULL_MSG"
    echo -e "${GREEN}✅ Changes committed${NC}"
else
    echo -e "${YELLOW}ℹ️  No changes to commit${NC}"
fi

# Always try to push
echo -e "${YELLOW}⬆️  Pushing to GitHub...${NC}"
if git push origin main; then
    echo -e "${GREEN}✅ Successfully deployed!${NC}"
    echo -e "${GREEN}🌐 Netlify will deploy automatically${NC}"
    echo -e "${GREEN}📱 Live at: https://neon-kheer-4be3e9.netlify.app${NC}"
    echo -e "${BLUE}⏱️  Deployment takes 2-5 minutes${NC}"
else
    echo -e "${RED}❌ Push failed${NC}"
    exit 1
fi