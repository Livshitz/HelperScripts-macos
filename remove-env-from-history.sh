#!/usr/bin/env bash

# Script to remove .env file from git history
# WARNING: This rewrites git history and requires force push if already pushed to remote

set -e

echo "⚠️  WARNING: This script will rewrite git history!"
echo "This will remove .env file from all commits in the repository."
echo ""
echo "Before proceeding:"
echo "  1. Make sure you have a backup of your .env file"
echo "  2. Notify team members if this is a shared repository"
echo "  3. After running, you'll need to force push: git push origin --force --all"
echo ""
read -p "Do you want to continue? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Step 1: Add .env to .gitignore if not already there
echo "📝 Checking .gitignore..."
if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
    echo "Adding .env to .gitignore..."
    cat >> .gitignore << EOF

# Environment variables
.env
.env.local
.env.*
.env.*.local
EOF
    echo "✅ .env added to .gitignore"
else
    echo "✅ .env already in .gitignore"
fi

# Step 2: Remove .env from git history
echo ""
echo "🔄 Removing .env from git history..."
export FILTER_BRANCH_SQUELCH_WARNING=1
git filter-branch --force --index-filter \
    "git rm --cached --ignore-unmatch .env" \
    --prune-empty --tag-name-filter cat -- --all

# Step 3: Clean up
echo ""
echo "🧹 Cleaning up..."

# Remove backup refs
git for-each-ref --format="delete %(refname)" refs/original | git update-ref --stdin 2>/dev/null || true

# Expire reflog
git reflog expire --expire=now --all

# Garbage collect
git gc --prune=now --aggressive

echo ""
echo "✅ Successfully removed .env from git history!"
echo ""
echo "📌 Next steps:"
echo "  1. Verify your .env file still exists locally"
echo "  2. If you've pushed to remote, run: git push origin --force --all"
echo "  3. Notify team members to re-clone or reset their repositories"
echo ""

