#!/bin/sh
echo "Solving module-03: Creating pre-expansion documentation" >> /tmp/progress.log

# Create the pre-expansion state documentation
echo "=== Pre-Expansion State ===" > /tmp/expansion-log.txt
echo "" >> /tmp/expansion-log.txt
echo "Date: $(date)" >> /tmp/expansion-log.txt
echo "" >> /tmp/expansion-log.txt
echo "Filesystem Status:" >> /tmp/expansion-log.txt
df -h /app >> /tmp/expansion-log.txt
echo "" >> /tmp/expansion-log.txt
echo "Volume Group Status:" >> /tmp/expansion-log.txt
vgdisplay app_vg >> /tmp/expansion-log.txt
echo "" >> /tmp/expansion-log.txt
echo "Logical Volume Status:" >> /tmp/expansion-log.txt
lvdisplay /dev/app_vg/app_lv >> /tmp/expansion-log.txt

echo "Pre-expansion documentation created at /tmp/expansion-log.txt" >> /tmp/progress.log

# Verify the filesystem type
FS_TYPE=$(df -T /app | tail -1 | awk '{print $2}')
echo "Filesystem type: $FS_TYPE" >> /tmp/progress.log

# Verify LV status
LV_STATUS=$(lvdisplay /dev/app_vg/app_lv | grep "LV Status" | awk '{print $3}')
echo "LV Status: $LV_STATUS" >> /tmp/progress.log

echo "Module-03 solve complete - analysis and planning done" >> /tmp/progress.log
