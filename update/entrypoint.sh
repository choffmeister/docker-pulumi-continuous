#!/bin/bash
set -e

MODE="$1"
GIT_BRANCH="$2"
GIT_MESSAGE="$3"

# create temporary directory
TEMP_DIR="$(mktemp -d)"
cd "${TEMP_DIR}"

# create new branch from old base branch
echo "Checking out repository..."
GIT_BRANCH_BASE="${GIT_BRANCH}"
GIT_BRANCH_NEXT="deployment/$(date '+%Y%m%d%H%M%S')"
git clone -b "${GIT_BRANCH_BASE}" --single-branch --depth=1 "https://${GITHUB_USER}:${GITHUB_ACCESS_TOKEN}@github.com/${GITHUB_REPO}.git" .
git config user.name "${GITHUB_USER}"
git config user.email "${GITHUB_USER}@github"
git checkout -B "${GIT_BRANCH_NEXT}"

# update docker tags
echo "Updating docker tags..."
cd "${PULUMI_DIRECTORY:-.}"
pulumi login
pulumi stack select ${PULUMI_STACK}
for ARG in ${@:4}; do
  KEY=$(echo $ARG | awk -F '=' '{print $1}')
  VAL=$(echo $ARG | awk -F '=' '{print $2}')
  pulumi config set ${KEY} ${VAL}
done
git diff -U0 | cat
git add .
git commit -m "${GIT_MESSAGE}"

if [ "${MODE}" == "pr" ]; then
  # create pull request
  echo "Creating pull request..."
  git push origin "${GIT_BRANCH_NEXT}" -f
  curl -X POST "https://api.github.com/repos/${GITHUB_REPO}/pulls" \
    --fail \
    --silent \
    --output /dev/null \
    -u "${GITHUB_USER}:${GITHUB_ACCESS_TOKEN}" \
    -d @- << EOF
{
  "title": "${GIT_MESSAGE}",
  "body": "",
  "head": "${GIT_BRANCH_NEXT}",
  "base": "${GIT_BRANCH_BASE}"
}
EOF
elif [ "${MODE}" == "push" ]; then
  echo "Pushing..."
  git push origin "${GIT_BRANCH_NEXT}:${GIT_BRANCH_BASE}"
else
  echo "Unknown mode ${MODE}"
  exit 1
fi
