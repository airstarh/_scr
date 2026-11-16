Yes. The safest standard tool is trash-cli. It understands FreeDesktop Trash metadata instead of blindly deleting directories.

Check whether installed:

command -v trash-list

Install if necessary:

sudo apt install trash-cli

List every Trash entry accessible to the current user, including its deletion date and original path:

trash-list

Show known Trash directories and their sizes across mounted filesystems:

uid="$(id -u)"; { printf '%s\n' "${XDG_DATA_HOME:-$HOME/.local/share}/Trash"; findmnt -rn -o TARGET | while IFS= read -r mount; do printf '%s\n' "$mount/.Trash-$uid" "$mount/.Trash/$uid"; done; } | sort -u | while IFS= read -r trash; do if [ -d "$trash" ]; then printf '\n%s\n' "$trash"; du -sh "$trash"; find "$trash/files" -mindepth 1 -maxdepth 1 -printf '.' 2>/dev/null | wc -c | awk '{print "Top-level items:",$1}'; fi; done

Safe cleanup commands:

trash-empty

Delete only entries older than 30 days:

trash-empty 30

Restore interactively:

trash-restore

Important: do not manually run rm -rf against Trash directories unless their metadata is already broken. trash-empty removes both payloads and matching .trashinfo records consistently.

This covers standards-compliant Trash locations. An application can theoretically maintain a private recycle bin elsewhere, but that would not be part of the system’s normal Trash mechanism.
