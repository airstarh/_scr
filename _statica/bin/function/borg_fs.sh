# ============================================
# borg_fs_tree - Display directory tree with pseudo-graphic output
# Usage: borg_fs_tree [directory]
# Max depth: 10 levels
# ============================================
borg_fs_tree() {
    # Local function variables
    local MAX_DEPTH=10
    local current_depth=0

    # Color definitions
    local GREEN='\033[0;32m'
    local BLUE='\033[0;34m'
    local YELLOW='\033[0;33m'
    local RED='\033[0;31m'
    local NC='\033[0m' # No Color
    local BOLD='\033[1m'

    # Internal recursive function to print tree
    __print_tree() {
        local dir="$1"
        local prefix="$2"
        local depth="$3"

        # Check if depth exceeds maximum
        if [ $depth -ge $MAX_DEPTH ]; then
            echo "${prefix}${YELLOW}└── ... (max depth reached)${NC}"
            return
        fi

        # Get list of items (directories first, then files)
        local items=()
        local dirs=()
        local files=()

        # Read directory contents
        while IFS= read -r item; do
            if [ -d "$dir/$item" ]; then
                dirs+=("$item")
            else
                files+=("$item")
            fi
        done < <(ls -A "$dir" 2>/dev/null | sort)

        # Combine directories and files
        items=("${dirs[@]}" "${files[@]}")

        local total_items=${#items[@]}
        local count=0

        for item in "${items[@]}"; do
            count=$((count + 1))
            local is_last=$([ $count -eq $total_items ] && echo "true" || echo "false")
            local full_path="$dir/$item"

            # Determine the connector
            local connector="├──"
            if [ "$is_last" = "true" ]; then
                connector="└──"
            fi

            # Determine the prefix for children
            local child_prefix="$prefix"
            if [ "$is_last" = "true" ]; then
                child_prefix="${prefix}    "
            else
                child_prefix="${prefix}│   "
            fi

            # Check if it's a directory
            if [ -d "$full_path" ]; then
                # Check if directory is empty
                if [ -z "$(ls -A "$full_path" 2>/dev/null)" ]; then
                    echo "${prefix}${connector} ${BLUE}${BOLD}$item${NC} ${YELLOW}(empty)${NC}"
                else
                    echo "${prefix}${connector} ${BLUE}${BOLD}$item${NC}/"
                    __print_tree "$full_path" "$child_prefix" $((depth + 1))
                fi
            else
                # It's a file - check if executable
                if [ -x "$full_path" ]; then
                    echo "${prefix}${connector} ${GREEN}$item${NC}*"
                else
                    echo "${prefix}${connector} ${NC}$item${NC}"
                fi
            fi
        done
    }

    # Main function logic
    local start_dir="${1:-.}"

    # Check if directory exists
    if [ ! -d "$start_dir" ]; then
        echo -e "${RED}Error: Directory '$start_dir' does not exist${NC}"
        return 1
    fi

    # Get absolute path
    local abs_path=$(cd "$start_dir" && pwd 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Cannot access directory '$start_dir'${NC}"
        return 1
    fi

    # Print header
    echo -e "${BOLD}${BLUE}📁 $abs_path${NC}"
    echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Start printing tree
    __print_tree "$start_dir" "" 0

    # Print footer with statistics
    echo -e "\n${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Count total items (only top level for summary)
    local total_items=$(find "$start_dir" -maxdepth 1 -type f -o -type d 2>/dev/null | wc -l)
    local total_dirs=$(find "$start_dir" -maxdepth 1 -type d 2>/dev/null | wc -l)
    local total_files=$(find "$start_dir" -maxdepth 1 -type f 2>/dev/null | wc -l)

    echo -e "${BOLD}📊 Summary:${NC}"
    echo -e "  📂 Directories: ${BLUE}$total_dirs${NC}"
    echo -e "  📄 Files: ${GREEN}$total_files${NC}"
    echo -e "  📦 Total items: ${YELLOW}$total_items${NC}"
    echo -e "  📏 Max depth: ${YELLOW}$MAX_DEPTH${NC}"

    # Clean up internal function
    unset -f __print_tree
}

# Optional: Add tab completion for directory paths
_borg_fs_tree_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -d -- "$cur") )
}
complete -F _borg_fs_tree_completion borg_fs_tree
