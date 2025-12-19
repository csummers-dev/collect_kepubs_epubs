#Written by @csummers-dev 12.18.25

#!/bin/bash

# Colors
BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Set defaults
SEARCH_DIR="."
OUTPUT_DIR="$SCRIPT_DIR/collect_output"

FOUND=0
CREATED_LOCAL=0
COPIED_OUTPUT=0
SKIPPED_OUTPUT=0

# Parse the args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --create-folder)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    *)
      SEARCH_DIR="$1"
      shift
      ;;
  esac
done

# Set the output directory
mkdir -p "$OUTPUT_DIR"

# Main
find "$SEARCH_DIR" -type f -name "*.kepub" | while read -r kepub; do
  FOUND=$((FOUND + 1))

  dir="$(dirname "$kepub")"
  base="$(basename "$kepub")"
  kepub_epub="$dir/$base.epub"
  output_name="$(basename "$kepub_epub")"

  # Ensure .kepub.epub exists next to original
  if [[ ! -f "$kepub_epub" ]]; then
    cp "$kepub" "$kepub_epub"
    CREATED_LOCAL=$((CREATED_LOCAL + 1))
  fi

  # Copy to output folder if not already present (case-insensitive)
  if ls "$OUTPUT_DIR" | grep -iq "^${output_name}$"; then
    SKIPPED_OUTPUT=$((SKIPPED_OUTPUT + 1))
  else
    cp "$kepub_epub" "$OUTPUT_DIR/"
    COPIED_OUTPUT=$((COPIED_OUTPUT + 1))
  fi
done

# Print summary
echo
echo -e "${BOLD}${BLUE}────────────────────────────────────────${RESET}"
echo -e "${BOLD}${BLUE} Kepub Collection Summary${RESET}"
echo -e "${BOLD}${BLUE}────────────────────────────────────────${RESET}"
echo
echo -e "${GREEN}Found .kepub files:${RESET}              $FOUND"
echo -e "${GREEN}Created local .kepub.epub copies:${RESET} $CREATED_LOCAL"
echo -e "${GREEN}Copied to output folder:${RESET}         $COPIED_OUTPUT"
echo -e "${YELLOW}Skipped (already in output):${RESET}    $SKIPPED_OUTPUT"
echo
echo -e "${BOLD}Output folder:${RESET} $OUTPUT_DIR"
echo -e "${BOLD}${BLUE}────────────────────────────────────────${RESET}"
echo
