#!/bin/bash

REMOTE_USER="username"
REMOTE_HOST="x.x.x.x"
REMOTE_PORT="22"
REPO_PATH="/~/backups"
BORG_REPO="${REMOTE_USER}@${REMOTE_HOST}:${REPO_PATH}"

BACKUP_NAME="$(hostname)-$(date +%Y-%m-%d_%H-%M-%S)"
SOURCE_DIR="${HOME}"

export BORG_PASSPHRASE="" 

LOG_FILE="${HOME}/.borg-backup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

# Start backup
log "Starting backup: ${BACKUP_NAME}"

# Create backup with exclusions
borg create \
    --verbose \
    --stats \
    --progress \
    --compression lz4 \
    --exclude-caches \
    --exclude "${HOME}/.cache" \
    --exclude "${HOME}/.local/share/Trash" \
    --exclude "${HOME}/.thumbnails" \
    --exclude "${HOME}/.mozilla/firefox/*/Cache" \
    --exclude "${HOME}/.config/google-chrome/*/Cache" \
    --exclude "${HOME}/.config/Code/Cache" \
    --exclude "${HOME}/.config/google-chrome" \
    --exclude "${HOME}/.config/Mattermost" \
    --exclude "${HOME}/.mozilla/firefox" \
    --exclude "${HOME}/.npm" \
    --exclude "${HOME}/.cargo/registry" \
    --exclude "${HOME}/.gradle" \
    --exclude "${HOME}/tokens" \
    --exclude "${HOME}/.docker" \
    --exclude "${HOME}/.vagrant.d" \
    --exclude "${HOME}/Downloads" \
    --exclude "${HOME}/.local/share/**/*" \
    --exclude "${HOME}/.vscode" \
    --exclude "${HOME}/.config/Code" \
    --exclude "${HOME}/Téléchargements" \
    --exclude "*.tmp" \
    --exclude "*.temp" \
    --exclude "*~" \
    --exclude "*.log" \
    "${BORG_REPO}::${BACKUP_NAME}" \
    "${SOURCE_DIR}" 2>&1 | tee -a "${LOG_FILE}"

# Check exit status
if [ $? -eq 0 ]; then
    log "Backup completed successfully"
else
    log "ERROR: Backup failed!"
    exit 1
fi

# Prune old backups (keep last 7 daily, 4 weekly, 6 monthly)
log "Pruning old backups..."
borg prune \
    --verbose \
    --list \
    --keep-daily=7 \
    --keep-weekly=4 \
    --keep-monthly=6 \
    "${BORG_REPO}" 2>&1 | tee -a "${LOG_FILE}"

if [ $? -eq 0 ]; then
    log "Pruning completed successfully"
else
    log "WARNING: Pruning failed!"
fi

# Compact the repository to free space
log "Compacting repository..."
borg compact "${BORG_REPO}" 2>&1 | tee -a "${LOG_FILE}"

log "Backup process finished"