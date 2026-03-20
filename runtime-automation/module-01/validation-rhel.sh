#!/bin/sh
echo "Validating module-01: Introduction" >> /tmp/progress.log

# Check that Nate's notes file exists
if [ ! -f /home/nate/lvm-notes.txt ]; then
    echo "FAIL: Nate's LVM notes file is missing"
    echo "HINT: The setup script should create /home/nate/lvm-notes.txt"
    exit 1
fi

# Check that /app filesystem exists and is mounted
if ! mount | grep -q "/app"; then
    echo "FAIL: /app filesystem is not mounted"
    echo "HINT: The setup should have created and mounted /app"
    exit 1
fi

# Check that /app is on an LVM volume
if ! mount | grep "/app" | grep -q "app_vg-app_lv"; then
    echo "FAIL: /app is not mounted from the expected LVM volume"
    echo "HINT: Should be mounted from /dev/mapper/app_vg-app_lv"
    exit 1
fi

echo "PASS: Introduction module validation complete"
echo "The lab environment is properly configured and ready"
exit 0
