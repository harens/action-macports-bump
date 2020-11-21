#!/bin/bash

echo -e "\033[1;94m🔧 Setting up MacPorts"
curl -LO https://raw.githubusercontent.com/GiovanniBussi/macports-ci/master/macports-ci

# File is downloaded above
# TODO: Add a backup file which can be checked
# shellcheck disable=SC1091
source ./macports-ci install

echo -e "\033[1;94m⬇️ Installing GitHub CLI"
sudo port install gh

echo -e "\033[1;94m😀 Authenticating GitHub CLI"
echo "$TOKEN" >> token.txt
gh auth login --with-token < token.txt
gh auth status

echo -e "\033[1;94m🔍 Determining current outdated version"
CURRENT=$(port info --version "$NAME" | sed 's/[A-Za-z: ]*//g')  # Remove letters, colon and space
echo "Current version number is $CURRENT!"

echo -e "\033[1;94m🏷️ Determining new version from tag"
# We want to keep the dots, but remove all letters
TAG="${TAG//[A-Za-z]}"
echo "New version number is $TAG!"

echo -e "\033[1;94m📒 Determining Category"
CATEGORY=$(port info --category "$NAME")
# Only take the first category
# Replace commas with line breaks
CATEGORY=$(echo "$CATEGORY" | cut -d' ' -f2 | tr "," "\n")
echo "Category is $CATEGORY!"

echo -e "\033[1;94m⬇️ Cloning MacPorts Repo"
gh repo fork "$REPO" --clone=true --remote=true
# Name of the cloned folder
CLONE=$(echo "$REPO" | awk -F'/' '{print $2}')
git clone https://"$USER":"$TOKEN"@github.com/"$USER"/"$CLONE"

echo -e "\033[1;94m📁 Creating local Portfile Repo"
mkdir -p ports/"$CATEGORY"/"$NAME"
# Copy Portfile to the local repo
cp "$CLONE"/"$CATEGORY"/"$NAME"/Portfile ports/"$CATEGORY"/"$NAME"/Portfile
# shellcheck disable=SC1091
source ./macports-ci localports ports

echo -e "\033[1;94m⏫ Bumping Version"
# Replaces first instance of old version with new version
sed -i '' "1,/$CURRENT/ s/$CURRENT/$TAG/" ports/"$CATEGORY"/"$NAME"/Portfile
sudo port bump "$NAME"

echo -e "\033[1;94m📨 Sending PR"

cd "$CLONE" || exit 1
git checkout -b bump-"$NAME"
# Copy changes back to main repo
cp ../ports/"$CATEGORY"/"$NAME"/Portfile "$CATEGORY"/"$NAME"/Portfile
git add "$CATEGORY"/"$NAME"/Portfile
git commit -m "$NAME: update to $TAG"
# git push --set-upstream origin bump-"$NAME"
gh pr create --title "$NAME: update to $TAG" --body "Created with [action-macports-bump](https://github.com/harens/action-macports-bump)" --head=bump-"$NAME"

echo -e "\033[1;94m🎉 PR Sent!"
