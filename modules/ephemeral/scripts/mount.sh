# Expects from Nix: BTRFS_DEVICE, persist_names[@]

SYSROOT="/sysroot"
BTRFS_ROOT="/run/btrfs-root"

cleanup() {
  umount "$BTRFS_ROOT" 2>/dev/null || true
  rmdir "$BTRFS_ROOT" 2>/dev/null || true
}

[[ ${#persist_names[@]} -gt 0 ]] || exit 0

mkdir -p "$BTRFS_ROOT"
mount -t btrfs -o subvolid=5 "$BTRFS_DEVICE" "$BTRFS_ROOT"
trap cleanup EXIT

[[ -d "$BTRFS_ROOT/@persist" ]] || exit 0

for dir in "${!persist_names[@]}"; do
  target="${SYSROOT}${dir}"
  subvol_path="@persist/${persist_names[$dir]}"

  # Skip if persist subvolume doesn't exist, already mounted, or mountpoint missing
  btrfs subvolume show "$BTRFS_ROOT/$subvol_path" &>/dev/null || continue
  findmnt -n "$target" &>/dev/null && continue
  [[ -d $target ]] || continue

  mount -t btrfs -o "subvol=$subvol_path" "$BTRFS_DEVICE" "$target"
done
