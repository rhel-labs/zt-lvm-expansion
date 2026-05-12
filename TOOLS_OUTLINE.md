# Troubleshooting Tools - zt-lvm-expansion Lab

## Lab Overview
This lab teaches how to diagnose and resolve filesystem capacity issues by expanding LVM logical volumes and growing filesystems.

## Key Concept
Understanding LVM architecture and the two-step process for expanding storage: extend the logical volume, then grow the filesystem.

---

## Tools Used & Their Application

### 1. **df** - Disk Filesystem Usage
**Purpose:** Identify filesystem capacity problems and verify expansion results

**Usage in Lab:**
- Module 02: Confirm filesystem is nearly full
  ```bash
  df -h /app
  ```
- Module 03: Check filesystem type
  ```bash
  df -T /app
  ```
- Module 04: Verify expansion succeeded
  ```bash
  df -h /app
  ```

**Slide Points:**
- Shows mounted filesystem usage and capacity
- `-h` = human-readable sizes (GB, MB)
- `-T` = show filesystem Type (XFS, ext4, etc.)
- Critical for before/after comparison
- Different from `du` - shows filesystem size, not directory usage

---

### 2. **du** - Disk Usage
**Purpose:** Understand what's consuming space within the filesystem

**Usage in Lab:**
- Module 02: See actual usage by directory
  ```bash
  du -sh /app/*
  ```

**Slide Points:**
- Shows actual disk usage of directories/files
- `-s` = summary (don't recurse into subdirectories)
- `-h` = human-readable sizes
- Helps understand if problem is data growth vs. filesystem size
- Complements `df` - df shows capacity, du shows actual usage

---

### 3. **pvdisplay** - Physical Volume Display
**Purpose:** Examine physical volumes (the foundation of LVM)

**Usage in Lab:**
- Module 02: Verify entire disk is initialized as PV
  ```bash
  sudo pvdisplay
  ```

**Slide Points:**
- Shows physical disks configured for LVM
- First layer in LVM architecture
- Displays:
  - PV Name (/dev/vdb)
  - VG Name (which volume group it belongs to)
  - PV Size (total physical size)
  - Allocatable (yes/no)
  - PE Size (Physical Extent size - the allocation unit)
  - Total/Free PE (physical extents)

---

### 4. **vgdisplay** - Volume Group Display
**Purpose:** Examine volume groups and available free space

**Usage in Lab:**
- Module 02: Check VG size and free space
  ```bash
  sudo vgdisplay app_vg
  ```

**Slide Points:**
- Shows volume group information (pool of storage)
- **KEY FIELDS:**
  - VG Size - total capacity from all PVs
  - Alloc PE / Size - how much is allocated to LVs
  - **Free PE / Size** - available space (THE CRITICAL NUMBER)
- This is where we find the unused 4GB
- Shows whether expansion is possible without adding disks

---

### 5. **vgs** - Volume Group Summary
**Purpose:** Quick summary view of volume groups

**Usage in Lab:**
- Module 03: Quick check of available free space
  ```bash
  sudo vgs app_vg
  ```

**Slide Points:**
- Condensed, table format
- **VFree column** shows available space at a glance
- Faster than vgdisplay for quick checks
- Good for scripting and quick verification

---

### 6. **lvdisplay** - Logical Volume Display
**Purpose:** Examine logical volumes and their current size

**Usage in Lab:**
- Module 02: Check current LV size
  ```bash
  sudo lvdisplay /dev/app_vg/app_lv
  ```
- Module 03: Verify LV status (available/healthy)
  ```bash
  sudo lvdisplay /dev/app_vg/app_lv | grep "LV Status"
  ```

**Slide Points:**
- Shows logical volume details
- **KEY FIELDS:**
  - LV Path - device path
  - LV Name - logical volume name
  - VG Name - parent volume group
  - **LV Size** - current size (shows it's only 1GB)
  - LV Status - health check (should be "available")
- This is the "room" we're expanding

---

### 7. **lvs** - Logical Volume Summary
**Purpose:** Quick summary view of logical volumes

**Usage in Lab:**
- Module 03: Quick check of current LV size
  ```bash
  sudo lvs app_vg/app_lv
  ```

**Slide Points:**
- Condensed, table format  
- **LSize column** shows current size
- Faster than lvdisplay for quick checks
- Complements vgs for rapid assessment

---

### 8. **lvextend** - Extend Logical Volume
**Purpose:** Grow the logical volume to use available VG space (STEP 1 of expansion)

**Usage in Lab:**
- Module 04: Extend LV to use all free space
  ```bash
  sudo lvextend -l +100%FREE /dev/app_vg/app_lv
  ```

**Slide Points:**
- **THE KEY COMMAND** for LVM expansion
- `-l +100%FREE` = use all available free space in VG
- Alternative: `-L +4G` to add specific size
- Alternative: `-l 100%VG` to use entire VG
- Only extends the LV, NOT the filesystem (common mistake!)
- Must be followed by filesystem resize command

---

### 9. **xfs_growfs** - Grow XFS Filesystem
**Purpose:** Expand the XFS filesystem to use newly available space (STEP 2 of expansion)

**Usage in Lab:**
- Module 04: Grow filesystem after extending LV
  ```bash
  sudo xfs_growfs /app
  ```

**Slide Points:**
- **THE KEY COMMAND** for XFS filesystem expansion
- Takes mount point as argument (not device!)
- Can be done **online** (while filesystem is mounted and in use!)
- XFS-specific - ext4 uses `resize2fs`
- Automatically detects new size from underlying LV
- **XFS can only grow, never shrink** (design choice)

---

### 10. **mount** - Show Mounted Filesystems
**Purpose:** Verify filesystem is mounted and can be grown online

**Usage in Lab:**
- Module 03: Confirm /app is mounted
  ```bash
  mount | grep /app
  ```

**Slide Points:**
- Shows all mounted filesystems and their options
- Confirms mount point exists and is active
- For XFS, verifies we can do online resize
- Shows mount options (rw, relatime, etc.)

---

### 11. **cat** - Display File Contents
**Purpose:** Document current state before making changes

**Usage in Lab:**
- Module 03: Record current state
  ```bash
  cat /app/README.txt
  ```

**Slide Points:**
- Used for documentation/verification
- Shows we can read data before changes
- Part of safety protocol: test access before maintenance
- Simple but important verification step

---

## LVM Architecture Diagram

```
Physical Layer:
  /dev/vdb (5GB disk)
      ↓
  Physical Volume (PV)
      ↓
  Volume Group (VG) - app_vg [5GB total, 4GB free]
      ↓
  Logical Volume (LV) - app_lv [1GB currently allocated]
      ↓
  Filesystem (XFS) - mounted on /app [1GB capacity, 96% used]
```

**The Problem:** Everything is configured correctly, but the LV only uses 1GB of the 5GB available

**The Solution:** 
1. lvextend → grow LV from 1GB to 5GB
2. xfs_growfs → grow filesystem from 1GB to 5GB

---

## Troubleshooting Flow

### Discovery Phase
1. **df -h** → Confirm filesystem is full
2. **du -sh** → Understand what's using the space (data vs. waste)

### Investigation Phase - LVM Layers
3. **pvdisplay** → Check physical volumes (5GB available)
4. **vgdisplay** → Check volume group (5GB total, **4GB FREE** - key finding!)
5. **lvdisplay** → Check logical volume (only 1GB - the problem!)
6. **df -T** → Check filesystem type (XFS)

### Planning Phase
7. **vgs / lvs** → Quick summary of current state
8. **mount** → Verify filesystem is mounted (can we do online resize?)
9. **lvdisplay | grep Status** → Health check before changes

### Execution Phase
10. **lvextend** → Extend logical volume to 5GB
11. **xfs_growfs** → Grow filesystem to use new space

### Verification Phase
12. **df -h** → Confirm expansion successful (should show ~5GB total)
13. **lvs / vgs** → Verify LV now uses all VG space
14. **cat** → Verify data still accessible

---

## Key Teaching Points

### LVM Concepts
- **Three Layers:** Physical Volume → Volume Group → Logical Volume
- **Flexibility:** Can resize without reformatting
- **Headroom:** Always size with growth in mind
- **Physical Extents:** LVM's allocation unit (like blocks)

### Two-Step Expansion Process
1. **lvextend:** Grows the logical volume (container)
2. **xfs_growfs/resize2fs:** Grows the filesystem (contents)
- **Common mistake:** Extending LV but forgetting filesystem resize
- Result: df still shows old size even though LV is bigger

### XFS Specifics
- Can be grown online (no downtime)
- Cannot be shrunk (design trade-off)
- Takes mount point as argument
- Automatically detects new size

### Best Practices
- Always document current state first
- Verify health before making changes
- Use percentage-based sizing when possible (+100%FREE)
- Test data access before and after
- Consider future growth when initially sizing

---

## Slide Deck Suggestions

### Slide 1: The Problem
- Screenshot of `df -h /app` showing 96% usage
- "Application team needs more space!"

### Slide 2: LVM Architecture
- Visual diagram of the three layers
- Highlight that disk is 5GB but only 1GB is usable

### Slide 3: Discovery with df vs du
- `df` shows filesystem is 96% full
- `du` shows data is ~950MB (legitimate usage)
- Problem: Filesystem too small, not wasted space

### Slide 4: LVM Investigation Workflow
```
pvdisplay  → Physical disk fully available (5GB)
vgdisplay  → Volume Group has 4GB FREE!
lvdisplay  → Logical Volume only 1GB (the problem)
df         → Filesystem constrained by small LV
```

### Slide 5: The Solution - Two Steps
```
Step 1: lvextend -l +100%FREE /dev/app_vg/app_lv
        → Grows LV from 1GB to 5GB

Step 2: xfs_growfs /app
        → Grows filesystem from 1GB to 5GB
```

### Slide 6: Command Comparison
| Command | Purpose | Layer |
|---------|---------|-------|
| pvdisplay | View physical volumes | Physical |
| vgdisplay/vgs | View volume groups | Pool |
| lvdisplay/lvs | View logical volumes | Logical |
| df | View filesystem usage | Filesystem |
| lvextend | Grow logical volume | Action (LV) |
| xfs_growfs | Grow XFS filesystem | Action (FS) |

### Slide 7: XFS vs ext4 Differences
| Feature | XFS | ext4 |
|---------|-----|------|
| Online grow | Yes | Yes |
| Can shrink | No | Yes |
| Resize command | xfs_growfs | resize2fs |
| Argument | mount point | device path |

### Slide 8: Verification Checklist
- ✓ df shows new size
- ✓ lvs shows LV expanded
- ✓ vgs shows Free space reduced
- ✓ Data still accessible
- ✓ No errors in dmesg/logs

### Slide 9: Common Mistakes
1. Running only lvextend (forgot xfs_growfs)
   - LV bigger but filesystem still small
2. Using wrong command for filesystem type
   - xfs_growfs for XFS, resize2fs for ext4
3. Trying to shrink XFS
   - Not supported, use ext4 if shrinking needed
4. No pre-change documentation
   - Can't prove what changed

### Slide 10: When to Use This Approach
**Good for:**
- Growing existing filesystems
- Online expansion (no downtime)
- Filesystems with free space in VG

**Not for:**
- Adding new disks (need vgextend first)
- Shrinking filesystems (use ext4, requires unmount)
- Non-LVM partitions (need different tools)

---

## Demo Script Notes

1. Show df - filesystem 96% full
2. Check du - data usage is legitimate, not waste
3. pvdisplay - full disk available
4. vgdisplay - AHA! 4GB free in VG
5. lvdisplay - LV only 1GB (root cause)
6. Show df vs lvs comparison (1GB both places - constrained)
7. Execute lvextend -l +100%FREE
8. Show df - STILL 1GB! (common confusion)
9. Execute xfs_growfs /app
10. Show df - NOW it's 5GB! (success)
11. Explain why both commands needed
12. Show data is still accessible
