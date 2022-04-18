#!/bin/bash
set -eo pipefail

IMAGES_DIR=${SKIFF_BUILDROOT_DIR}/images
HOST_DIR=${SKIFF_BUILDROOT_DIR}/host
SYSFS_DIR=${SKIFF_BUILDROOT_DIR}/extra_images/sysfs
BOOT_DIR=${SYSFS_DIR}/boot
ROOTFS_DIR=${BOOT_DIR}
BOOT_IMAGE=${IMAGES_DIR}/apq8096-boot.img
SKIFF_IMAGE=${IMAGES_DIR}/apq8096-sysfs.ext4.img
SPARSE_SKIFF_IMAGE=${IMAGES_DIR}/apq8096-sysfs.ext4

if [ -f ${SKIFF_IMAGE} ]; then
    rm -f ${SKIFF_IMAGE}
fi
if [ -f ${SPARSE_SKIFF_IMAGE} ]; then
    rm -f ${SPARSE_SKIFF_IMAGE} || true
fi

mkdir -p ${SYSFS_DIR}
cd ${SYSFS_DIR}
mkdir -p bin dev etc lib mnt proc sbin sys tmp var

cd ${IMAGES_DIR}
mkdir -p ${BOOT_DIR}/skiff-init ${ROOTFS_DIR}/
if [ -d ${IMAGES_DIR}/rootfs_part/ ]; then
    rsync -rav ${IMAGES_DIR}/rootfs_part/ ${ROOTFS_DIR}/
fi
if [ -d ${IMAGES_DIR}/persist_part/ ]; then
    rsync -rav ${IMAGES_DIR}/persist_part/ ${SYSFS_DIR}/
fi
rsync -rv ./skiff-init/ ${BOOT_DIR}/skiff-init/
cp ${SKIFF_CURRENT_CONF_DIR}/resources/resize2fs.conf ./skiff-init/resize2fs.conf
rsync -rv \
  ./*.dtb ./*Image* \
  ./skiff-release ./rootfs.squashfs \
  ${BOOT_DIR}/

# boot symlinks
ln -fs /boot/skiff-init/skiff-init-squashfs ${SYSFS_DIR}/init
ln -fs /boot/skiff-init/skiff-init-squashfs ${SYSFS_DIR}/sbin/init
mkdir -p ${SYSFS_DIR}/lib/systemd
ln -fs /boot/skiff-init/skiff-init-squashfs ${SYSFS_DIR}/lib/systemd/systemd

# create sysfs.ext4
echo "Building raw image..."
${HOST_DIR}/sbin/mkfs.ext4 \
           -d ${SYSFS_DIR} \
           -L "sysfs" \
           -U "57f8f4bc-abf4-655f-bf67-946fc0f9f25b" \
           ${SKIFF_IMAGE} "2G"
# make it sparse
echo "Generating sparse $(basename ${SPARSE_SKIFF_IMAGE})..."
${HOST_DIR}/bin/img2simg \
           ${SKIFF_IMAGE} \
           ${SPARSE_SKIFF_IMAGE}
# delete old raw image
echo "Done, deleting raw image..."
rm ${SKIFF_IMAGE} || true

# create boot i
echo "Generating $(basename ${BOOT_IMAGE})..."
KERNEL_CMDLINE="noinitrd console=ttyMSM0,115200,n8 earlycon=msm_geni_serial,0xa90000 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 swiotlb=2048 loop.max_part=7 cgroup.memory=nokmem,nosocket reboot=panic_warm net.ifnames=0"
${HOST_DIR}/bin/mkbootimg \
           --kernel Image.gz \
           --cmdline "${KERNEL_CMDLINE}" \
           --base "0x80000000" \
           --kernel_offset "0x00008000" \
           --ramdisk_offset "0x00008000" \
           --second_offset "0x00f00000" \
           --tags_offset "0x00000100" \
           --pagesize 4096 \
           --header_version 0 \
           --hashtype sha1 \
           -o ${BOOT_IMAGE}
