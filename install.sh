#!/usr/bin/env sh
set -eu

REPO_BASE="https://ericg2.github.io"
APT_SOURCE="/etc/apt/sources.list.d/vaulton.sources"
DNF_SOURCE="/etc/yum.repos.d/vaulton.repo"

say() { printf '%s\n' "$*"; }
fail() { say "Vaulton installer: $*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || fail "Run this script as your normal user; it will request sudo when needed."

if [ ! -r /etc/os-release ]; then
  fail "Cannot identify this Linux distribution. Download a package from https://github.com/ericg2/Vaulton-UI/releases"
fi
. /etc/os-release
ids=" ${ID:-} ${ID_LIKE:-} "

case "$ids" in
  *" debian "*|*" ubuntu "*|*" linuxmint "*|*" pop *)
    command -v apt-get >/dev/null 2>&1 || fail "APT is not installed."
    command -v sudo >/dev/null 2>&1 || fail "Install sudo, then run this script again."
    say "Configuring the Vaulton APT repository..."
    sudo install -d -m 0755 /etc/apt/sources.list.d
    printf '%s\n' 'Types: deb' 'URIs: https://ericg2.github.io/apt' 'Suites: stable' 'Components: main' 'Architectures: amd64' 'Trusted: yes' | sudo tee "$APT_SOURCE" >/dev/null
    say "Installing Vaulton..."
    sudo apt-get update
    sudo apt-get install -y vaulton
    ;;
  *" fedora "*|*" rhel "*|*" centos "*|*" rocky "*|*" almalinux "*|*" suse "*|*" opensuse "*)
    command -v dnf >/dev/null 2>&1 || fail "DNF is not installed. This installer currently supports DNF-based RPM distributions."
    command -v sudo >/dev/null 2>&1 || fail "Install sudo, then run this script again."
    say "Configuring the Vaulton DNF repository..."
    sudo install -d -m 0755 /etc/yum.repos.d
    sudo sh -c "cat > '$DNF_SOURCE'" <<EOF
[vaulton]
name=Vaulton
baseurl=$REPO_BASE/rpm/
enabled=1
gpgcheck=0
repo_gpgcheck=0
metadata_expire=30m
EOF
    say "Installing Vaulton..."
    sudo dnf makecache --refresh
    sudo dnf install -y vaulton
    ;;
  *)
    fail "Unsupported distribution '$ID'. Download a .deb or .rpm from https://github.com/ericg2/Vaulton-UI/releases"
    ;;
esac

say "Vaulton is installed. Future updates are available through your package manager."
