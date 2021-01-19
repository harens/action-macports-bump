#!/bin/bash

echo -e "\033[1;94m🔧 Setting up MacPorts"
curl -LO https://raw.githubusercontent.com/GiovanniBussi/macports-ci/master/macports-ci

# File is downloaded above
# TODO: Add a backup file which can be checked
# shellcheck disable=SC1091
source ./macports-ci install

echo -e "\033[1;94m⬇️ Installing seaport"
# Speed up a little by not running brew cleanup
export HOMEBREW_NO_INSTALL_CLEANUP="true"
# If this works remove --HEAD
brew install harens/tap/seaport --HEAD

echo -e "\033[1;94m😀 Authenticating GitHub CLI"
echo "$TOKEN" >> token.txt
gh auth login --with-token < token.txt
gh auth status

# For some reason the gh repo fork in seaport is too slow
# This clones it before hand using the pre-seaport method

# Homebrew doesn't like the USER variable being set
echo -e "\033[1;94m⬇️ Cloning MacPorts Repo"

# All of this should be unnecessary...but it isn't for some reason

gh repo fork macports/macports-ports
git clone https://"$GITHUB_USER":"$TOKEN"@github.com/"$GITHUB_USER"/macports-ports

cd macports-ports || exit 1
git remote add upstream "https://github.com/macports/macports-ports"
cd ..

# Uses the current directory
seaport pr "$NAME" "$(pwd)"
