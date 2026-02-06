#!/bin/bash
#
# .NET SDK Module - Install using Microsoft's official installer
#

log "Setting up .NET SDK..."

DOTNET_INSTALL_DIR="$ACTUAL_HOME/.dotnet"
DOTNET_INSTALL_SCRIPT="/tmp/dotnet-install-$$.sh"

# Show current versions if installed
if [[ -x "$DOTNET_INSTALL_DIR/dotnet" ]]; then
    info "Current .NET SDKs: $("$DOTNET_INSTALL_DIR/dotnet" --list-sdks 2>/dev/null | paste -sd ', ')"
fi

# Download installer script once
log "Downloading .NET install script..."
run_as_user curl -fsSL https://dot.net/v1/dotnet-install.sh -o "$DOTNET_INSTALL_SCRIPT" || {
    error "Failed to download .NET install script"
    return 1
}
chmod +x "$DOTNET_INSTALL_SCRIPT"
trap "rm -f '$DOTNET_INSTALL_SCRIPT'" RETURN

# Determine which SDK channels to install (from second-to-last LTS through latest)
DOTNET_CHANNELS=$(python3 -c "
import json, sys, urllib.request

url = 'https://dotnetcli.azureedge.net/dotnet/release-metadata/releases-index.json'
try:
    data = json.loads(urllib.request.urlopen(url).read())
except Exception as e:
    print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)

# Filter non-EOL channels with numeric versions
channels = []
for r in data['releases-index']:
    ver = r.get('channel-version', '')
    phase = r.get('support-phase', '')
    release_type = r.get('release-type', '')
    if phase in ('active', 'maintenance'):
        try:
            channels.append((tuple(int(x) for x in ver.split('.')), ver, release_type))
        except ValueError:
            continue

channels.sort(reverse=True)

# Find the two most recent LTS versions
lts_versions = [c for c in channels if c[2] == 'lts']
if len(lts_versions) < 2:
    # Fallback: install all non-EOL channels
    floor = channels[-1][0] if channels else (0, 0)
else:
    floor = lts_versions[1][0]

# Collect channels >= floor, output ascending by version number
result = sorted([c for c in channels if c[0] >= floor])
print(' '.join(c[1] for c in result))
") || {
    error "Failed to determine .NET channels"
    return 1
}

if [[ -z "$DOTNET_CHANNELS" ]]; then
    error "No .NET channels found"
    return 1
fi

log "Installing .NET SDK channels: $DOTNET_CHANNELS"

# Install each channel
for channel in $DOTNET_CHANNELS; do
    log "Installing .NET SDK $channel..."
    run_as_user bash "$DOTNET_INSTALL_SCRIPT" --channel "$channel" || {
        warn "Failed to install .NET SDK $channel"
    }
done

# Remove old patch versions, keeping only the latest per channel
if [[ -d "$DOTNET_INSTALL_DIR/sdk" ]]; then
    local prev_channel="" latest=""
    for ver in $(ls -v "$DOTNET_INSTALL_DIR/sdk/"); do
        # Extract major.minor from version like 8.0.406
        local cur_channel="${ver%.*}"
        if [[ "$cur_channel" == "$prev_channel" && -n "$latest" ]]; then
            log "Removing old SDK $latest..."
            rm -rf "$DOTNET_INSTALL_DIR/sdk/$latest"
        fi
        prev_channel="$cur_channel"
        latest="$ver"
    done
fi

# Show installed SDKs
if [[ -x "$DOTNET_INSTALL_DIR/dotnet" ]]; then
    info "Installed SDKs: $("$DOTNET_INSTALL_DIR/dotnet" --list-sdks 2>/dev/null | paste -sd ', ')"
fi

log ".NET SDK installation complete!"
