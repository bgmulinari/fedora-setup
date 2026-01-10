#!/bin/bash
#
# Multimedia Module - Install codecs and hardware acceleration
#

set -euo pipefail

log "Setting up multimedia support..."

# Install video codecs
install_codecs() {
    log "Installing video codecs..."
    tui_set_substep "Swapping ffmpeg-free for full ffmpeg..."

    # Swap limited ffmpeg for full version with all codecs
    if rpm -q ffmpeg &>/dev/null; then
        info "Full ffmpeg already installed"
    else
        dnf swap -y ffmpeg-free ffmpeg --allowerasing >> "$LOG_FILE" 2>&1 || true
    fi

    tui_set_substep "Installing GStreamer plugins..."

    # GStreamer plugins for video/audio playback
    dnf install -y gstreamer1-plugins-{bad-*,good-*,base} \
        gstreamer1-plugin-openh264 gstreamer1-libav lame* \
        --exclude=gstreamer1-plugins-bad-free-devel \
        >> "$LOG_FILE" 2>&1 || true

    tui_set_substep "Installing multimedia groups..."

    # Multimedia groups
    dnf group install -y multimedia >> "$LOG_FILE" 2>&1 || true
    dnf group install -y sound-and-video >> "$LOG_FILE" 2>&1 || true

    log "Video codecs installed"
}

# Install hardware acceleration support
install_hw_acceleration() {
    log "Installing hardware acceleration support..."
    tui_set_substep "Installing VA-API libraries..."

    # Core VA-API support for hardware video decoding
    dnf install -y ffmpeg-libs libva libva-utils >> "$LOG_FILE" 2>&1

    tui_set_substep "Installing OpenH264 for Firefox..."

    # Firefox H.264 fix (OpenH264 codec support)
    dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264 >> "$LOG_FILE" 2>&1 || true

    # Ensure Cisco OpenH264 repo is enabled
    dnf config-manager setopt fedora-cisco-openh264.enabled=1 >> "$LOG_FILE" 2>&1 || true

    log "Hardware acceleration installed"
}

# Execute
install_codecs
install_hw_acceleration

log "Multimedia setup complete!"
