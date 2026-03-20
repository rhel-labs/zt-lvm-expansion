#!/bin/bash
USER=rhel

echo "Adding wheel" > /root/post-run.log
usermod -aG wheel rhel

echo "Setup vm rhel - LVM expansion lab" > /tmp/progress.log

chmod 666 /tmp/progress.log

echo "Waiting for secondary disk /dev/vdb to be available" >> /tmp/progress.log

# Wait for /dev/vdb to appear (may take a moment after VM boot)
for i in {1..30}; do
    if [ -b /dev/vdb ]; then
        echo "Secondary disk /dev/vdb is now available" >> /tmp/progress.log
        break
    fi
    sleep 2
done

if [ ! -b /dev/vdb ]; then
    echo "ERROR: /dev/vdb did not appear after 60 seconds" >> /tmp/progress.log
    exit 1
fi

echo "Creating LVM structure on /dev/vdb" >> /tmp/progress.log

# Create physical volume on the entire 5GB disk
pvcreate /dev/vdb >> /tmp/progress.log 2>&1

# Create volume group named app_vg
vgcreate app_vg /dev/vdb >> /tmp/progress.log 2>&1

# Create logical volume of only 1GB (leaving ~4GB free for expansion exercises)
lvcreate -L 1G -n app_lv app_vg >> /tmp/progress.log 2>&1

# Format with XFS filesystem
mkfs.xfs /dev/app_vg/app_lv >> /tmp/progress.log 2>&1

# Create mount point
mkdir -p /app

# Mount the filesystem
mount /dev/app_vg/app_lv /app >> /tmp/progress.log 2>&1

# Add to fstab for persistence
echo "/dev/app_vg/app_lv /app xfs defaults 0 0" >> /etc/fstab

# Set ownership
chown rhel:rhel /app

echo "Creating application data in /app" >> /tmp/progress.log

# Create some application structure to make it look realistic
mkdir -p /app/data
mkdir -p /app/logs
mkdir -p /app/config

# Create a config file
cat > /app/config/app.conf << 'EOF'
# Super-Business Application Configuration
app_name=SuperBusinessApp
data_dir=/app/data
log_dir=/app/logs
max_log_size=100M
EOF

# Create some initial log files
echo "$(date) - Application started successfully" > /app/logs/app.log
echo "$(date) - Database connection established" >> /app/logs/app.log

# Now fill up the filesystem to cause the problem
# We'll create a large file that takes up most of the 1GB
# Leave just a tiny bit free so it's clearly full but not completely locked
echo "Filling /app filesystem to simulate the problem" >> /tmp/progress.log

# Create a 900MB file to fill most of the space
dd if=/dev/zero of=/app/data/large_dataset.dat bs=1M count=900 >> /tmp/progress.log 2>&1

# Create some additional smaller files to make it more realistic
for i in {1..10}; do
    dd if=/dev/zero of=/app/data/backup_file_$i.bak bs=1M count=5 >> /tmp/progress.log 2>&1
done

echo "Filesystem /app is now critically full" >> /tmp/progress.log

# Show the disk usage for verification
df -h /app >> /tmp/progress.log

echo "Lab setup complete - /app filesystem is full and ready for troubleshooting" >> /tmp/progress.log
