borg_fs_tree() {
    # Custom array of folder names to skip
    SKIP_NAMES=(".git" "node_modules" "vendor")

    local start_dir="${1:-.}"
    local MAX_DEPTH="${2:-10}"

    local ORANGE='\033[0;33m'
    local PURPLE='\033[0;35m'
    local GREEN='\033[0;32m'
    local WHITE='\033[0;37m'
    local YELLOW='\033[1;33m'
    local RED='\033[0;31m'
    local BLUE='\033[0;34m'
    local NC='\033[0m'
    local BOLD='\033[1m'

    __print_color() {
        printf "%b%s%b%s" "$1" "$2" "$NC" "$3"
    }

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
                # Skip folders in SKIP_NAMES
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
                local dir_color="$ORANGE"
                [[ "$item" == _* ]] && dir_color="$PURPLE"

                printf "%s" "$prefix"
                printf "%s " "$connector"
                __print_color "$dir_color" "$item" "/"

                local content_count=$(ls -A1 "$full_path" 2>/dev/null | wc -l)
                if [ "$content_count" -eq 0 ]; then
                    __print_color "$YELLOW" " (empty)" ""
                fi
                printf "\n"

                __print_tree "$full_path" "$child_prefix" $((depth + 1))
            else
                local file_color="$WHITE"
                local suffix=""

                [[ "$item" == .* ]] && file_color="$GREEN"
                [ -x "$full_path" ] && suffix="*"

                printf "%s" "$prefix"
                printf "%s " "$connector"
                __print_color "$file_color" "$item" "$suffix"
                printf "\n"
            fi
        done
    }

    __count_items() {
        local dir="$1"
        local depth="$2"
        local dir_count=0
        local file_count=0
        local hidden_count=0
        local underscore_count=0

        if [ $depth -ge $MAX_DEPTH ]; then
            echo "0 0 0 0"
            return
        fi

        while IFS= read -r item; do
            if [ -n "$item" ] && [ "$item" != "." ] && [ "$item" != ".." ]; then
                # Skip folders in SKIP_NAMES
                if __should_skip "$item"; then
                    continue
                fi
                if [ -d "$dir/$item" ]; then
                    dir_count=$((dir_count + 1))
                    [[ "$item" == _* ]] && underscore_count=$((underscore_count + 1))
                    local sub_counts=$(__count_items "$dir/$item" $((depth + 1)))
                    local sub_dirs=$(echo "$sub_counts" | cut -d' ' -f1)
                    local sub_files=$(echo "$sub_counts" | cut -d' ' -f2)
                    local sub_hidden=$(echo "$sub_counts" | cut -d' ' -f3)
                    local sub_underscore=$(echo "$sub_counts" | cut -d' ' -f4)
                    dir_count=$((dir_count + sub_dirs))
                    file_count=$((file_count + sub_files))
                    hidden_count=$((hidden_count + sub_hidden))
                    underscore_count=$((underscore_count + sub_underscore))
                else
                    file_count=$((file_count + 1))
                    [[ "$item" == .* ]] && hidden_count=$((hidden_count + 1))
                fi
            fi
        done < <(ls -A1 "$dir" 2>/dev/null | sort)

        echo "$dir_count $file_count $hidden_count $underscore_count"
    }

    if [ ! -d "$start_dir" ]; then
        __print_color "$RED" "Error: Directory '$start_dir' does not exist" ""
        printf "\n"
        return 1
    fi

    local abs_path=$(cd "$start_dir" && pwd 2>/dev/null)
    if [ $? -ne 0 ]; then
        __print_color "$RED" "Error: Cannot access directory '$start_dir'" ""
        printf "\n"
        return 1
    fi

    __print_color "$BLUE" "📁 $abs_path" ""
    printf "\n"
    __print_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" ""
    printf "\n"

    __print_tree "$start_dir" "" 0

    printf "\n"
    __print_color "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" ""
    printf "\n"

    local counts=$(__count_items "$start_dir" 0)
    local total_dirs=$(echo "$counts" | cut -d' ' -f1)
    local total_files=$(echo "$counts" | cut -d' ' -f2)
    local total_hidden=$(echo "$counts" | cut -d' ' -f3)
    local total_underscore_dirs=$(echo "$counts" | cut -d' ' -f4)
    local total_items=$((total_dirs + total_files))

    __print_color "$BOLD" "📊 Summary:" ""
    printf "\n"
    printf "  "
    __print_color "$ORANGE" "📂 Directories: " "$total_dirs"
    printf "\n"
    printf "  "
    __print_color "$PURPLE" "📂 Underscore dirs (_*): " "$total_underscore_dirs"
    printf "\n"
    printf "  "
    __print_color "$WHITE" "📄 Regular files: " "$((total_files - total_hidden))"
    printf "\n"
    printf "  "
    __print_color "$GREEN" "📄 Hidden files (.*): " "$total_hidden"
    printf "\n"
    printf "  "
    __print_color "$YELLOW" "📦 Total items: " "$total_items"
    printf "\n"
    printf "  "
    __print_color "$YELLOW" "📏 Max depth: " "$MAX_DEPTH"
    printf "\n"

    printf "\n"
    __print_color "$BOLD" "Legend:" ""
    printf "\n"
    printf "  "
    __print_color "$ORANGE" "Orange" " - Regular directories"
    printf "\n"
    printf "  "
    __print_color "$PURPLE" "Purple" " - Directories starting with _"
    printf "\n"
    printf "  "
    __print_color "$WHITE" "White" " - Regular files"
    printf "\n"
    printf "  "
    __print_color "$GREEN" "Green" " - Hidden files (dot files)"
    printf "\n"
    printf "  "
    __print_color "$GREEN" "*" " - Executable file"
    printf "\n"
    printf "  "
    __print_color "$YELLOW" "(empty)" " - Empty directory"
    printf "\n"

    unset -f __print_tree __print_color __count_items __should_skip
}

_borg_fs_tree_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -d -- "$cur") )
}
complete -F _borg_fs_tree_completion borg_fs_tree
