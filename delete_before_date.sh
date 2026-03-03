#!/usr/bin/env zsh

set -euo pipefail

usage() {
  print -u2 "Usage: $0 /path/to/dir YYYY-MM-DD"
}

reference_timestamp() {
  local date_string="$1"
  local ts=""

  ts="$(date -j -v-1S -f '%Y-%m-%d %H:%M:%S' "$date_string 00:00:00" '+%Y%m%d%H%M.%S' 2>/dev/null)" || true
  if [[ -z "$ts" ]]; then
    ts="$(date -d "$date_string 00:00:00 - 1 second" '+%Y%m%d%H%M.%S' 2>/dev/null)" || true
  fi

  if [[ -z "$ts" ]]; then
    return 1
  fi

  print -- "$ts"
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

target_dir="${1:A}"
date_string="$2"

if [[ ! -d "$target_dir" ]]; then
  print -u2 "Directory not found: $target_dir"
  exit 1
fi

touch_ts="$(reference_timestamp "$date_string")" || {
  print -u2 "Invalid date: $date_string"
  exit 1
}

ref_file="$(mktemp)"
trap 'rm -f "$ref_file"' EXIT
touch -t "$touch_ts" "$ref_file"

print -- "Deleting files in $target_dir modified before $date_string"
print -- "-----------------------------------------------"
find "$target_dir" -type f ! -newer "$ref_file" -print
print -- "-----------------------------------------------"

read "confirm?Proceed with deletion? (y/N): "

if [[ "${confirm:l}" == "y" ]]; then
  find "$target_dir" -type f ! -newer "$ref_file" -delete
  print -- "Done."
else
  print -- "Aborted."
fi
