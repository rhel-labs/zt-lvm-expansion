#!/bin/sh
echo "Solving module-01: Introduction complete" >> /tmp/progress.log

# Verify Nate's notes are available
if [ -f /home/nate/lvm-notes.txt ]; then
    echo "Nate's LVM notes are available for reference" >> /tmp/progress.log
else
    echo "WARNING: Nate's notes file not found" >> /tmp/progress.log
fi

echo "Module-01 solve complete - ready to begin diagnosis" >> /tmp/progress.log
