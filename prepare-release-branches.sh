#!/bin/bash
set -euo pipefail

echo "+----------------------------+"
echo "| Preparing Release Branches |"
echo "+----------------------------+"

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
BRANCH_NAME="newrelease/${TASK_NUMBER}_merge_develop_release_${DATESTAMP}"
UAT_BRANCH_NAME="newrelease/${TASK_NUMBER}_merge_release_uat_${DATESTAMP}"

# ----- Initial preparation -----
echo_space
echo "Initial preparation..."

#Pull the latest changes from the remote repository
echo "Fetching the latest changes from the remote repository..."
git fetch origin

# Check if branches already exists
echo "Checking if the branch '$BRANCH_NAME' already exists..."
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  echo_space
  echo "ERROR: Branch '$BRANCH_NAME' already exists. Please delete it or choose a different task number."
  echo_space
  git checkout develop
  exit 2
fi

echo "Checking if the branch '$UAT_BRANCH_NAME' already exists..."
if git show-ref --verify --quiet "refs/heads/$UAT_BRANCH_NAME"; then
  echo_space
  echo "ERROR: Branch '$UAT_BRANCH_NAME' already exists. Please delete it or choose a different task number."
  echo_space
  git checkout develop
  exit 3
fi

# Pull the latest changes from the develop branch
echo "Pulling the latest changes from the develop branch..."
git checkout develop
git pull origin develop

# ----- Release branch preparation -----
unset PRE_MERGE_HEAD
unset POST_MERGE_HEAD

echo_space
echo "Preparing release branch: $BRANCH_NAME"

# Pull the latest changes from the release branch
echo "Pulling the latest changes from the release branch..."
git checkout release
git pull origin release

# Create a new branch from release branch
echo "Create a new branch '$BRANCH_NAME' from release branch"
git checkout -b "$BRANCH_NAME"

# Merge the develop branch into the new release branch
echo "Merging develop branch into $BRANCH_NAME"
PRE_MERGE_HEAD="$(git rev-parse HEAD)"
if ! git merge develop --no-ff -m "Merge develop into $BRANCH_NAME"; then
  echo_space
  echo "ERROR: Merge failed. Please resolve conflicts and try again."
  echo_space
  git merge --abort
  git checkout develop
  git branch -D "$BRANCH_NAME"
  echo_space
  exit 4
fi

# Check if there were changes merged into the new release branch
echo "Checking if there were changes merged into the new release branch..."
POST_MERGE_HEAD="$(git rev-parse HEAD)"
if [ "$PRE_MERGE_HEAD" = "$POST_MERGE_HEAD" ]; then
  echo_space
  echo "ERROR: No changes were merged into the new release branch. Please check the develop and release branches for differences."
  echo_space
  git checkout develop
  git branch -D "$BRANCH_NAME"
  exit 5
fi

echo_space
echo "New release branch '$BRANCH_NAME' created successfully and merged with develop branch."
echo_space

# ----- UAT branch preparation -----
unset PRE_MERGE_HEAD
unset POST_MERGE_HEAD

echo_space
echo "Preparing UAT branch: $UAT_BRANCH_NAME"

# Pull the latest changes from the uat branch
echo "Pulling the latest changes from the uat branch..."
git checkout uat
git pull origin uat

# Create a new branch from uat branch
echo "Create a new branch '$UAT_BRANCH_NAME' from uat branch"
git checkout -b "$UAT_BRANCH_NAME"

# Merge the new release branch into the new UAT branch
echo "Merging $BRANCH_NAME into $UAT_BRANCH_NAME"
PRE_MERGE_HEAD="$(git rev-parse HEAD)"
if ! git merge "$BRANCH_NAME" --no-ff -m "Merge '$BRANCH_NAME' into '$UAT_BRANCH_NAME'"; then
  echo_space
  echo "ERROR: Merge failed. Please resolve conflicts and try again."
  echo_space
  git merge --abort
  git checkout develop
  git branch -D "$UAT_BRANCH_NAME"
  echo_space
  exit 7
fi

# Check if there were changes merged into the new UAT branch
echo "Checking if there were changes merged into the new UAT branch..."
POST_MERGE_HEAD="$(git rev-parse HEAD)"
if [ "$PRE_MERGE_HEAD" = "$POST_MERGE_HEAD" ]; then
  echo_space
  echo "ERROR: No changes were merged into the new UAT branch. Please check the develop and release branches for differences."
  echo_space
  git checkout develop
  git branch -D "$UAT_BRANCH_NAME"
  exit 8
fi

echo_space
echo "New UAT branch '$UAT_BRANCH_NAME' created successfully and merged with '$BRANCH_NAME' branch."
echo_space

# ----- Push branches to origin -----
echo_space
echo "Pushing branches to the remote repository..."

# Push the new release branch to the remote repository
echo_space
echo "Pushing the new release branch '$BRANCH_NAME' to the remote repository..."
if ! git push origin "$BRANCH_NAME"; then
  echo_space
  echo "ERROR: Failed to push the new release branch '$BRANCH_NAME' to the remote repository. Please check your network connection and remote repository settings."
  echo_space
  git checkout develop
  git branch -D "$BRANCH_NAME"
  exit 6
fi

# Push the new UAT branch to the remote repository
echo_space
echo "Pushing the new UAT branch '$UAT_BRANCH_NAME' to the remote repository..."
if ! git push origin "$UAT_BRANCH_NAME"; then
  echo_space
  echo "ERROR: Failed to push the new UAT branch '$UAT_BRANCH_NAME' to the remote repository. Please check your network connection and remote repository settings."
  echo_space
  git checkout develop
  git branch -D "$UAT_BRANCH_NAME"
  exit 9
fi

# ----- Final instructions -----
git checkout develop
echo_space

echo "+--------------------+"
echo "| Final Instructions |"
echo "+--------------------+"

echo_space
echo "Create a pull request to merge the new release branch '$BRANCH_NAME' into 'RELEASE' using the GitHub web interface."
echo_space
echo "Create a pull request to merge the new UAT branch '$UAT_BRANCH_NAME' into 'UAT' using the GitHub web interface."
echo_space
exit 0

# # Create a pull request for the new release branch
# echo "Creating a pull request for the new release branch '$BRANCH_NAME'..."
# if ! gh pr create --base release --head "$BRANCH_NAME" --title "Merge $BRANCH_NAME into release" --body "This pull request merges the changes from the develop branch into the release branch for task $TASK_NUMBER."; then
  # echo_space
  # echo "Failed to create a pull request for the new release branch '$BRANCH_NAME'. Create one manually using the GitHub web interface."
  # echo_space
  # git checkout develop
  # exit 7
# fi

# # Create a pull request for the new release branch
# echo "Creating a pull request for the new UAT branch '$UAT_BRANCH_NAME'..."
# if ! gh pr create --base uat --head "$UAT_BRANCH_NAME" --title "Merge $BRANCH_NAME into uat" --body "This pull request merges the changes from the new release branch into the uat branch for task $TASK_NUMBER."; then
  # echo_space
  # echo "Failed to create a pull request for the new UAT branch '$UAT_BRANCH_NAME'. Create one manually using the GitHub web interface."
  # echo_space
  # git checkout develop
  # exit 7
# fi
