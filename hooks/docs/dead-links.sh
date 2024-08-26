#! /usr/bin/env bash

# FAIL FAST
if [ -z "$1" ]; then
  echo "Usage: $0 <file>"
  exit 1
fi

for cmd in curl rg; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "$cmd is not installed"
    exit 1
  fi
done

# Loop through the files
for file in $1; do
  # Check if the file exists
  if [ -f "$file" ]; then
    # Get the links from the file
    mapfile -t links < <(rg '\[[^\(]*\]\((\S+)\)' -or '$1' "$file")
    for link in "${links[@]}"; do
      # Split the link into its components
      mapfile -t components < <(echo "$link" | tr '#' ' ')
      case "${#components[@]}" in
        # MEANS: No heading in the link
        1)
          # Check if the file the link points to exists
          if ! [ -f "${components[0]}" ]; then
            echo "$file: Link broken (File not found): ${components[0]}"
            exit 1
          fi
          ;;
        # MEANS: The line contains a link w/ heading
        2)
          # Check if the file the link points to exists
          if ! [ -f "${components[0]}" ]; then
            echo "$file: Link broken (File not found): ${components[0]}"
            exit 1
          else
            # Check if the heading exists in the file
            SEARCH=$("^#+ $(echo "${components[1]}" | tr '-' ' ')")
            case $(rg -ic "$SEARCH" "${components[0]}") in
              # MEANS: The heading does not exist
              0)
                echo "$file: Link broken (Heading not found): '${components[1]}'"
                exit 1
                ;;
              # MEANS: The heading exists
              1)
                continue
                ;;
              # MEANS: More than one heading found
              *)
                echo "$file: More than one heading found: # ${components[1]}"
                exit 1
                ;;
            esac
          fi
          ;;
        # MEANS: Somethings broke
        *)
          echo "$file: ERROR (BadNumberOfComponents)"
          echo "  - WANTS: 1 || 2"
          echo "  - GOT: ${#components[@]} (${components[*]})"
          exit 1
          ;;
      esac
    done
  else
    echo "File not found: $file"
    exit 1
  fi
done
