#!/bin/bash
shopt -s nocasematch 2>/dev/null
DRY_RUN=true  # Change to 'false' to actually move files

# --- Images ---
ARR_IMAGES=(".jpg" ".jpeg" ".png" ".gif" ".bmp" ".svg" ".webp" ".tiff" ".heic" ".raw")

# --- Documents ---
ARR_DOCS=(".pdf" ".doc" ".docx" ".xls" ".xlsx" ".ppt" ".pptx" ".odt" ".rtf" ".txt" ".csv" ".epub" ".mobi")

# --- Audio ---
ARR_AUDIO=(".mp3" ".wav" ".flac" ".aac" ".ogg" ".m4a" ".wma" ".aiff" ".opus")

# --- Video ---
ARR_VIDEO=(".mp4" ".mkv" ".mov" ".avi" ".wmv" ".flv" ".webm" ".m4v" ".mpeg" ".mpg")

# --- Plain Text & Code ---
ARR_TEXT=(".txt" ".md" ".rtf" ".log" ".conf" ".json" ".yaml" ".xml" ".csv" ".tsv")

# Helper function: matches_any <filename> <array_of_extensions>
matches_any() {
    local file="$1"
    shift
    local extensions=("$@")

    for ext in "${extensions[@]}"; do
        # Case-insensitive check (Bash 4+)
        if [[ "${file:lower}" == *"${ext:lower}" ]]; then
            return 0 # Match found
        fi
    done
    return 1 # No match
}

# Helper function: moves files, renaming them if they already exist
safe_move() {
    local src="$1"
    local dest_dir="$2"
    local filename=$(basename "$src")
    local name="${filename%.*}"
    local ext="${filename##*.}"

    # If filename has no extension, handle it
    if [[ "$name" == "$ext" ]]; then ext=""; else ext=".$ext"; fi

    local target="$dest_dir/$filename"
    local counter=1

    # Loop until a unique filename is found
    while [[ -e "$target" ]]; do
        target="$dest_dir/${name}_${counter}${ext}"
        ((counter++))
    done

    if [ "$DRY_RUN" = true ]; then
            echo "[DRY RUN] Would move: $src -> $target"
    else
            mkdir -p "$dest_dir"
            mv "$src" "$target"
            echo "MOVED: $src -> $target"
    fi
}

TMPFILE=$(mktemp) || exit 1
ls -p | grep -v / > $TMPFILE
while IFS= read -r filename; do
  target_dir=""
  if matches_any "$filename" "${ARR_IMAGES[@]}"; then
    target_dir="Images"
  elif matches_any "$filename" "${ARR_DOCS[@]}"; then
    target_dir="Documents"
  elif matches_any "$filename" "${ARR_AUDIO[@]}"; then
    target_dir="Audio"
  elif matches_any "$filename" "${ARR_VIDEO[@]}"; then
    target_dir="Video"
  elif matches_any "$filename" "${ARR_TEXT[@]}"; then
    target_dir="Text"
  else
    target_dir="Other"
  fi
  if [ -n "$target_dir" ]; then
      safe_move "$filename" "$target_dir"
  fi
done < "$TMPFILE"
rm -f "$TMPFILE"

