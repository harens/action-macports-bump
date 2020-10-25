#!/bin/bash

# Based off https://github.com/macports/macports-ports/blob/master/_ci/bootstrap.sh

# Copyright (c) 2020 The MacPorts Project
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of Apple Inc. nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

mdutil -sa

set -e

echo "Disable NTP clock sync"
# https://trac.macports.org/ticket/58800
/usr/bin/sudo /bin/launchctl unload /System/Library/LaunchDaemons/com.apple.timed.plist &


echo "Guard against intermittent Travis CI DNS outages"
for host in distfiles.macports.org dl.bintray.com github.com packages.macports.org packages-private.macports.org rsync-origin.macports.org github-production-release-asset-2e65be.s3.amazonaws.com; do
    dig +short "$host" | sed -n '$s/$/ '"$host/p" | sudo tee -a /etc/hosts >/dev/null
done

OS_MAJOR=$(uname -r | cut -f 1 -d .)

# Download resources in background ASAP but use later
echo "Download resources"
curl -fsSLO "https://dl.bintray.com/macports-ci-bot/macports-base/2.6r0/MacPorts-${OS_MAJOR}.tar.bz2" &
curl_mpbase_pid=$!
curl -fsSLO "https://dl.bintray.com/macports-ci-bot/getopt/getopt-v1.1.6.tar.bz2" &
curl_getopt_pid=$!
curl -fsSLO "https://github.com/macports/mpbot-github/releases/download/v0.0.1/runner" &
curl_runner_pid=$!

echo "Uninstall Homebrew"
brew --version
/usr/bin/sudo /usr/bin/find /usr/local -mindepth 2 -delete && hash -r

# Built by https://github.com/macports/macports-base/blob/travis-ci/.travis.yml
echo "Download and Install MacPorts"
wait $curl_mpbase_pid
sudo tar -xpf "MacPorts-${OS_MAJOR}.tar.bz2" -C /
rm -f "MacPorts-${OS_MAJOR}.tar.bz2"

echo "Set PATH for portindex"
source /opt/local/share/macports/setupenv.bash
echo "Set ports tree to $PWD"
sudo sed -i "" "s|rsync://rsync.macports.org/macports/release/tarballs/ports.tar|file://${PWD}|; /^file:/s/default/nosync,default/" /opt/local/etc/macports/sources.conf
echo "Set CI as not interactive"
echo "ui_interactive no" | sudo tee -a /opt/local/etc/macports/macports.conf >/dev/null
echo "Set to only download from the CDN, not the mirrors"
echo "host_blacklist *.distfiles.macports.org *.packages.macports.org" | sudo tee -a /opt/local/etc/macports/macports.conf >/dev/null
echo "Set to try downloading archives from the private server after trying the public server"
echo "archive_site_local https://packages.macports.org/:tbz2 https://packages-private.macports.org/:tbz2" | sudo tee -a /opt/local/etc/macports/macports.conf >/dev/null
# Prefer to get archives from the public server instead of the private server
# preferred_hosts has no effect on archive_site_local
# See https://trac.macports.org/ticket/57720
#echo "preferred_hosts packages.macports.org" | sudo tee -a /opt/local/etc/macports/macports.conf >/dev/null

echo "Update PortIndex"
rsync --no-motd -zvl "rsync://rsync-origin.macports.org/macports/release/ports/PortIndex_darwin_${OS_MAJOR}_i386/PortIndex" .

echo "Clone MacPorts"
git clone https://github.com/macports/macports-ports
cd macports-ports

echo "Checkout branch"
git checkout -b $NAME

echo "Create MacPorts user"
sudo /opt/local/postflight && sudo rm -f /opt/local/postflight
