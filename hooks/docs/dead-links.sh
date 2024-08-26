#! /usr/bin/env bash

# FAIL FAST
if [ $# -le 0 ]; then
  echo "Usage: $0 <file>"
  exit 1
fi

for cmd in curl rg; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "$cmd is not installed"
    exit 1
  fi
done

PASS=true

is_url() {
  if [[ "$1" =~ ^https?:// ]]; then
    true
  else
    false
  fi
}

absolute_path() {
  PREFIX_PATH="$1" # The path of the file
  SUFFIX_PATH="$2" # The path of the link
  # +++ Possible Path Formats Handled +++
  # 1. ./file.md
  # 2. ../file.md
  # 3. /file.md
  # 4. file.md
  # Check if the link is an absolute path
  if [[ "$SUFFIX_PATH" =~ ^/ ]]; then
    echo "$SUFFIX_PATH"
  # Check if the link is a relative path
  elif [[ "$SUFFIX_PATH" =~ ^\./ ]]; then
    echo "$(echo "$PREFIX_PATH" | rg '(.*)/.+$' -or '$1')/$SUFFIX_PATH"
  # Check if the link is a relative path w/ parent directory hops
  elif [[ "$SUFFIX_PATH" =~ ^\.\./ ]]; then
    while [[ "$SUFFIX_PATH" =~ ^\.\./ ]]; do
      PREFIX_PATH="$(echo "$PREFIX_PATH" | rg '(.*)/.+$' -or '$1')"
      SUFFIX_PATH="$(echo "$SUFFIX_PATH" | rg '^\.\./(.+)$' -or '$1')"
      shift
    done
    echo "$PREFIX_PATH/$SUFFIX_PATH" | tr '//' '/'
  else
    echo "$PREFIX_PATH/$SUFFIX_PATH" | tr '//' '/'
  fi
}

# Loop through the files
for file in "$@"; do
  # Check if the file exists
  if [ -f "$file" ]; then
    # Get the links from the file
    IFS=" " read -r -a links <<< "$(rg '\[[^\(]*\]\((\S+)\)' -or '$1' "$file")"
    for link in "${links[@]}"; do
      # Split the link into its components
      IFS=" " read -r -a components <<< "$(echo "$link" | tr '#' ' ')"
      case "${#components[@]}" in
        # MEANS: No heading in the link
        1)
          # IF !URL && !FILE
          if is_url "${components[0]}"; then
            # Check if the link is reachable
            if ! curl -s --head "${components[0]//\\/}" | head -n 1 | rg -cq '200'; then
              echo "$file: Link broken (URL not reachable): ${components[0]}"
              PASS=false
            fi
          # Build absolute path to the linked file to verify it exists
          elif ! [ -f "$(absolute_path "$file" "${components[0]}")" ]; then
            echo "$file: Link broken 1(File not found): ${components[0]}"
            PASS=false
          fi
          ;;
        # MEANS: The line contains a link w/ heading
        2)
          # IF !URL && !FILE
          if is_url "${components[0]}"; then
            # Check if the link is reachable
            if ! curl -s --head "${components[0]//\\/}" | head -n 1 | rg -cq '200'; then
              echo "$file: Link broken (URL not reachable): ${components[0]}"
              PASS=false
            fi
          # Build absolute path to the linked file to verify it exists
          elif ! [ -f "$(absolute_path "$file" "${components[0]}")" ]; then
            echo "$file: Link broken (File not found): ${components[0]}"
            PASS=false
          # If Not a URL && File exists -> Check if the heading exists
          else
            # Check if the heading exists in the file
            SEARCH=$("^#+ $(echo "${components[1]}" | tr '-' ' ')")
            case $(rg -ic "$SEARCH" "${components[0]}") in
              # MEANS: The heading does not exist
              0)
                echo "$file: Link broken (Heading not found): '${components[1]}'"
                PASS=false
                ;;
              # MEANS: The heading exists
              1)
                continue
                ;;
              # MEANS: More than one heading found
              *)
                echo "$file: Error in Linked file (More than one heading found): # ${components[1]}"
                PASS=false
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
    PASS=false
  fi
done

if [ "$PASS" = false ]; then
  exit 1
fi
