#!/sbin/sh

# threshold for free space on /data in kib
datafree_threshold=$(expr __UBUNTU_ROOTFS_SIZE__ / 512)

# threshold for free space on sdcard in kib
sdfree_threshold=$(expr __UBUNTU_ROOTFS_SIZE__ / 1024)


# check if the given parameter $1 is
#    * a mount point
#    * has enough free space ($2 kib)
# if so, mount the partition, set the "ubuntu.rootfs.extract.location" property
# based on the partition path and return 0, otherwise do nothing and return 1.
check_mount() {
    echo "Checking $1.."
    is_valid_storage=1 # assume this is not a valid storage

    mountpoint -q $1
    retcode=$?
    if [ $retcode -eq 0 ]; then # we have found a valid mount point..

        # see if this needs to be mounted first
        if mount | grep "on $1 "; then
            is_mounted=0 # is already mounted!
        else
            echo "Mounting $1.."
            is_mounted=1 # not mounted yet!
            mount $1
        fi

        # check free space on this partition
        freesize=$(df -P -B 1024 | grep $1 | awk '{ print $4 }')
        if [ -z $freesize ]; then freesize=0; fi

        if [ $freesize -ge $2 ]; then
            /system/bin/setprop ubuntu.rootfs.extract.location "$1/tmp-ubuntu-rootfs.tar.gz"
            is_valid_storage=0 # success
            echo "Using $1!"
        else
            echo "$1: Not enough free space, only $freesize / $2 KiB"
        fi

        # unmount if this was previously not mounted and is not valid storage
        if [ $is_mounted -eq 1 ] && [ $is_valid_storage -eq 1 ]; then
            echo "Unmounting $1.."
            umount $1
        fi
    fi

    return $is_valid_storage
}

# check possible locations (NB: mind the || at the end of each line)
check_mount "/data" $datafree_threshold ||
check_mount "/ext/sdcard" $sdfree_threshold ||
check_mount "/sdcard" $sdfree_threshold ||
/system/bin/setprop ubuntu.rootfs.extract.location "failed-targz"

datasize=$(df -P -B 1024 | grep "/data" | awk '{ print $4 }')
if [ -z $datasize ]; then datasize=0; fi
if [ $datasize -lt $(expr __UBUNTU_ROOTFS_SIZE__ / 1024) ]; then
    /system/bin/setprop ubuntu.rootfs.extract.location "failed-rootfs"
    echo "/data: Not enough free space to store the Ubuntu RootFS!"
fi


sync
