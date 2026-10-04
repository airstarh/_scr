#! /bin/bash

borg_oid_DCIM_to_sp1(){
    local rows row id media_type source_path relative_path
    local destination destination_dir temporary
    local quoted_destination quoted_dir quoted_temporary

    if ! rows="$(
        adb shell \
            "content query --user 12 \
             --uri content://media/external/file \
             --projection _id:_data:media_type \
             --where \"_data LIKE '/storage/emulated/12/DCIM/%'\" \
             --sort '_id ASC'"
    )"; then
        echo "Failed to enumerate Second Space DCIM files" >&2
        return 1
    fi

    while IFS= read -r row; do
        id="$(sed -n 's/.*_id=\([0-9]*\),.*/\1/p' <<< "$row")"
        media_type="$(sed -n 's/.*media_type=\([0-9]*\).*/\1/p' <<< "$row")"

        if [[ -z "$id" || -z "$media_type" || "$media_type" == 0 ]]; then
            continue
        fi

        source_path="${row#*_data=}"
        source_path="${source_path%, media_type=*}"
        relative_path="${source_path#/storage/emulated/12/DCIM/}"

        destination="/storage/emulated/0/_A001.sp1/DCIM/$relative_path"
        destination_dir="$(dirname -- "$destination")"
        temporary="${destination}.partial"

        printf -v quoted_dir '%q' "$destination_dir"
        printf -v quoted_temporary '%q' "$temporary"
        printf -v quoted_destination '%q' "$destination"

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
