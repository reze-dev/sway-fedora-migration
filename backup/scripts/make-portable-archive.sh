#!/usr/bin/env bash
# Pack the whole repository into a single portable tar.zst file, so the backup
# can be copied to another machine or an external disk in one step.
#
#   ./make-portable-archive.sh [target-directory]
#
# The archive is written next to the repository by default, never inside it,
# and its SHA-256 is recorded in backup/archive-checksums.txt.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TARGET_DIR="${1:-$(dirname "$REPO_ROOT")}"
STAMP="$(date +%Y-%m-%d)"
ARCHIVE="$TARGET_DIR/backup-full-$STAMP.tar.zst"

cd "$REPO_ROOT"

echo "packing $REPO_ROOT -> $ARCHIVE"
tar --zstd -cf "$ARCHIVE" --exclude='./.git' --exclude='*.sock' .

echo "checksum:"
( cd "$TARGET_DIR" && sha256sum "$(basename "$ARCHIVE")" ) | tee "$REPO_ROOT/backup/archive-checksums.txt"

ls -lh "$ARCHIVE"
echo
echo "extract with:"
echo "  tar --zstd -xf $ARCHIVE -C /target/directory"
