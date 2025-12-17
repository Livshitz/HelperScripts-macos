#!/bin/bash

# Script to reset current branch to match another branch locally
# Usage: ./reset-branch.sh <target-branch>

if [ -z "$1" ]; then
  echo "Error: No target branch specified"
  echo "Usage: ./reset-branch.sh <target-branch>"
  echo "Example: ./reset-branch.sh lab"
  exit 1
fi

TARGET_BRANCH="$1"
CURRENT_BRANCH=$(git branch --show-current)

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not in a git repository"
  exit 1
fi

# Check if target branch exists
if ! git show-ref --verify --quiet "refs/heads/$TARGET_BRANCH"; then
  echo "Error: Branch '$TARGET_BRANCH' does not exist locally"
  exit 1
fi

echo "Current branch: $CURRENT_BRANCH"
echo "Resetting to: $TARGET_BRANCH"
echo ""
read -p "Are you sure? This will discard all changes on $CURRENT_BRANCH (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted"
  exit 0
fi

# Reset current branch to target branch
git reset --hard "$TARGET_BRANCH"

echo ""
echo "✓ Successfully reset $CURRENT_BRANCH to $TARGET_BRANCH"

