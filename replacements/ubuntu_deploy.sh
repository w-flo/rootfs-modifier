#!/sbin/sh

android_boot=/system/boot

ubuntu=/data/ubuntu
ubuntu_boot=$ubuntu/boot
ubuntu_bak=/data/ubuntu_bak

phablet_home=$ubuntu/home/phablet
phablet_home_bak=$ubuntu_bak/home

timezone=$ubuntu/etc/timezone
timezone_bak=$ubuntu_bak/timezone

ofono=$ubuntu/var/lib/ofono
ofono_bak=$ubuntu_bak/ofono

network_settings=$ubuntu/etc/NetworkManager/system-connections
network_settings_bak=$ubuntu_bak/nm_connections

tmp_extract=/data/ubuntu_tmp_extract
tarball_location=$(/system/bin/getprop ubuntu.rootfs.extract.location)

backup() {
    mkdir -p $ubuntu_bak
    if [ -d $2 ]; then
        echo "Removing previous backout of $1"
        rm -rf $2
    fi
    if [ -d $1 ]; then
        echo "Backing up $1 to $2"
        mv $1 $2
    fi
}

restore() {
    if [ -d $2 ]; then
        echo "Restoring $1 from $2"
        rm -rf $1
        mv $2 $1
    fi
}

copy_android_ramdisk() {
    if [ -f $android_boot/android-ramdisk.img ]; then
        cp -f $android_boot/android-ramdisk.img $ubuntu_boot
    fi
}

deploy_ubuntu() {
    echo "Deploying Ubuntu from tarball $tarball_location"
    if [ -d $tmp_extract ]; then
        rm -rf $tmp_extract
    fi
    mkdir $tmp_extract
    tar --numeric-owner -xzf $tarball_location -C $tmp_extract
    rm $tarball_location
    if [ -d $ubuntu ]; then
        rm -rf $ubuntu
    fi
    mv $tmp_extract $ubuntu
}

backup $phablet_home $phablet_home_bak
backup $network_settings $network_settings_bak
backup $ofono $ofono_bak
backup $timezone $timezone_bak
deploy_ubuntu
copy_android_ramdisk
restore $phablet_home $phablet_home_bak
restore $network_settings $network_settings_bak
restore $ofono $ofono_bak
restore $timezone $timezone_bak
