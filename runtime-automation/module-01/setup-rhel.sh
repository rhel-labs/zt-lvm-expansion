#!/bin/sh
echo "Starting module-01: Introduction" >> /tmp/progress.log

# Create Nate's notes file for students to reference
cat > /home/nate/lvm-notes.txt << 'EOF'
Nate's LVM Expansion Quick Reference
====================================

When you need to expand an LVM-based filesystem, follow these steps in order:

1. Check available space: vgdisplay to see if your VG has free space
2. Extend the logical volume: lvextend -l +100%FREE /dev/vg_name/lv_name
3. Grow the filesystem:
   - For XFS: xfs_growfs /mount_point
   - For ext4: resize2fs /dev/vg_name/lv_name

Remember: You can extend XFS filesystems while they're mounted!

Common mistakes to avoid:
- Don't forget to grow the filesystem after extending the LV
- Make sure you have free space in the VG before extending
- Use the correct filesystem resize command (xfs_growfs vs resize2fs)

-Nate
EOF

chown nate:nate /home/nate/lvm-notes.txt
chmod 644 /home/nate/lvm-notes.txt

echo "Module-01 setup complete - Nate's notes created" >> /tmp/progress.log
