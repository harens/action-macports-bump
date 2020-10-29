#!/bin/bash

echo "Setting up MacPorts"
curl -LO https://raw.githubusercontent.com/GiovanniBussi/macports-ci/master/macports-ci
source ./macports-ci install

echo "Removing text from tag"
TAG=${TAG//[!0-9]/}

# TODO: Remove "category: "
echo "Determining Category"
CATEGORY=$(port info --category $NAME)
CATEGORY_LIST=($CATEGORY)
CATEGORY=${CATEGORY_LIST[1]}  # Only take the first category
CATEGORY=$(echo "$CATEGORY" | tr "," " ")  # Remove any commas
echo "Category is $CATEGORY!"

echo "Cloning MacPorts Repo"
git clone https://github.com/macports/macports-ports

echo "Creating local Portfile Repo"
mkdir -p ports/$CATEGORY/$NAME
echo "Copying Portfile"
cp macports-ports/$CATEGORY/$NAME/Portfile ports/$CATEGORY/$NAME/Portfile
source macports-ci localports ports

echo "Installing GitHub CLI"
sudo port install gh

echo "Authenticating GitHub CLI"
echo $TOKEN >> token.txt
gh auth login --with-token < token.txt

# echo "Checkout branch"
# git checkout -b $NAME
