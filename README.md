# Vaulton installation website

This repository hosts [https://ericg2.github.io](https://ericg2.github.io).

- Linux installer: `curl -fsSL https://ericg2.github.io/install.sh | sh`
- Windows installer: `irm https://ericg2.github.io/install.ps1 | iex`
- Downloads: [Vaulton GitHub Releases](https://github.com/ericg2/Vaulton-UI/releases)

The Pages workflow periodically imports the latest public Linux release packages and generates APT and DNF repository metadata.

**Repository signing:** The initial repository bootstrap uses HTTPS with APT `Trusted: yes` and DNF `gpgcheck=0`. This is convenient but does not provide package/repository signature verification. Before treating this as a high-assurance distribution channel, add a long-lived signing key as a GitHub Actions secret and enable signed APT Release metadata and RPM package signatures.
