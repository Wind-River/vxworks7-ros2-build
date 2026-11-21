#!/usr/bin/env bash
# run-qemu.sh - boot the toolkit's ros2.img on VxWorks/QEMU, optionally attaching a
# host directory (e.g. your built RTP) as a USB disk so you can run YOUR binary
# on the target without repacking the image.
#
#   run-qemu.sh                         # just boot ros2.img
#   run-qemu.sh --usb <dir>             # + attach <dir> as USB mass storage -> /bd0a
#
# On the target command shell:
#   [vxWorks *]# /bd0a/<your_binary>
#
# Needs: qemu-system-x86_64, a VxWorks kernel (from the mounted/installed SDK),
# and tap0 up at 192.168.200.254 (sudo ip tuntap add dev tap0 mode tap; ip addr
# add 192.168.200.254/24 dev tap0; ip link set tap0 up). Quit QEMU with Ctrl-A x.
set -euo pipefail

TOOLKIT_DIR="${TOOLKIT:-${KIT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}}"
IMG="${VX_IMG:-$TOOLKIT_DIR/ros2.img}"
SDK_DIR="${WRSDK:-${WIND_SDK_HOME:-$TOOLKIT_DIR/wrsdk}}"

USB_DIR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --usb) USB_DIR="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

[ -f "$IMG" ] || { echo "no ros2.img at $IMG (set VX_IMG)"; exit 1; }
KERNEL="$(find "$SDK_DIR"/vxsdk/bsps -path '*itl_generic*/vxWorks' -print -quit 2>/dev/null || true)"
[ -n "$KERNEL" ] || { echo "no x86 vxWorks kernel under $SDK_DIR/vxsdk/bsps"; exit 1; }
command -v qemu-system-x86_64 >/dev/null || { echo "qemu-system-x86_64 not found"; exit 1; }

usb_args=()
if [ -n "$USB_DIR" ]; then
  [ -d "$USB_DIR" ] || { echo "--usb dir not found: $USB_DIR"; exit 1; }
  echo "Attaching $USB_DIR as USB mass storage -> /bd0a on target"
  usb_args=(-usb -device usb-ehci,id=ehci -device usb-storage,drive=fat32
            -drive "file=fat:rw:$USB_DIR,id=fat32,format=raw,if=none")
fi

# tap0 preflight: the bootline + -net tap need tap0 up at 192.168.200.254.
# NOTE: run `ip` with LD_LIBRARY_PATH cleared -- the sourced SDK env prepends the
# VxWorks sysroot (which carries its own libc.so.1) and would break system binaries.
if ! env -u LD_LIBRARY_PATH ip addr show tap0 2>/dev/null | grep -q '192.168.200.254'; then
  cat >&2 <<'EOF'
ERROR: network interface tap0 (192.168.200.254) is not up. The target needs it.
Set it up once (requires root privileges on your host):
    sudo ip tuntap add dev tap0 mode tap user "$(id -un)"
    sudo ip addr add 192.168.200.254/24 dev tap0
    sudo ip link set tap0 up
EOF
  exit 1
fi

echo "Booting $IMG  (kernel=$KERNEL). Quit with Ctrl-A x."
# Launch qemu with LD_LIBRARY_PATH cleared: if this script is run from a shell
# that sourced the SDK env, LD_LIBRARY_PATH carries VxWorks target libs (sysroot
# / export/root) whose libc.so.1 is NOT loadable on the host and would make
# qemu-system-x86_64 itself fail with "libc.so.1: cannot open shared object".
# qemu is a host binary and needs only the host loader path.
exec env -u LD_LIBRARY_PATH qemu-system-x86_64 -enable-kvm -smp 8 -m 2G -machine q35 -cpu Nehalem -kernel "$KERNEL" \
  -net nic -net tap,ifname=tap0,script=no,downscript=no \
  -display none -serial mon:stdio \
  -append "bootline:fs(0,0)host:/vxWorks h=192.168.200.254 e=192.168.200.1 g=192.168.200.254 u=ftp pw=ftp123 o=gei0 s=/ata0/vxscript" \
  -device ich9-ahci,id=ahci \
  -drive "file=$IMG,if=none,id=ros2disk,format=raw" \
  -device ide-hd,drive=ros2disk,bus=ahci.0 \
  "${usb_args[@]}"
