# Expects from Nix: BTRFS_DEVICE, expected_names[@]

warn() {
  if [[ -t 2 ]]; then
    echo -e "\033[1;33mWarning: $*\033[0m" >&2
  else
    echo "Warning: $*" >&2
  fi
}

usage() {
  cat <<-'EOF'
		Usage:
		  ephemeral-orphans check
		  ephemeral-orphans prune [--dry-run]

		Commands:
		  check   List orphaned @persist subvolumes and exit.
		  prune   Delete orphaned @persist subvolumes (asks for confirmation).

		Options:
		  --dry-run  Show what would be deleted without deleting (prune only).
	EOF
}

command="${1:-}"
[[ -n $command ]] || {
  usage
  exit 1
}
shift

case "$command" in
check | prune) ;;
*)
  echo "Unknown command: $command" >&2
  usage >&2
  exit 1
  ;;
esac

dry_run=false
while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run)
    [[ $command == "prune" ]] || {
      echo "--dry-run is only valid with 'prune'" >&2
      usage >&2
      exit 1
    }
    dry_run=true
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
  shift
done

# Skip during nixos-install (no prior system exists yet)
[[ -d /run/current-system ]] || exit 0
[[ -e $BTRFS_DEVICE ]] || exit 0

# Build lookup set for expected names
declare -A expected_set
for e in "${expected_names[@]}"; do expected_set["$e"]=1; done

BTRFS_ROOT="/run/btrfs-root"

cleanup() {
  umount "$BTRFS_ROOT" 2>/dev/null || true
  rmdir "$BTRFS_ROOT" 2>/dev/null || true
}

trap cleanup EXIT
mkdir -p "$BTRFS_ROOT"

# Mount read-only for check, read-write for prune
if [[ $command == "prune" ]] && ! $dry_run; then
  mount_opts="subvolid=5,rw"
else
  mount_opts="subvolid=5,ro"
fi
mount -t btrfs -o "$mount_opts" "$BTRFS_DEVICE" "$BTRFS_ROOT" 2>/dev/null || exit 0

persist_dir="$BTRFS_ROOT/@persist"
[[ -d $persist_dir ]] || exit 0

orphans=()
while IFS= read -r subvol; do
  [[ -n $subvol ]] || continue
  subvol_name="${subvol##*/}"
  [[ -v expected_set["$subvol_name"] ]] || orphans+=("$subvol_name")
done < <(btrfs subvolume list -o "$persist_dir" 2>/dev/null | awk '{print $NF}')

if [[ ${#orphans[@]} -eq 0 ]]; then
  echo "No orphaned subvolumes found."
  exit 0
fi

if [[ $command == "check" ]]; then
  warn "Found ${#orphans[@]} orphaned persist subvolume(s):"
  for subvol_name in "${orphans[@]}"; do
    echo "  @persist/$subvol_name" >&2
  done
  echo "Run 'sudo ephemeral-orphans prune --dry-run' to preview cleanup." >&2
  exit 0
fi

echo "Found ${#orphans[@]} orphaned subvolume(s):"
for subvol_name in "${orphans[@]}"; do
  echo "  @persist/$subvol_name"
done

if $dry_run; then
  echo "Dry run - no changes made."
  exit 0
fi

read -r -p "Delete these subvolumes now? [y/N] " answer
case "$answer" in
y | Y | yes | YES)
  for subvol_name in "${orphans[@]}"; do
    btrfs subvolume delete -R "$persist_dir/$subvol_name"
    echo "  Deleted: @persist/$subvol_name"
  done
  ;;
*)
  echo "Aborted. No changes made."
  ;;
esac
