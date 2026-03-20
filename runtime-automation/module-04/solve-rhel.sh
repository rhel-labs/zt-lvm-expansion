#!/bin/sh
echo "Solving module-04: Performing LVM expansion" >> /tmp/progress.log

# Extend the logical volume to use all free space
lvextend -l +100%FREE /dev/app_vg/app_lv >> /tmp/progress.log 2>&1

# Grow the XFS filesystem
xfs_growfs /app >> /tmp/progress.log 2>&1

echo "LVM expansion complete" >> /tmp/progress.log

# Show the result
df -h /app >> /tmp/progress.log
