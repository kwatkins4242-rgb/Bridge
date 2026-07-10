#!/bin/bash
# ═══════════════════════════════════════════════════════════
# ODIN Start Script — boots Bridge + MCP together
# Usage: ./start.sh
# ═══════════════════════════════════════════════════════════

ENV_FILE="$HOME/Env/ENV"
BRIDGE="$HOME/MCP/server/bridge.py"
MCP_SERVER="$HOME/MCP/server/server.py"
LOG_DIR="$HOME/MCP/logs"

mkdir -p "$LOG_DIR"

# Load ENV
if [ -f "$ENV_FILE" ]; then
    set -a; source "$ENV_FILE"; set +a
    echo "[ODIN] ENV loaded from $ENV_FILE"
else
    echo "[WARN] No ENV file at $ENV_FILE"
fi

# Kill anything on 8099 cleanly
echo "[ODIN] Clearing port 8099..."
fuser -k 8099/tcp 2>/dev/null || true
sleep 1

# ── Start Bridge on 8099 ─────────────────────────────────
echo "[ODIN] Starting Bridge on port 8099..."
nohup python3 "$BRIDGE" > "$LOG_DIR/bridge.log" 2>&1 &
BRIDGE_PID=$!
echo "[ODIN] Bridge PID: $BRIDGE_PID"
sleep 2

# Verify bridge is up
if curl -s http://127.0.0.1:8099/health > /dev/null 2>&1; then
    echo "[ODIN] Bridge ✓ running on 8099"
else
    echo "[WARN] Bridge may not be up yet — check $LOG_DIR/bridge.log"
fi

# ── Start MCP (stdio mode for local IDE use) ─────────────
echo "[ODIN] MCP server ready at $MCP_SERVER"
echo "[ODIN] Connect your IDE/Claude to: $MCP_SERVER"
echo ""
echo "════════════════════════════════════════"
echo "  ODIN Stack Running"
echo "  Bridge : http://127.0.0.1:8099"
echo "  MCP    : $MCP_SERVER (stdio)"
echo "  Logs   : $LOG_DIR/"
echo "════════════════════════════════════════"
echo ""
echo "To run MCP manually:"
echo "  python3 $MCP_SERVER stdio"
echo ""
echo "To tail bridge logs:"
echo "  tail -f $LOG_DIR/bridge.log"
