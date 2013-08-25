#!/bin/sh

if [ -e modified-saucy-preinstalled-touch-armhf.zip ]; then
	echo "Please remove modified-saucy-preinstalled-touch-armhf.zip!"
	exit 1
fi

if [ -e tmp ]; then
	echo "Please remove the $(pwd)/tmp directory!"
	exit 1
fi


mkdir -p tmp/zip
cd tmp/zip

echo "Extracting files… (Need root to preserve file owner!!)"
unzip ../../saucy-preinstalled-touch-armhf.zip > /dev/null
mkdir targz
cd targz
tar xfz ../saucy-preinstalled-touch-armhf.tar.gz --exclude='dev/*' --same-owner
rm ../saucy-preinstalled-touch-armhf.tar.gz

echo "Updating files…"
rm -r \
	SWAP.swap \
	var/cache/apt/pkgcache.bin \
	var/cache/apt/srcpkgcache.bin \
	var/lib/apt/lists/* \
	var/log/lastlog
cp -r ../../../replacements/targz/* .

sed -i '/  . FIXME: Nexus7 (grouper)/ i\  # FIXME: HTC Desire Z (vision)\n  /dev/kgsl-2d0 rw,\n  /dev/genlock rw,\n  /sys/devices/system/soc/soc0/id r,\n' usr/share/apparmor/easyprof/templates/ubuntu/1.0/ubuntu-sdk

cd ..
cp ../../replacements/find_extract_location.sh .
cp ../../replacements/ubuntu_deploy.sh .
cp ../../replacements/updater-script ./META-INF/com/google/android/

rootfs_size=$(du -s --bytes targz/ | awk '{print $1}')
sed -i "s/__UBUNTU_ROOTFS_SIZE__/$rootfs_size/" find_extract_location.sh


echo "Compressing files…"
cd targz
tar cfz ../saucy-preinstalled-touch-armhf.tar.gz *
cd ..
rm -fr ./targz

zip -r ../../modified-saucy-preinstalled-touch-armhf.zip * > /dev/null
cd ../../
rm -r tmp/

echo "Done!"
