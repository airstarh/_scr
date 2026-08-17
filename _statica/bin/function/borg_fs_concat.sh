borg_fs_concat() {
    if [ $# -eq 0 ]; then
        echo "Usage: borg_fs_concat <file1> [file2] ..." >&2
        return 1
    fi

    for file in "$@"; do
        if [ ! -f "$file" ]; then
            echo "Error: Cannot open file '$file'" >&2
            continue
        fi

        echo "\`\`\` $file"
        cat "$file"
        echo "\`\`\`"
        echo
    done
}
export -f borg_fs_concat
