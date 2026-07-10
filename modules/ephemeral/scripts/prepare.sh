# Expects from Nix: BTRFS_DEVICE, subvol_mounts[@], directories[@], files[@], persist_names[@]

BTRFS_ROOT="/run/btrfs-root"

cleanup() {
  umount "$BTRFS_ROOT" 2>/dev/null || true
  rmdir "$BTRFS_ROOT" 2>/dev/null || true
}

rel_path() {
  local rel="${1#"$2"}"
  printf '%s' "${rel#/}"
}

# Create directory path with correct permissions from source
mkdir_parents() {
  local src_base="$1" dst_base="$2" rel="$3"
  local IFS='/' part cur_src="$src_base" cur_dst="$dst_base"

  for part in $rel; do
    [[ -n $part ]] || continue
    cur_src="$cur_src/$part"
    cur_dst="$cur_dst/$part"

    [[ -d $cur_dst ]] && continue
    mkdir "$cur_dst"
    chown --reference="$cur_src" "$cur_dst"
    chmod --reference="$cur_src" "$cur_dst"
  done
}

copy_file() {
  local src_base="$1" dst_base="$2" rel="$3"
  local src="$src_base/$rel"

  [[ -e $src ]] || return 0
  mkdir_parents "$src_base" "$dst_base" "$(dirname "$rel")"
  cp -a "$src" "$dst_base/$rel"
}

setup_persist_dir() {
  local dir="$1" current="$2" next="$3" mountpoint="$4"
  local subvol_path="@persist/${persist_names[$dir]}"
  local persist_path="$BTRFS_ROOT/$subvol_path"
  local rel
  rel=$(rel_path "$dir" "$mountpoint")

  # Create persist subvolume if needed
  if ! btrfs subvolume show "$persist_path" &>/dev/null; then
    if [[ ! -d "$current/$rel" ]]; then
      echo "Warning: '$dir' does not exist in current root, skipping persist setup" >&2
      return 0
    fi
    btrfs subvolume create "$persist_path"
    chown --reference="$current/$rel" "$persist_path"
    chmod --reference="$current/$rel" "$persist_path"
    cp -a --reflink=auto "$current/$rel/." "$persist_path/"
  fi

  mkdir_parents "$current" "$next" "$rel"
}

prepare_subvolume() {
  local subvol="$1" mountpoint="$2"
  local current="$BTRFS_ROOT/$subvol"
  local backup="$BTRFS_ROOT/${subvol}-backup"
  local next="$BTRFS_ROOT/${subvol}-next"

  # Recovery: handle incomplete previous runs
  if [[ ! -d $current ]]; then
    if [[ -d $backup ]]; then
      echo "Recovery: restoring $subvol from ${subvol}-backup"
      mv "$backup" "$current"
    elif [[ -d $next ]]; then
      echo "Recovery: promoting ${subvol}-next to $subvol"
      mv "$next" "$current"
    else
      echo "Error: no $subvol found and no recovery possible" >&2
      return 1
    fi
  fi

  # Clean up stale backup/next from previous runs
  [[ -d $backup ]] && {
    echo "Cleaning up stale ${subvol}-backup"
    btrfs subvolume delete -R "$backup"
  }
  [[ -d $next ]] && {
    echo "Cleaning up stale ${subvol}-next"
    btrfs subvolume delete -R "$next"
  }

  btrfs subvolume create "$next"

  # Persist directories
  while IFS= read -r dir; do
    [[ -n $dir ]] && setup_persist_dir "$dir" "$current" "$next" "$mountpoint"
  done <<<"${directories[$subvol]:-}"

  # Persist files
  while IFS= read -r file; do
    [[ -n $file ]] && copy_file "$current" "$next" "$(rel_path "$file" "$mountpoint")"
  done <<<"${files[$subvol]:-}"

  # Rotate: current -> backup, next -> current
  # If crash after first mv: backup exists, current missing -> recovery restores backup
  # If crash after second mv: backup exists, current exists -> backup gets cleaned up next boot
  mv "$current" "$backup"
  mv "$next" "$current"

  # Safe to delete backup now
  btrfs subvolume delete -R "$backup"
}

[[ ${#subvol_mounts[@]} -gt 0 ]] || exit 0

mkdir -p "$BTRFS_ROOT"
mount -t btrfs -o subvolid=5 "$BTRFS_DEVICE" "$BTRFS_ROOT"
trap cleanup EXIT

# Create @persist on first boot and let the system initialize before rotating
if [[ ! -d "$BTRFS_ROOT/@persist" ]]; then
  btrfs subvolume create "$BTRFS_ROOT/@persist"
  exit 0
fi

for subvol in "${!subvol_mounts[@]}"; do
  prepare_subvolume "$subvol" "${subvol_mounts[$subvol]}"
done
