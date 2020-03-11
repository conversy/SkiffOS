#!/bin/bash

echo "Copying pre-compiled u-boot binary..."
cp $SKIFF_CURRENT_CONF_DIR/resources/sd_fuse/u-boot.bin ./output/images/u-boot.bin

echo "Copying sd_fuse blobs..."
rsync -rav $SKIFF_CURRENT_CONF_DIR/resources/sd_fuse/ ./output/images/hk_sd_fuse/