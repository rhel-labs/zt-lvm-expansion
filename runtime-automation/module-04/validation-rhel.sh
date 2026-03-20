#!/bin/sh
echo "Validating module-04: Checking LVM expansion" >> /tmp/progress.log

# Check if logical volume is approximately 5GB (allowing for some variance)
LV_SIZE=$(lvs --noheadings --units g -o lv_size /dev/app_vg/app_lv | tr -d ' ' | sed 's/g//')

# Convert to integer for comparison (remove decimal)
LV_SIZE_INT=$(echo "$LV_SIZE" | cut -d. -f1)

if [ "$LV_SIZE_INT" -lt 4 ]; then
    echo "FAIL: Logical volume has not been extended"
    echo "HINT: Use 'lvextend -l +100%FREE /dev/app_vg/app_lv' to extend the logical volume"
    exit 1
fi

# Check if filesystem is approximately 5GB
FS_SIZE=$(df -BG /app | tail -1 | awk '{print $2}' | sed 's/G//')

if [ "$FS_SIZE" -lt 4 ]; then
    echo "FAIL: Filesystem has not been grown to use the extended logical volume"
    echo "HINT: After extending the LV, you need to grow the filesystem with 'xfs_growfs /app'"
    exit 1
fi

# Check that filesystem has reasonable free space (should have more than 3GB free)
FS_AVAIL=$(df -BG /app | tail -1 | awk '{print $4}' | sed 's/G//')

if [ "$FS_AVAIL" -lt 3 ]; then
    echo "FAIL: Filesystem doesn't have expected free space after expansion"
    echo "HINT: Check that both lvextend and xfs_growfs completed successfully"
    exit 1
fi

echo "PASS: LVM expansion completed successfully"
echo "Logical volume is ${LV_SIZE}GB and filesystem has ${FS_AVAIL}GB free space"
exit 0
