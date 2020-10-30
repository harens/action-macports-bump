#!/bin/bash

echo -e "\033[1;94m🔧 Setting up MacPorts"
curl -LO https://raw.githubusercontent.com/GiovanniBussi/macports-ci/master/macports-ci
source ./macports-ci install

echo -e "\033[1;94m🔍 Determining current outdated version"
CURRENT=$(port info --version $NAME | sed 's/[A-Za-z: ]*//g')  # Remove letters, colon and space
echo "Current version number is $CURRENT!"

echo -e "\033[1;94m🏷️ Determining new version from tag"
# We want to keep the dots, but remove all letters
TAG=$(echo $TAG | sed 's/[A-Za-z]*//g')
echo "New version number is $TAG!"

echo -e "\033[1;94m📒 Determining Category"
CATEGORY=$(port info --category $NAME)
CATEGORY_LIST=($CATEGORY)
CATEGORY=${CATEGORY_LIST[1]}  # Only take the first category
CATEGORY=$(echo "$CATEGORY" | tr "," " ")  # Remove any commas
echo "Category is $CATEGORY!"

echo -e "\033[1;94m⬇️ Cloning MacPorts Repo"
git clone https://github.com/macports/macports-ports

echo -e "\033[1;94m📁 Creating local Portfile Repo"
mkdir -p ports/$CATEGORY/$NAME
# Copy Portfile to the local repo
cp macports-ports/$CATEGORY/$NAME/Portfile ports/$CATEGORY/$NAME/Portfile
source macports-ci localports ports

echo -e "\033[1;94m⬇️ Installing GitHub CLI"
sudo port install gh

echo -e "\033[1;94m😀 Authenticating GitHub CLI"
echo $TOKEN >> token.txt
gh auth login --with-token < token.txt
gh auth status

# (\d+\.)(\d+\.)(.*)

# echo "Checkout branch"
# git checkout -b $NAME
