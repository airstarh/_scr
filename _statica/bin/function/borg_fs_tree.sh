borg_fs_tree() {
    # Custom array of folder names to skip
    SKIP_NAMES=(".git" "node_modules" "vendor" "storage" "config" "bootstrap" "config" "public" "resources")

    local start_dir="${1:-.}"
    local MAX_DEPTH="${2:-10}"

    __should_skip() {
        local item="$1"
        for skip_name in "${SKIP_NAMES[@]}"; do
            if [ "$item" = "$skip_name" ]; then
                return 0
            fi
        done
        return 1
    }

    __print_tree() {
        local dir="$1"
        local prefix="$2"
        local depth="$3"

        if [ $depth -ge $MAX_DEPTH ]; then
            return
        fi

        local dirs=()
        local files=()

        while IFS= read -r item; do
            if [ -n "$item" ] && [ "$item" != "." ] && [ "$item" != ".." ]; then
                if __should_skip "$item"; then
                    continue
                fi
                if [ -d "$dir/$item" ]; then
                    dirs+=("$item")
                else
                    files+=("$item")
                fi
            fi
        done < <(ls -A1 "$dir" 2>/dev/null | sort)

        local items=("${dirs[@]}" "${files[@]}")
        local total_items=${#items[@]}
        local count=0

        for item in "${items[@]}"; do
            count=$((count + 1))
            local is_last=false
            [ $count -eq $total_items ] && is_last=true
            local full_path="$dir/$item"

            local connector="├──"
            $is_last && connector="└──"

            local child_prefix="$prefix"
            if $is_last; then
                child_prefix="${prefix}    "
            else
                child_prefix="${prefix}│   "
            fi

            if [ -d "$full_path" ]; then
                # Wrap folder names in square brackets
                printf "%s%s [%s]\n" "$prefix" "$connector" "$item"
                __print_tree "$full_path" "$child_prefix" $((depth + 1))
            else
                # Files without brackets
                printf "%s%s %s\n" "$prefix" "$connector" "$item"
            fi
        done
    }

    __count_items() {
        local dir="$1"
        local depth="$2"
        local dir_count=0
        local file_count=0

        if [ $depth -ge $MAX_DEPTH ]; then
            echo "0 0"
            return
        fi

        while IFS= read -r item; do
            if [ -n "$item" ] && [ "$item" != "." ] && [ "$item" != ".." ]; then
                if __should_skip "$item"; then
                    continue
                fi
                if [ -d "$dir/$item" ]; then
                    dir_count=$((dir_count + 1))
                    local sub_counts=$(__count_items "$dir/$item" $((depth + 1)))
                    local sub_dirs=$(echo "$sub_counts" | cut -d' ' -f1)
                    local sub_files=$(echo "$sub_counts" | cut -d' ' -f2)
                    dir_count=$((dir_count + sub_dirs))
                    file_count=$((file_count + sub_files))
                else
                    file_count=$((file_count + 1))
                fi
            fi
        done < <(ls -A1 "$dir" 2>/dev/null | sort)

        echo "$dir_count $file_count"
    }

    if [ ! -d "$start_dir" ]; then
        echo "Error: Directory '$start_dir' does not exist"
        return 1
    fi

    local abs_path=$(cd "$start_dir" && pwd 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Error: Cannot access directory '$start_dir'"
        return 1
    fi

    echo "📁 $abs_path"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    __print_tree "$start_dir" "" 0

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local counts=$(__count_items "$start_dir" 0)
    local total_dirs=$(echo "$counts" | cut -d' ' -f1)
    local total_files=$(echo "$counts" | cut -d' ' -f2)
    local total_items=$((total_dirs + total_files))

    echo "📊 Summary:"
    echo "  📂 Directories: $total_dirs"
    echo "  📄 Files: $total_files"
    echo "  📦 Total items: $total_items"
    echo "  📏 Max depth: $MAX_DEPTH"

    unset -f __print_tree __count_items __should_skip
}
export -f borg_fs_tree

_borg_fs_tree_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -d -- "$cur") )
}
complete -F _borg_fs_tree_completion borg_fs_tree
