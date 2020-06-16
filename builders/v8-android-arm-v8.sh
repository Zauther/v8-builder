VERSION=$1

sudo apt-get install -y \
    pkg-config \
    git \
    subversion \
    curl \
    wget \
    build-essential \
    python \
    xz-utils \
    zip

git config --global user.name "V8 Android Builder"
git config --global user.email "v8.android.builder@localhost"
git config --global core.autocrlf false
git config --global core.filemode false
git config --global color.ui true


cd ~
echo "=====[ Getting Depot Tools ]====="	
git clone -q https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=$(pwd)/depot_tools:$PATH
gclient


mkdir v8
cd v8

echo "=====[ Fetching V8 ]====="
fetch v8
echo "target_os = ['android']" >> .gclient
cd ~/v8/v8
./build/install-build-deps-android.sh
git checkout $VERSION
gclient sync


echo "=====[ Building V8 ]====="
python ./tools/dev/v8gen.py arm64.release -vv -- '
target_os = "android"
target_cpu = "arm64"
v8_target_cpu = "arm64"
is_component_build = true
v8_enable_i18n_support = false
symbol_level = 0
'
ninja -C out.gn/arm64.release -t clean
ninja -C out.gn/arm64.release v8_libplatform
ninja -C out.gn/arm64.release v8