#!/usr/bin/env zsh

set -euo pipefail

usage() {
  print -u2 "Usage: $0 [directory]"
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 1 ]]; then
  usage
  exit 1
fi

target_dir="${1:-.}"
script_path="${0:A}"

if [[ ! -d "$target_dir" ]]; then
  print -u2 "Directory not found: $target_dir"
  exit 1
fi

target_dir="${target_dir:A}"

typeset -a photo_exts video_exts
photo_exts=(
  jpg jpeg png gif webp heic heif tif tiff bmp
  dng raw arw cr2 cr3 nef raf orf rw2 avif
)
video_exts=(
  mp4 mov m4v avi mkv webm mpg mpeg mts m2ts
  3gp wmv flv ts vob insv
)

is_in_list() {
  local needle="$1"
  shift
  local item

  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done

  return 1
}

destination_for() {
  local file="$1"
  local ext="${file:e:l}"
  local date_bits year month_name day

  if [[ "$file" == "$script_path" ]]; then
    return 1
  fi

  if is_in_list "$ext" "${photo_exts[@]}"; then
    date_bits="$(stat -f '%Sm' -t '%Y|%B|%d' "$file")"
    IFS='|' read -r year month_name day <<< "$date_bits"
    print -- "$target_dir/$year/$month_name/$day/Photo"
    return 0
  fi

  if is_in_list "$ext" "${video_exts[@]}"; then
    date_bits="$(stat -f '%Sm' -t '%Y|%B|%d' "$file")"
    IFS='|' read -r year month_name day <<< "$date_bits"
    print -- "$target_dir/$year/$month_name/$day/Video"
    return 0
  fi

  print -- "$target_dir/Other"
}

unique_path() {
  local dir="$1"
  local base_name="$2"
  local stem="${base_name%.*}"
  local ext=""
  local candidate="$dir/$base_name"
  local counter=1

  if [[ "$base_name" == *.* ]]; then
    ext=".${base_name##*.}"
  else
    stem="$base_name"
  fi

  while [[ -e "$candidate" ]]; do
    candidate="$dir/${stem}_$counter$ext"
    ((counter++))
  done

  print -- "$candidate"
}

find "$target_dir" \
  \( -path "$target_dir/Other" -o -path "$target_dir/Other/*" -o \
     -path "$target_dir/[0-9][0-9][0-9][0-9]" -o -path "$target_dir/[0-9][0-9][0-9][0-9]/*" \) -prune -o \
  -type f -print0 | while IFS= read -r -d '' file; do
  destination_dir="$(destination_for "$file")" || continue
  mkdir -p "$destination_dir"
  destination_path="$(unique_path "$destination_dir" "${file:t}")"

  if [[ "$file" != "$destination_path" ]]; then
    print -- "Moving: $file -> $destination_path"
    mv "$file" "$destination_path"
  fi
done
