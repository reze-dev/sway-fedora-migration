#!/usr/bin/env bash
# Verify the backup: every plain file and every archive must match the
# checksum that was recorded when the backup was captured.
#
#   ./verify-backup.sh
#
# Exit code 0 means the backup is intact.

set -uo pipefail

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BACKUP_DIR" || exit 1

fail=0

echo "== plain files =="
if [[ -f checksums.sha256 ]]; then
    plain="$(grep -v '^\S*  \./archives/' checksums.sha256 | wc -l)"
    if grep -v '^\S*  \./archives/' checksums.sha256 | sha256sum -c --quiet 2>&1; then
        echo "OK: $plain files match"
    else
        echo "FAILED: some files do not match"
        fail=1
    fi
else
    echo "FAILED: checksums.sha256 is missing"
    fail=1
fi

echo "== archives =="
if [[ -d archives ]]; then
    for f in archives/*.tar.zst; do
        [[ -e "$f" ]] || continue
        expected="$(grep -F "archives/$(basename "$f")" checksums.sha256 2>/dev/null | awk '{print $1}')"
        actual="$(sha256sum "$f" | awk '{print $1}')"
        if [[ -n "$expected" && "$expected" == "$actual" ]]; then
            printf 'OK   %s (%s)\n' "$f" "$(du -h "$f" | cut -f1)"
        else
            printf 'FAIL %s\n' "$f"
            fail=1
        fi
        # the archive must also be readable
        if ! tar --zstd -tf "$f" >/dev/null 2>&1; then
            printf 'FAIL %s is not a readable tar.zst archive\n' "$f"
            fail=1
        fi
    done
else
    echo "no archives directory"
fi

echo "== summary =="
printf 'files: %s\n' "$(find . -type f | wc -l)"
printf 'size:  %s\n' "$(du -sh . | cut -f1)"
if [[ -f capture-date.txt ]]; then
    printf 'captured: %s\n' "$(cat capture-date.txt)"
fi

if [[ $fail -eq 0 ]]; then
    echo "BACKUP OK"
else
    echo "BACKUP HAS PROBLEMS"
fi
exit $fail
