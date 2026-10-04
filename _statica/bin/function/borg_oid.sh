#! /bin/bash

borg_oid_DCIM_to_sp1(){
    local source="${1:-/storage/emulated/12/DCIM}"
    local destination_root="${2:-/storage/emulated/0/_A001.sp1/DCIM}"
    local source_user source_prefix
    local rows row id format source_path relative_path
    local destination destination_dir temporary
    local quoted_destination quoted_dir quoted_temporary

    source="${source%/}"
    destination_root="${destination_root%/}"

    if [[ ! "$source" =~ ^/storage/emulated/([0-9]+)/.+$ || "$source" == *"'"* ]]; then
        echo "Source must match /storage/emulated/<user-id>/<directory>" >&2
        return 2
    fi
    if [[ "$destination_root" != /storage/emulated/*/* ]]; then
        echo "Destination must be below /storage/emulated/<user-id>" >&2
        return 2
    fi

    source_user="${BASH_REMATCH[1]}"
    source_prefix="$source/"

    if ! rows="$(
        adb shell \
            "content query --user $source_user \
             --uri content://media/external/file \
             --projection _id:_data:format \
             --where \"_data LIKE '$source_prefix%'\" \
             --sort '_id ASC'"
    )"; then
        echo "Failed to enumerate source files: $source" >&2
        return 1
    fi

    while IFS= read -r row; do
        id="$(sed -n 's/.*_id=\([0-9]*\),.*/\1/p' <<< "$row")"
        format="$(sed -n 's/.*format=\([0-9]*\).*/\1/p' <<< "$row")"

        # MTP format 12289 is a directory (association), not a readable file.
        if [[ -z "$id" || "$format" == 12289 ]]; then
            continue
        fi

        source_path="${row#*_data=}"
        source_path="${source_path%, format=*}"
        if [[ "$source_path" != "$source_prefix"* ]]; then
            continue
        fi
        relative_path="${source_path#"$source_prefix"}"

        destination="$destination_root/$relative_path"
        destination_dir="$(dirname -- "$destination")"
        temporary="${destination}.partial"

        printf -v quoted_dir '%q' "$destination_dir"
        printf -v quoted_temporary '%q' "$temporary"
        printf -v quoted_destination '%q' "$destination"

        if adb shell "test -e $quoted_destination"; then
            echo "Skipping existing: $relative_path"
            continue
        fi

        echo "Copying: $relative_path"
        if ! adb shell \
            "mkdir -p -- $quoted_dir && \
             content read --user 12 \
                 --uri content://media/external/file/$id \
                 > $quoted_temporary && \
             mv -- $quoted_temporary $quoted_destination"; then
            echo "Failed to copy: $relative_path" >&2
            return 1
        fi
    done <<< "$rows"
}
