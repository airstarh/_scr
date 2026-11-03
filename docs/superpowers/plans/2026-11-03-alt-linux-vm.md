# ALT Linux VM Launcher Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a safe `borg_vm_alt` shell function that creates and launches the approved portable ALT Linux VM configuration.

**Architecture:** Keep the launcher self-contained, with small helper functions for validation, serialized VMDK creation, first-run NetworkManager bridge setup with route verification/recovery, user-owned TAP lifecycle, and QEMU launch. Exercise behavior through a shell test harness that replaces external commands, so verification never creates a real disk, changes networking, or starts QEMU.

**Tech Stack:** Bash, QEMU 10, `qemu-img`, NetworkManager `nmcli`, SPICE USB redirection, VirtIO 9p

**Spec:** `docs/superpowers/specs/2026-11-03-alt-linux-vm-design.md`

## Global Constraints

- Launcher: `_statica/bin/function/borg_vm_alt.sh`; public function: `borg_vm_alt`.
- Disk: `/osa/_v/qemu_alt/alt-linux.vmdk`, dynamically allocated VMDK, 50 GB maximum.
- ISO: `/osa/_v/qemu_alt/alt.11.kde.iso`; share: `/osa/_v/qemu_alt/share`; mount tag: `hostshare`.
- Bridge: `br-alt` over wired interface `enp1s0`; stable guest MAC address; no NAT fallback.
- Do not start QEMU, alter the live network, overwrite storage, or create a Git commit during implementation verification.

## Review Focus

- Existing VMDK must never be recreated or truncated.
- Missing ISO/share/tool prerequisites must stop before any privileged or launch action.
- Existing valid `br-alt` must not trigger NetworkManager reconfiguration.
- Bridge setup failure must stop rather than launch with an unintended network mode.
- QEMU arguments must include the installer, a user-owned TAP attached to the bridge, 9p share, audio, and multiple SPICE USB-redirection channels.

---

### Task 1: Executable launcher behavior

**Files:**
- Create: `_statica/bin/function/borg_vm_alt.sh`
- Create: `tests/borg_vm_alt_test.sh`

**Interfaces:**
- Consumes: host commands `qemu-system-x86_64`, `qemu-img`, `nmcli`, and `sudo`.
- Produces: sourceable Bash function `borg_vm_alt`; internal helpers prefixed `_borg_vm_alt_`.

- [ ] **Step 1: Write the failing shell tests**

Cover prerequisite failure, first-run `qemu-img create -f vmdk ... 50G`, preservation of an existing disk, bridge reuse, bridge-setup failure, and exact QEMU arguments for VMDK, ISO, `br-alt`, stable MAC, `hostshare`, PulseAudio/HDA, SPICE, and USB-redirection channels.

- [ ] **Step 2: Run tests and verify RED**

Run: `bash tests/borg_vm_alt_test.sh`
Expected: FAIL because the approved launcher behavior is not implemented.

- [ ] **Step 3: Implement the launcher**

Implement `borg_vm_alt()` and `_borg_vm_alt_` helpers. Use NetworkManager to create/reuse `br-alt`, enslave `enp1s0` on first setup with explicit confirmation of command success, create the VMDK only when absent, and launch QEMU only after every prerequisite succeeds.

- [ ] **Step 4: Run automated and static verification**

Run: `bash tests/borg_vm_alt_test.sh && bash -n _statica/bin/function/borg_vm_alt.sh && shellcheck _statica/bin/function/borg_vm_alt.sh tests/borg_vm_alt_test.sh`
Expected: all tests pass; syntax is valid; ShellCheck produces no findings. If ShellCheck is unavailable, report that explicitly and retain the other verification results.

- [ ] **Step 5: Inspect repository diff without committing**

Run: `git diff --check && git status --short && git diff -- _statica/bin/function/borg_vm_alt.sh tests/borg_vm_alt_test.sh docs/superpowers`
Expected: no whitespace errors; only intended files are changed; no commit is created.
