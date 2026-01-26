#!/system/bin/sh
# Hymo services.sh
# Mount stage: late (after boot completed)

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

if [ "$MOUNT_STAGE" = "services" ]; then
    log "services: executing mount (stage=$MOUNT_STAGE)"
    if [ -f "$MODDIR/hymo_mount_common.sh" ]; then
        . "$MODDIR/hymo_mount_common.sh"
        run_hymod_mount "$MODDIR" "services"
        exit $?
    fi
    log "services: missing hymo_mount_common.sh"
    exit 1
fi

log "services: skip (stage=$MOUNT_STAGE)"
exit 0
