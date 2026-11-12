#!/usr/bin/env sh
set -eu

REPO_BASE="https://ericg2.github.io"
repo_status="$(curl -fsSL -H "Cache-Control: no-cache" "$REPO_BASE/repo-status.json" 2>/dev/null || true)"
case "$repo_status" in
  *'"available":true'*'"signed":true'*) ;;
  *) printf '%s\n' "Vaulton Linux packages are not yet available with signature verification enabled. Use GitHub Releases for manual downloads: https://github.com/ericg2/Vaulton-UI/releases" >&2; exit 1 ;;
esac
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
  *" debian "*|*" ubuntu "*|*" linuxmint "*|*" pop "*)
    command -v apt-get >/dev/null 2>&1 || fail "APT is not installed."
    command -v sudo >/dev/null 2>&1 || fail "Install sudo, then run this script again."
    say "Configuring the Vaulton APT repository..."
    sudo install -d -m 0755 /etc/apt/sources.list.d /etc/apt/keyrings
    curl -fsSL "$REPO_BASE/keys/vaulton-archive-keyring.gpg" | sudo tee /etc/apt/keyrings/vaulton.gpg >/dev/null
    sudo chmod 0644 /etc/apt/keyrings/vaulton.gpg
    printf '%s\n' 'Types: deb' 'URIs: https://ericg2.github.io/apt' 'Suites: stable' 'Components: main' 'Architectures: amd64' 'Signed-By: /etc/apt/keyrings/vaulton.gpg' | sudo tee "$APT_SOURCE" >/dev/null
    say "Installing Vaulton..."
    sudo apt-get update
    sudo apt-get install -y vaulton
    ;;
  *" suse "*|*" opensuse "*)
    command -v zypper >/dev/null 2>&1 || fail "Zypper is not installed."
    command -v sudo >/dev/null 2>&1 || fail "Install sudo, then run this script again."
    say "Configuring the Vaulton Zypper repository..."
    sudo install -d -m 0755 /etc/zypp/repos.d
    sudo sh -c "cat > /etc/zypp/repos.d/vaulton.repo" <<EOF
[vaulton]
name=Vaulton
baseurl=$REPO_BASE/rpm/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=$REPO_BASE/keys/vaulton-archive-key.asc
type=rpm-md
EOF
    say "Installing Vaulton..."
    sudo zypper refresh
    sudo zypper install -y vaulton
    ;;
  *" fedora "*|*" rhel "*|*" centos "*|*" rocky "*|*" almalinux "*)
    command -v dnf >/dev/null 2>&1 || fail "DNF is not installed. This installer currently supports DNF-based RPM distributions."
    command -v sudo >/dev/null 2>&1 || fail "Install sudo, then run this script again."
    say "Configuring the Vaulton DNF repository..."
    sudo install -d -m 0755 /etc/yum.repos.d
    sudo sh -c "cat > '$DNF_SOURCE'" <<EOF
[vaulton]
name=Vaulton
baseurl=$REPO_BASE/rpm/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=$REPO_BASE/keys/vaulton-archive-key.asc
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
