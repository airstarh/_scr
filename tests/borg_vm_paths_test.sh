#!/usr/bin/env bash

set -u

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
alt="$root/_statica/bin/function/borg_vm_alt.sh"
windows="$root/_statica/bin/function/borg_vm.sh"
failures=0

assert_contains() {
    grep -Fq -- "$2" "$1" || {
        printf 'FAIL: %s\n' "$3" >&2
        failures=$((failures + 1))
    }
}

assert_absent() {
    if grep -Fq -- "$2" "$1"; then
        printf 'FAIL: %s\n' "$3" >&2
        failures=$((failures + 1))
    fi
}

assert_contains "$alt" '/mnt/d501aaa/_v/qemu_alt' 'ALT launcher must use the moved ALT VM directory'
assert_contains "$windows" '/mnt/d501aaa/_v/qemu/w7x64_HDA.img' 'Windows launcher must use the moved disk'
assert_contains "$windows" '/mnt/d501aaa/_v/qemu/shara/' 'Windows launcher must use the moved share'
assert_absent "$alt" '/osa/_v/' 'ALT launcher must not retain the old VM root'
assert_absent "$windows" '/osa/_v/' 'Windows launcher must not retain the old VM root'

((failures == 0)) || exit 1
printf 'PASS: VM launcher paths\n'
