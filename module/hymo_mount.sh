#!/system/bin/sh
# Hymo Mount Core Script
# This script contains the actual mount logic
# Called by post-fs-data.sh, metamount.sh, or services.sh based on mount_stage config

MODDIR="${0%/*}"
cd "$MODDIR"

# Use argument or default to metamount
MOUNT_STAGE="${1:-metamount}"

if [ -f "$MODDIR/hymo_mount_common.sh" ]; then
    . "$MODDIR/hymo_mount_common.sh"
    run_hymod_mount "$MODDIR" "$MOUNT_STAGE"
    exit $?
fi

echo "[Wrapper] Missing hymo_mount_common.sh" >> /data/adb/hymo/daemon.log
exit 1
