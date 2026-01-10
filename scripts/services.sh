#!/bin/bash
#
# Systemd Services Module
# Enables and starts services from config/services.txt
#

log "Configuring systemd services..."

SERVICES_FILE="$SCRIPT_DIR/config/services.txt"

manage_services() {
    if [[ ! -f "$SERVICES_FILE" ]]; then
        warn "Services file not found: $SERVICES_FILE"
        info "Create this file with service names to enable/start"
        return
    fi

    local enabled_count=0
    local svc_count=0
    local svc_total
    svc_total=$(grep -cve '^[[:space:]]*#' -e '^[[:space:]]*$' "$SERVICES_FILE" 2>/dev/null || echo 0)

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Trim whitespace
        line=$(echo "$line" | xargs)
        ((svc_count++))

        # Parse line: can be "service" or "service:action"
        # Actions: enable (default), disable, mask, unmask
        local service action
        if [[ "$line" == *:* ]]; then
            service="${line%%:*}"
            action="${line#*:}"
        else
            service="$line"
            action="enable"
        fi

        tui_set_substep "Configuring service $svc_count/$svc_total: $service ($action)"

        case "$action" in
            enable)
                if systemctl is-enabled "$service" &>/dev/null; then
                    info "Already enabled: $service"
                else
                    systemctl enable --now "$service" && {
                        info "Enabled and started: $service"
                        ((enabled_count++))
                    } || warn "Failed to enable: $service"
                fi
                ;;
            disable)
                systemctl disable --now "$service" 2>/dev/null && \
                    info "Disabled: $service" || \
                    warn "Failed to disable: $service"
                ;;
            mask)
                systemctl mask "$service" && \
                    info "Masked: $service" || \
                    warn "Failed to mask: $service"
                ;;
            unmask)
                systemctl unmask "$service" && \
                    info "Unmasked: $service" || \
                    warn "Failed to unmask: $service"
                ;;
            *)
                warn "Unknown action '$action' for service: $service"
                ;;
        esac
    done < "$SERVICES_FILE"
    tui_set_substep ""

    log "Enabled $enabled_count service(s)"
}

# Execute
manage_services

log "Systemd services configuration complete!"
