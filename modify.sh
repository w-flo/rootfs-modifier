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

echo "Extracting files…"
unzip ../../saucy-preinstalled-touch-armhf.zip > /dev/null
gunzip saucy-preinstalled-touch-armhf.tar.gz

echo "Updating files…"
cp ../../replacements/find_extract_location.sh .
cp ../../replacements/ubuntu_deploy.sh .
cp ../../replacements/updater-script ./META-INF/com/google/android/
cd ../../replacements/targz
tar uf ../../tmp/zip/saucy-preinstalled-touch-armhf.tar *
tar --delete -f ../../tmp/zip/saucy-preinstalled-touch-armhf.tar --wildcards \
	SWAP.swap \
	var/cache/apt/pkgcache.bin \
	var/lib/apt/lists/*
cd ../../tmp/zip

echo "Compressing files…"
gzip saucy-preinstalled-touch-armhf.tar
zip -r ../../modified-saucy-preinstalled-touch-armhf.zip * > /dev/null
cd ../../
rm -r tmp/

echo "Done!"
