#!/bin/sh
echo "Solving module-02: Running diagnostic commands" >> /tmp/progress.log

# Run the key diagnostic commands that students should run
echo "=== Filesystem Status ===" >> /tmp/progress.log
df -h /app >> /tmp/progress.log 2>&1

echo "=== Disk Usage ===" >> /tmp/progress.log
du -sh /app/* >> /tmp/progress.log 2>&1

echo "=== Physical Volume Status ===" >> /tmp/progress.log
pvdisplay >> /tmp/progress.log 2>&1

echo "=== Volume Group Status ===" >> /tmp/progress.log
vgdisplay app_vg >> /tmp/progress.log 2>&1

echo "=== Logical Volume Status ===" >> /tmp/progress.log
lvdisplay /dev/app_vg/app_lv >> /tmp/progress.log 2>&1

echo "=== Nate's Notes ===" >> /tmp/progress.log
cat /home/nate/lvm-notes.txt >> /tmp/progress.log 2>&1

echo "Module-02 solve complete - diagnosis performed" >> /tmp/progress.log
