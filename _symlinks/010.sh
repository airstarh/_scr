
mountpoint -q /var/lib/snapd && echo "OK: snapd lib bound"
mountpoint -q /var/lib/apt && echo "OK: apt lib bound"
mountpoint -q /var/cache/snapd && echo "OK: snapd cache bound"
