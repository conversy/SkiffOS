# /mnt/boot is mounted by skiff-init-squashfs.
export BOOT_DEVICE="LABEL=system"
# export MOUNT_BOOT_DEVICE="true"
export PERSIST_DEVICE="LABEL=userdata"
export ROOTFS_DEVICE="/mnt/boot"
export ROOTFS_MNT_FLAGS="--rbind"
export DISABLE_RESIZE_PERSIST="true"
