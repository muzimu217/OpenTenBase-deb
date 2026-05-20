#!/bin/bash
# OpenTenBase Docker entrypoint
# Initializes and starts the appropriate node type

set -e

NODE_TYPE="${NODE_TYPE:-}"
NODE_NAME="${NODE_NAME:-}"
GTM_HOST="${GTM_HOST:-}"
GTM_PORT="${GTM_PORT:-6666}"
COORD_PORT="${COORD_PORT:-5432}"
DN_PORT="${DN_PORT:-15432}"

DATA_DIR="/var/lib/opentenbase/data/${NODE_NAME}"

log() {
    echo "[opentenbase-${NODE_NAME}] $1"
}

# Initialize GTM
init_gtm() {
    if [ ! -f "$DATA_DIR/gtm.conf" ]; then
        log "Initializing GTM..."
        mkdir -p "$DATA_DIR"
        /usr/lib/opentenbase/bin/initgtm -D "$DATA_DIR" --nodename=gtm

        # Configure port
        echo "port = $GTM_PORT" >> "$DATA_DIR/gtm.conf"
        echo "listen_addresses = '*'" >> "$DATA_DIR/gtm.conf"
    fi

    log "Starting GTM on port $GTM_PORT..."
    exec /usr/lib/opentenbase/bin/gtm -D "$DATA_DIR"
}

# Initialize Coordinator
init_coordinator() {
    if [ ! -f "$DATA_DIR/postgresql.conf" ]; then
        log "Initializing Coordinator..."
        mkdir -p "$DATA_DIR"
        /usr/lib/opentenbase/bin/initdb -D "$DATA_DIR" --nodename=coordinator

        # Configure
        echo "port = $COORD_PORT" >> "$DATA_DIR/postgresql.conf"
        echo "listen_addresses = '*'" >> "$DATA_DIR/postgresql.conf"
        echo "gtm_host = '$GTM_HOST'" >> "$DATA_DIR/postgresql.conf"
        echo "gtm_port = $GTM_PORT" >> "$DATA_DIR/postgresql.conf"

        # Allow connections
        echo "host all all 0.0.0.0/0 trust" >> "$DATA_DIR/pg_hba.conf"
    fi

    log "Starting Coordinator on port $COORD_PORT..."
    exec /usr/lib/opentenbase/bin/postgres -D "$DATA_DIR"
}

# Initialize Datanode
init_datanode() {
    if [ ! -f "$DATA_DIR/postgresql.conf" ]; then
        log "Initializing Datanode..."
        mkdir -p "$DATA_DIR"
        /usr/lib/opentenbase/bin/initdb -D "$DATA_DIR" --nodename="$NODE_NAME"

        # Configure
        echo "port = $DN_PORT" >> "$DATA_DIR/postgresql.conf"
        echo "listen_addresses = '*'" >> "$DATA_DIR/postgresql.conf"
        echo "gtm_host = '$GTM_HOST'" >> "$DATA_DIR/postgresql.conf"
        echo "gtm_port = $GTM_PORT" >> "$DATA_DIR/postgresql.conf"

        # Allow connections
        echo "host all all 0.0.0.0/0 trust" >> "$DATA_DIR/pg_hba.conf"
    fi

    log "Starting Datanode on port $DN_PORT..."
    exec /usr/lib/opentenbase/bin/postgres -D "$DATA_DIR"
}

# Main
case "$NODE_TYPE" in
    gtm)
        init_gtm
        ;;
    coordinator)
        init_coordinator
        ;;
    datanode)
        init_datanode
        ;;
    *)
        log "ERROR: NODE_TYPE must be set to gtm, coordinator, or datanode"
        exit 1
        ;;
esac
