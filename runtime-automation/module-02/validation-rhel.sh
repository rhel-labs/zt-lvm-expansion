#!/bin/sh
echo "Validating module-02: Diagnosis" >> /tmp/progress.log

# Check that filesystem is nearly full (should be > 90% used)
FS_USE=$(df /app | tail -1 | awk '{print $5}' | sed 's/%//')

if [ "$FS_USE" -lt 90 ]; then
    echo "FAIL: Filesystem is not in the expected full state (${FS_USE}% used)"
    echo "HINT: The filesystem should be approximately 96% full for this lab"
    exit 1
fi

# Check that logical volume is approximately 1GB
LV_SIZE=$(lvs --noheadings --units g -o lv_size /dev/app_vg/app_lv | tr -d ' ' | sed 's/g//')
LV_SIZE_INT=$(echo "$LV_SIZE" | cut -d. -f1)

if [ "$LV_SIZE_INT" -gt 2 ]; then
    echo "FAIL: Logical volume is larger than expected (${LV_SIZE}GB)"
    echo "HINT: For diagnosis module, LV should still be ~1GB"
    exit 1
fi

# Check that volume group has free space (should have > 3GB free)
VG_FREE=$(vgs --noheadings --units g -o vg_free app_vg | tr -d ' ' | sed 's/g//')
VG_FREE_INT=$(echo "$VG_FREE" | cut -d. -f1)

if [ "$VG_FREE_INT" -lt 3 ]; then
    echo "FAIL: Volume group doesn't have expected free space (${VG_FREE}GB free)"
    echo "HINT: VG should have approximately 4GB of free space"
    exit 1
fi

echo "PASS: Diagnosis validation complete"
echo "Filesystem: ${FS_USE}% full, LV: ${LV_SIZE}GB, VG Free: ${VG_FREE}GB"
exit 0
