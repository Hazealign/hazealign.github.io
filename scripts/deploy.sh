#!/bin/bash

ENCRYPTION_LABEL="7fd66f08a613"
SOURCE_BRANCH="src"
TARGET_BRANCH="master"

# Save some useful information
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

# Clone the existing gh-pages for this repo into out/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deply)
git clone https://${GH_TOKEN}@github.com/Hazealign/hazealign.github.io.git out
cd out
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
cd ..

# Clean out existing contents
rm -rf out/**/* || exit 0

# Now let's go have some fun with the cloned repo
cd out
cp -R ./../_site/* .

git config --global user.name "Travis CI"
git config --global user.email "hazelee@re.aligni.st"

# If there are no changes to the compiled out (e.g. this is a README update) then just bail.
if [ -z `git diff --exit-code` ]; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
git add .
git commit -m "Deploy to GitHub Pages: ${SHA}"

# Now that we're all set up, we can push.
git push -f origin $TARGET_BRANCH 