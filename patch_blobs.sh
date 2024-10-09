#!/bin/bash
#
# Copyright (C) 2023-2024 The risingOS Android Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Script for patching existing blob/s unlike extract-files.sh that patches the blobs 
# during vendor blobs extraction through blob_fixup()
# USAGE: on Android root dir: bash device/xiaomi/nabu/patch_blobs.sh
set -e

device="nabu"
brand="xiaomi"
base_path="$(pwd)/vendor/$brand/$device/proprietary/vendor"
libs_out_path="$(pwd)/out/target/product/$device/vendor"

blobs_map=(
    "lib64/libcrypto.so,lib64/libcrypto-v33.so,lib64/libwvhidl.so"
)

echo "Starting symlink creation for device: $device, brand: $brand"
for blobs in "${blobs_map[@]}"; do
    echo "Processing symlink setup: $blobs"
    IFS=',' read -r symlink_lib symlink_source_lib relative_blob_path <<< "$blobs"
    target_file="$base_path/$relative_blob_path"
    symlink_lib_file="$libs_out_path/$symlink_lib"
    symlink_source_lib_file="$libs_out_path/$symlink_source_lib"
    if [[ -e "$symlink_lib_file" && -e "$symlink_source_lib_file" && -e "$target_file" ]]; then
        patchelf --replace-needed "$symlink_lib_file" "$symlink_source_lib_file" "$target_file"
        echo "Symlink created successfully for $target_file"
    else
        echo "Error: One or more files do not exist:"
        [[ ! -e "$symlink_lib_file" ]] && echo "Missing: $symlink_lib_file"
        [[ ! -e "$symlink_source_lib_file" ]] && echo "Missing: $symlink_source_lib_file"
        [[ ! -e "$target_file" ]] && echo "Missing: $target_file"
    fi
done
echo "Blob patching completed!"

