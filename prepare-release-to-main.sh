#!/bin/bash
set -euo pipefail

echo "+-------------------------+"
echo "| Preparing Main Branches |"
echo "+-------------------------+"

usage() {
  echo "Usage: $0 --task <task-number>"
}

echo_space() {
  echo " "
}

TASK_NUMBER=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --task)
      if [ -z "${2:-}" ]; then
        usage
        exit 1
      fi
      TASK_NUMBER="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [ -z "$TASK_NUMBER" ]; then
  usage
  exit 1
fi

command -v gh >/dev/null 2>&1 || { echo "ERROR: gh (GitHub CLI) not found"; exit 1; }

CURRENT_DATE="$(date -u +"%Y-%m-%d")"
DATESTAMP="$(date -u +"%Y%m%d")"
BRANCH_NAME="syncmain/${TASK_NUMBER}_merge_release_main_${DATESTAMP}"

# ----- Initial preparation -----
echo_space
echo "Initial preparation..."

# Pull the latest changes from the develop branch
echo "Pulling the latest changes from the develop branch..."
git checkout release
git pull origin release

#Pull the latest changes from the remote repository
echo "Fetching the latest changes from the remote repository..."
git fetch origin

# Check if branches already exists
echo "Checking if the branch '$BRANCH_NAME' already exists..."
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  echo_space
  echo "ERROR: Branch '$BRANCH_NAME' already exists. Please delete it or choose a different task number."
  echo_space
  git checkout release
  exit 2
fi

# Pull the latest changes from the develop branch
echo "Pulling the latest changes from the release branch..."
git checkout release
git pull origin release

# ----- Main branch preparation -----
unset PRE_MERGE_HEAD
unset POST_MERGE_HEAD

echo_space
echo "Preparing main branch: $BRANCH_NAME"

# Pull the latest changes from the release branch
echo "Pulling the latest changes from the release branch..."
git checkout main
git pull origin main

# Create a new branch from main branch
echo "Create a new branch '$BRANCH_NAME' from main branch"
git checkout -b "$BRANCH_NAME"

# Merge the release branch into the new main branch
echo "Merging release branch into $BRANCH_NAME"
PRE_MERGE_HEAD="$(git rev-parse HEAD)"
if ! git merge release --no-ff -m "Merge release into $BRANCH_NAME"; then
  echo_space
  echo "ERROR: Merge failed. Please resolve conflicts and try again."
  echo_space
  git merge --abort
  git checkout main
  git branch -D "$BRANCH_NAME"
  echo_space
  exit 4
fi

# Check if there were changes merged into the new release branch
echo "Checking if there were changes merged into the new release branch..."
POST_MERGE_HEAD="$(git rev-parse HEAD)"
if [ "$PRE_MERGE_HEAD" = "$POST_MERGE_HEAD" ]; then
  echo_space
  echo "ERROR: No changes were merged into the new main branch. Please check the release and main branches for differences."
  echo_space
  git checkout release
  git branch -D "$BRANCH_NAME"
  exit 5
fi

echo_space
echo "New main branch '$BRANCH_NAME' created successfully and merged with release branch."
echo_space

# ----- Push branches to origin -----
echo_space
echo "Pushing branches to the remote repository..."

# Push the new release branch to the remote repository
echo_space
echo "Pushing the new main branch '$BRANCH_NAME' to the remote repository..."
if ! git push origin "$BRANCH_NAME"; then
  echo_space
  echo "ERROR: Failed to push the new main branch '$BRANCH_NAME' to the remote repository. Please check your network connection and remote repository settings."
  echo_space
  git checkout release
  git branch -D "$BRANCH_NAME"
  exit 6
fi

# ----- Final instructions -----
git checkout release
echo_space

echo "+--------------------+"
echo "| Final Instructions |"
echo "+--------------------+"

echo_space
echo "Create a pull request to merge the new main branch '$BRANCH_NAME' into 'MAIN' using the GitHub web interface."
echo_space
exit 0
