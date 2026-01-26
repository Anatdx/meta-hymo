#!/system/bin/sh
# Hymo post-fs-data.sh
# Mount stage: earliest (before most services start)

MODDIR="${0%/*}"
BASE_DIR="/data/adb/hymo"
LOG_FILE="$BASE_DIR/daemon.log"
CONFIG_FILE="$BASE_DIR/config.json"

log() {
    local ts
    ts="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$ts] [Wrapper] $1" >> "$LOG_FILE"
}

# Get mount_stage from config
get_mount_stage() {
    if [ -f "$CONFIG_FILE" ]; then
        # Simple JSON parsing for mount_stage
        STAGE=$(grep -o '"mount_stage"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | sed 's/.*"\([^"]*\)"$/\1/')
        echo "${STAGE:-metamount}"
    else
        echo "metamount"
    fi
}

MOUNT_STAGE=$(get_mount_stage)

if [ "$MOUNT_STAGE" = "post-fs-data" ]; then
    log "post-fs-data: executing mount (stage=$MOUNT_STAGE)"
    if [ -f "$MODDIR/hymo_mount_common.sh" ]; then
        . "$MODDIR/hymo_mount_common.sh"
        run_hymod_mount "$MODDIR" "post-fs-data"
        exit $?
    fi
    log "post-fs-data: missing hymo_mount_common.sh"
    exit 1
fi

log "post-fs-data: skip (stage=$MOUNT_STAGE)"
exit 0
