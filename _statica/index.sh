#!/bin/bash

BORG_INDEX="$(dirname "${BASH_SOURCE[0]}")"

source "${BORG_INDEX}/bin/function/borg_ssh.sh"
source "${BORG_INDEX}/bin/function/borg_git.sh"
