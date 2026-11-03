# ALT Linux VM Launcher Design

## Intent

Provide a `borg_vm_alt` shell function that starts an ALT Linux virtual machine for manual installation and later daily use. The VM must appear to the local router as an independent device so its network access can be managed separately.

## Goals

- Create a dynamically allocated, 50 GB VMDK disk at `/osa/_v/qemu_alt/alt-linux.vmdk` only when it does not already exist.
- Attach `/osa/_v/qemu_alt/alt.11.kde.iso` for user-managed installation.
- Share `/osa/_v/qemu_alt/share` with the guest using VirtIO 9p.
- Provide SPICE hot-plug USB redirection suitable for flash drives and HDA sound through PulseAudio.
- Connect the VM through a persistent bridge over the wired `enp1s0` interface, with its own stable MAC address and router-issued IP address.
- Fail with actionable messages rather than overwriting storage or silently falling back to NAT.

## Non-goals

- Starting the VM during implementation or installing ALT Linux.
- Passing through a complete USB controller or automatically taking keyboards and mice from the host.
- Changing the existing `borg_vm` function.

## Constraints

- The launcher lives at `/home/qqq/_A001/_scr/_statica/bin/function/borg_vm_alt.sh` and exports `borg_vm_alt`.
- No Git commit is to be created.
- Verification must not modify the live network.

## Approaches

- Selected: SPICE USB redirection plus a persistent Linux Ethernet bridge. This supports runtime flash-drive attachment while keeping host input devices safe, and exposes a separate guest MAC address to the router.
- Rejected: whole-controller USB passthrough, because it removes selected ports from the host and requires machine-specific PCI configuration.
- Rejected: QEMU user-mode NAT, because the router would see only the host rather than an independently manageable VM.

## Implementation outline

The function validates prerequisites and paths, serializes disk creation and VM launch, creates the VMDK on first use, and ensures a validated NetworkManager bridge named `br-alt` exists. It requests `sudo` for first-time bridge configuration and for creating a user-owned TAP attached to that bridge, avoiding reliance on a privileged QEMU bridge helper. USB redirection uses SPICE channels, and the shared directory is exposed with mount tag `hostshare` for the user to mount inside ALT Linux.
