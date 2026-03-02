#!/bin/zsh

# Usage:
# ./delete_before_date.sh /path/to/dir "2026-02-01"

TARGET_DIR="$1"
DATE_STRING="$2"

if [[ -z "$TARGET_DIR" || -z "$DATE_STRING" ]]; then
  echo "Usage: $0 /path/to/dir \"YYYY-MM-DD\""
  exit 1
fi

# Convert date to reference file
REF_FILE=$(mktemp)
touch -t "$(date -j -f "%Y-%m-%d" "$DATE_STRING" +"%Y%m%d0000" 2>/dev/null || date -d "$DATE_STRING" +"%Y%m%d0000")" "$REF_FILE"

echo "Deleting files in $TARGET_DIR modified BEFORE $DATE_STRING"
echo "-----------------------------------------------"

# Preview (comment out if not needed)
find "$TARGET_DIR" -type f ! -newer "$REF_FILE"

echo "-----------------------------------------------"
read "confirm?Proceed with deletion? (y/N): "

if [[ "$confirm" == "y" ]]; then
  find "$TARGET_DIR" -type f ! -newer "$REF_FILE" -delete
  echo "Done."
else
  echo "Aborted."
fi

rm "$REF_FILE"
