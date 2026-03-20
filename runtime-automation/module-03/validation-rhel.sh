#!/bin/sh
echo "Validating module-03: Analysis" >> /tmp/progress.log

# Check that pre-expansion log exists
if [ ! -f /tmp/expansion-log.txt ]; then
    echo "FAIL: Pre-expansion documentation not found at /tmp/expansion-log.txt"
    echo "HINT: Create the pre-expansion state documentation before proceeding"
    exit 1
fi

# Check that the log contains expected content
if ! grep -q "Pre-Expansion State" /tmp/expansion-log.txt; then
    echo "FAIL: Pre-expansion log doesn't contain expected header"
    echo "HINT: Log should document the pre-expansion state"
    exit 1
fi

if ! grep -q "app_vg" /tmp/expansion-log.txt; then
    echo "FAIL: Pre-expansion log doesn't contain volume group information"
    echo "HINT: Log should include vgdisplay output for app_vg"
    exit 1
fi

# Verify system is still in pre-expansion state (LV should still be ~1GB)
LV_SIZE=$(lvs --noheadings --units g -o lv_size /dev/app_vg/app_lv | tr -d ' ' | sed 's/g//')
LV_SIZE_INT=$(echo "$LV_SIZE" | cut -d. -f1)

if [ "$LV_SIZE_INT" -gt 2 ]; then
    echo "FAIL: Logical volume appears to have been expanded already (${LV_SIZE}GB)"
    echo "HINT: Analysis module should be completed before expansion"
    exit 1
fi

# Verify filesystem type is XFS
FS_TYPE=$(df -T /app | tail -1 | awk '{print $2}')
if [ "$FS_TYPE" != "xfs" ]; then
    echo "FAIL: Filesystem is not XFS (found: $FS_TYPE)"
    echo "HINT: This lab expects an XFS filesystem"
    exit 1
fi

# Verify /app is mounted
if ! mount | grep -q "/app"; then
    echo "FAIL: /app filesystem is not mounted"
    echo "HINT: Filesystem should remain mounted throughout the lab"
    exit 1
fi

echo "PASS: Analysis validation complete"
echo "Pre-expansion documentation exists and system is ready for expansion"
exit 0
