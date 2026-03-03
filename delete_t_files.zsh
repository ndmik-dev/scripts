#!/usr/bin/env zsh

set -euo pipefail

usage() {
  print -u2 "Usage: $0 [--dry-run] [directory]"
}

dry_run=false

case "${1:-}" in
  --dry-run)
    dry_run=true
    shift
    ;;
  --help|-h)
    usage
    exit 0
    ;;
esac

if [[ $# -gt 1 ]]; then
  usage
  exit 1
fi

target_dir="${1:-.}"
target_dir="${target_dir:A}"

if [[ ! -d "$target_dir" ]]; then
  print -u2 "Directory not found: $target_dir"
  exit 1
fi

if $dry_run; then
  find "$target_dir" -type f -name 't*' -print
else
  find "$target_dir" -type f -name 't*' -print -delete
fi
