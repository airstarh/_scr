#!/bin/bash

BORG_INDEX="$(dirname "${BASH_SOURCE[0]}")"

source "${BORG_INDEX}/bin/function/borg_ssh.sh"
source "${BORG_INDEX}/bin/function/borg_git.sh"
source "${BORG_INDEX}/bin/function/borg_vm.sh"
source "${BORG_INDEX}/bin/function/borg.sh"
source "${BORG_INDEX}/bin/function/borg_diag.sh"
source "${BORG_INDEX}/bin/function/borg_bt.sh"
source "${BORG_INDEX}/bin/function/borg_dkr.sh"
