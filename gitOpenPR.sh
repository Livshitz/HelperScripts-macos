#!/bin/bash

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Base branch (default: main)
BASE_BRANCH=${1:-main}

# Get remote URL and extract owner/repo
REMOTE_URL=$(git remote get-url origin)

# Handle both SSH and HTTPS formats
if [[ $REMOTE_URL =~ git@[^:]+:(.+)\.git$ ]]; then
  REPO_PATH="${BASH_REMATCH[1]}"
elif [[ $REMOTE_URL =~ https://[^/]+/(.+)\.git$ ]]; then
  REPO_PATH="${BASH_REMATCH[1]}"
else
  echo "Error: Could not parse remote URL: $REMOTE_URL"
  exit 1
fi

# Construct PR URL
PR_URL="https://github.com/${REPO_PATH}/compare/${BASE_BRANCH}...${CURRENT_BRANCH}?expand=1"

echo "Opening PR: ${BASE_BRANCH}...${CURRENT_BRANCH}"
open "$PR_URL"
