#!/system/bin/sh
# Hymo metamount.sh
# Mount stage: standard (end of post-fs-data, KSU's special timing)

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

case "$MOUNT_STAGE" in
    metamount)
        log "metamount: executing mount (stage=$MOUNT_STAGE)"
        if [ -f "$MODDIR/hymo_mount_common.sh" ]; then
            . "$MODDIR/hymo_mount_common.sh"
            run_hymod_mount "$MODDIR" "metamount"
            exit $?
        fi
        log "metamount: missing hymo_mount_common.sh"
        exit 1
        ;;
    post-fs-data)
        # Fallback: some environments only run metamount.sh for metamodules
        log "metamount: fallback to post-fs-data (stage=$MOUNT_STAGE)"
        if [ -f "$MODDIR/hymo_mount_common.sh" ]; then
            . "$MODDIR/hymo_mount_common.sh"
            run_hymod_mount "$MODDIR" "post-fs-data"
            exit $?
        fi
        log "metamount: missing hymo_mount_common.sh"
        exit 1
        ;;
    services)
        # Fallback: defer to boot completed if service.sh is not executed
        log "metamount: defer to boot completed (stage=$MOUNT_STAGE)"
        (
            while [ "$(getprop sys.boot_completed 2>/dev/null)" != "1" ]; do
                sleep 1
            done
            log "metamount: boot completed, executing mount (stage=$MOUNT_STAGE)"
            if [ -f "$MODDIR/hymo_mount_common.sh" ]; then
                . "$MODDIR/hymo_mount_common.sh"
                run_hymod_mount "$MODDIR" "services"
                exit $?
            fi
            log "metamount: missing hymo_mount_common.sh"
            exit 1
        ) &
        ;;
    *)
        # Unknown stage, default to metamount to avoid no-mount
        log "metamount: unknown stage, defaulting to metamount (stage=$MOUNT_STAGE)"
        if [ -f "$MODDIR/hymo_mount_common.sh" ]; then
            . "$MODDIR/hymo_mount_common.sh"
            run_hymod_mount "$MODDIR" "metamount"
            exit $?
        fi
        log "metamount: missing hymo_mount_common.sh"
        exit 1
        ;;
esac

exit 0