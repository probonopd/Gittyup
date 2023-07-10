#!/bin/bash

git submodule init
git submodule update

# Install Qt
echo "deb http://ppa.launchpad.net/beineri/opt-qt-5.15.2-xenial/ubuntu xenial main" | sudo tee -a /etc/apt/sources.list/qt.list

sudo add-apt-repository ppa:beineri/opt-qt-5.15.2-xenial -y
sudo apt-get update -qq
sudo apt-get -y install qt515base qt515tools libgl1-mesa-dev ca-certificates wget
set +e ; source /opt/qt*/bin/qt*-env.sh ; set -e

# Install ninja
sudo pip install ninja

# Build OpenSSL; why does it need a private (self-built) version?
cd dep/openssl/openssl
./config -fPIC
make -j $(npoc)
cd ../../..

# Build
mkdir -p build/release
cd build/release
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/ ../..
ninja
DESTDIR=./appdir ninja install
find ./appdir
rm -rf ./appdir/usr/include/
strip ./appdir/usr/bin/cmark ./appdir/usr/bin/gittyup ./appdir/usr/bin/indexer ./appdir/usr/bin/relauncher

# Deploy dependencies into AppDir
# FIXME: Remove the need for "--no-check-certificate"
wget --no-check-certificate -c https://github.com/$(wget --no-check-certificate -q https://github.com/probonopd/go-appimage/releases/expanded_assets/continuous -O - | grep "appimagetool-.*-x86_64.AppImage" | head -n 1 | cut -d '"' -f 2)
chmod +x appimagetool-*.AppImage
LD_LIBRARY_PATH=/opt/qt515/lib/ ./appimagetool-*.AppImage -s deploy ./appdir/usr/share/applications/*.desktop --appimage-extract-and-run # Bundle EVERYTHING

# Modify the AppDir: move ld-linux into the same directory as the payload application
# and change AppRun accordingly; so that, e.g., Qt qApp->applicationDirPath() works
mv ./appdir/lib64/ld-linux-x86-64.so.2 ./appdir/usr/bin/
sed -i -e 's@^LD_LINUX.*@LD_LINUX=$(find "$HERE/usr/bin" -name "ld-*.so.*" | head -n 1)@g' ./appdir/AppRun

# Turn AppDir into AppImage
./appimagetool-*.AppImage ./appdir --appimage-extract-and-run # turn AppDir into AppImage

# Two files have been generated, both must be uploaded to GitHub Releases for AppImageUpdate to work
ls -lh Gittyup-*
