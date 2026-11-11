# Vaulton installation website

This repository hosts [https://ericg2.github.io](https://ericg2.github.io).

- Linux installer: `curl -fsSL https://ericg2.github.io/install.sh | sh`
- Windows installer: `irm https://ericg2.github.io/install.ps1 | iex`
- Downloads: [Vaulton GitHub Releases](https://github.com/ericg2/Vaulton-UI/releases)

The Pages workflow imports validated, versioned DEB/RPM packages when the Vaulton-UI Linux release workflow dispatches `vaulton-release-assets-ready`. There is no polling schedule. A signed repository is published only after the repository signing key is configured.

**Repository signing:** The installer now requires signed APT metadata, signed RPM packages, and signed RPM repository metadata. Generate the long-lived key with `tool/setup-linux-repository-signing.sh` in `ericg2/Vaulton-UI`, publish only its public key at `keys/vaulton-archive-keyring.gpg`, and add the exported private key as the `VAULTON_REPO_SIGNING_KEY_BASE64` Actions secret in this repository. Never commit the private key. Also configure `VAULTON_PAGES_TOKEN` in `ericg2/Vaulton-UI` with Contents: write access to this Pages repository so release workflows can dispatch the refresh event.
