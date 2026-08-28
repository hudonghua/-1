#!/usr/bin/env bash
set -euo pipefail

# Idempotent dev-environment bootstrap for the "-1" memory/skills sync repo.
#
# This repository has no compiled application or package-manager dependencies.
# Its only executable code is the PowerShell sync tooling under scripts/
# (auto-pull.ps1, install-auto-pull-task.ps1, install-skills-locally.ps1),
# which drives the "cloud agent push -> local pull" sync loop described in
# AGENTS.md and scripts/README.md. PowerShell is not part of the default image,
# so install it here so agents can run and validate those scripts. Everything
# else the repo needs (git, curl) is already in the base image.

PWSH_VERSION="7.6.5"

if command -v pwsh >/dev/null 2>&1; then
  echo "pwsh already installed: $(pwsh --version)"
  exit 0
fi

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    echo "ERROR: need root or sudo to install PowerShell" >&2
    exit 1
  fi
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/powershell.tar.gz" \
  "https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell-${PWSH_VERSION}-linux-x64.tar.gz"

$SUDO mkdir -p /opt/microsoft/powershell/7
$SUDO tar zxf "$tmp/powershell.tar.gz" -C /opt/microsoft/powershell/7
$SUDO chmod +x /opt/microsoft/powershell/7/pwsh
$SUDO ln -sf /opt/microsoft/powershell/7/pwsh /usr/local/bin/pwsh

echo "pwsh installed: $(pwsh --version)"
